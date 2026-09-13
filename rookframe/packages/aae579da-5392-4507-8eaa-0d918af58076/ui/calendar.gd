extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/window.gd"

const SettingsScope = SDK.SettingsScope
const GregorianDate = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
const CalendarData = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_data.gd")
const CalendarNote = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_note.gd")
const DATE_FORMAT: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/date_format.tres")
const CALENDAR_TITLE: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_title.tres")
const CalendarRules = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_rules.gd")
const TextField = preload("res://rookframe/ui/components/forms/text_field.gd")
const TextArea = preload("res://rookframe/ui/components/forms/text_area.gd")

@onready var date_field: TextField = get_node("Layout/Body/Fields/Date")
@onready var note_title: TextField = get_node("Layout/Body/Fields/NoteTitle")
@onready var note_body: TextArea = get_node("Layout/Body/Fields/NoteBody")
@onready var draft_row: Label = get_node("Layout/Body/Fields/Draft/Copy/Title")
@onready var draft_detail: Label = get_node("Layout/Body/Fields/Draft/Copy/Detail")
@onready var draft_status: Label = get_node("Layout/Body/Fields/Draft/Copy/Status")
@onready var saved_note: Label = get_node("Layout/Body/Fields/SavedNote/Copy/Title")
@onready var saved_body: Label = get_node("Layout/Body/Fields/SavedBody")
@onready var note_count: Label = get_node("Layout/Body/Fields/NoteCount")
@onready var status: Label = get_node("Layout/Status")
var viewed_date: GregorianDate = GregorianDate.new()
var selected_note_id: int = 0
var editing_note_id: int = 0

func ready() -> void:
	if sdk != null:
		sdk.settings.changed.connect(settings_changed)
	get_node("Layout/Header").text = translated("Calendar")
	get_node("Layout/WorldDate").text = translated("World date not set")
	date_field.label_text = translated("View date")
	date_field.help_text = translated("Year-month-day · use the month and day numbers of this calendar")
	note_title.label_text = translated("Note title")
	note_body.label_text = translated("Note")
	note_body.placeholder = translated("Write a note for this date…")
	get_node("Layout/Body/Fields/DateActions/SetDate").text = translated("Set world date")
	get_node("Layout/Body/Fields/DateActions/Advance").text = translated("Advance World one day")
	get_node("Layout/CopyDate").text = translated("Copy World date")
	get_node("Layout/Body/Fields/NoteActions/Copy").text = translated("Copy note")
	get_node("Layout/SaveNote").text = translated("Save note")
	date_field.value = rules().format_date(viewed_date)
	var calendar: CalendarData = read_calendar()
	if calendar != null:
		if calendar.initialized:
			viewed_date.read_iso(calendar.date.iso())
			date_field.value = rules().format_date(viewed_date)
			status.text = translated("Changes are saved to this World. Unsaved drafts end when you leave.")
		else:
			status.text = translated("Set an explicit starting World date before saving notes.")
		refresh_calendar(calendar)
	refresh_draft("")
	show_notes()

func translated(message: String) -> String:
	if sdk == null:
		return message
	return sdk.translations.text(message)

func read_calendar() -> CalendarData:
	if sdk == null:
		status.text = translated("Open Calendar in a Rookframe World to read and save its data.")
		return null
	var result: SDK.DataResult = sdk.world_data.read()
	if not result.ok:
		status.text = result.message
		return null
	var calendar: CalendarData = CalendarData.new()
	if not calendar.read(result.value):
		status.text = translated("This Calendar release cannot interpret the retained data. No changes were saved.")
		return null
	return calendar

func refresh_calendar(calendar: CalendarData) -> void:
	get_node("Layout/Header").text = sdk.settings.world.text(CALENDAR_TITLE)
	get_node("Layout/WorldDate").text = translated("World date: ") + display_date(calendar.date) if calendar.initialized else translated("World date not set")
	var matching: Array[CalendarNote] = calendar.notes_for(viewed_date.iso())
	var selected: CalendarNote = null
	var index: int = 0
	for note in matching:
		index += 1
		if note.id == selected_note_id:
			selected = note
			break
	if selected == null and not matching.is_empty():
		selected = matching[0]
		index = 1
	selected_note_id = selected.id if selected != null else 0
	saved_note.text = selected.title if selected != null else translated("No notes for this date")
	saved_body.text = selected.body if selected != null else ""
	note_count.text = "%d / %d" % [index if selected != null else 0, matching.size()]
	var context: SDK.WorldContext = sdk.context()
	var can_edit: bool = context.ok and context.is_gm
	get_node("Layout/Body/Fields/DateActions/SetDate").disabled = not can_edit
	get_node("Layout/Body/Fields/DateActions/Advance").disabled = not can_edit or not calendar.initialized
	get_node("Layout/CopyDate").disabled = not calendar.initialized
	get_node("Layout/Body/Fields/NoteActions/Copy").disabled = selected == null
	get_node("Layout/SaveNote").disabled = not can_edit or not calendar.initialized
	get_node("Layout/NewNote").disabled = not can_edit or not calendar.initialized
	get_node("Layout/Body/Fields/NoteActions/Edit").disabled = not can_edit or selected == null
	get_node("Layout/Body/Fields/NoteActions/Delete").disabled = not can_edit or selected == null
	get_node("Layout/Body/Fields/NoteNavigation/Previous").disabled = index <= 1
	get_node("Layout/Body/Fields/NoteNavigation/Next").disabled = index >= matching.size()

func view_date(value: String) -> void:
	if not read_viewed_date(value):
		date_field.error_text = translated("Enter a valid year-month-day in this calendar, for example 0001-01-01.")
		return
	date_field.error_text = ""
	selected_note_id = 0
	var calendar: CalendarData = read_calendar()
	if calendar != null:
		refresh_calendar(calendar)
	refresh_draft("")

func advance_date() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	if not calendar.advance_day():
		status.text = translated("Set a starting date, or choose a date before 9999-12-31.")
		return
	if commit_calendar(calendar):
		viewed_date.read_iso(calendar.date.iso())
		date_field.value = rules().format_date(viewed_date)
		refresh_calendar(calendar)
		refresh_draft("")

func refresh_draft(_value: String) -> void:
	draft_row.text = note_title.value if not note_title.value.is_empty() else translated("Untitled note")
	draft_detail.text = display_date(viewed_date)
	draft_status.text = translated("Editing saved note") if editing_note_id != 0 else translated("New note draft")

func request_set_date() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	var parsed: GregorianDate = rules().parse_date(date_field.value)
	if parsed == null or not calendar.set_date(parsed.iso()):
		view_date(date_field.value)
		return
	if commit_calendar(calendar):
		viewed_date.read_iso(calendar.date.iso())
		refresh_calendar(calendar)
		refresh_draft("")

func request_save_note() -> void:
	if not read_viewed_date(date_field.value):
		view_date(date_field.value)
		return
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	var id: int = editing_note_id
	if id == 0:
		id = calendar.create_note(viewed_date.iso(), note_title.value, note_body.value)
	elif not calendar.update_note(id, viewed_date.iso(), note_title.value, note_body.value):
		id = 0
	if id == 0:
		note_body.error_text = translated("Set the World date and add a valid title and note before saving.")
		return
	note_body.error_text = ""
	if commit_calendar(calendar):
		editing_note_id = id
		selected_note_id = id
		refresh_calendar(calendar)
		refresh_draft("")
		show_notes()

func commit_calendar(calendar: CalendarData) -> bool:
	var result: SDK.OperationResult = sdk.world_data.replace(calendar.to_value())
	if not result.ok:
		status.text = result.message
		return false
	# Observe the accepted value through a fresh public query.
	var fresh: CalendarData = read_calendar()
	if fresh == null:
		return false
	refresh_calendar(fresh)
	status.text = translated("Saved to this World.")
	return true

func previous_note() -> void:
	navigate_note(-1)

func next_note() -> void:
	navigate_note(1)

func navigate_note(direction: int) -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	var matching: Array[CalendarNote] = calendar.notes_for(viewed_date.iso())
	for index in range(matching.size()):
		if matching[index].id == selected_note_id:
			var next_index: int = index + direction
			if next_index >= 0 and next_index < matching.size():
				selected_note_id = matching[next_index].id
			break
	refresh_calendar(calendar)

func edit_note() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	var note: CalendarNote = calendar.note_by_id(selected_note_id)
	if note != null:
		editing_note_id = note.id
		note_title.value = note.title
		note_body.value = note.body
		refresh_draft("")
		show_mode(2)

func new_note() -> void:
	editing_note_id = 0
	note_title.value = ""
	note_body.value = ""
	note_body.error_text = ""
	refresh_draft("")
	show_mode(2)

func delete_note() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null or not calendar.delete_note(selected_note_id):
		return
	var removed_id: int = selected_note_id
	if commit_calendar(calendar):
		if editing_note_id == removed_id:
			new_note()
		selected_note_id = 0
		refresh_calendar(calendar)

func show_notes() -> void:
	show_mode(0)

func show_world_date() -> void:
	show_mode(1)

func show_mode(mode: int) -> void:
	var editing: bool = mode == 2
	var browsing: bool = mode == 0
	get_node("Layout/Body/Fields/DateActions").visible = mode == 1
	get_node("Layout/Body/Fields/SavedNote").visible = browsing
	saved_body.visible = browsing
	note_count.visible = browsing
	get_node("Layout/Body/Fields/NoteNavigation").visible = browsing
	get_node("Layout/Body/Fields/NoteActions").visible = browsing
	get_node("Layout/Body/Fields/Draft").visible = editing
	note_title.visible = editing
	note_body.visible = editing
	get_node("Layout/BackToNotes").visible = not browsing
	get_node("Layout/SaveNote").visible = editing
	get_node("Layout/WorldDateActions").visible = browsing
	get_node("Layout/NewNote").visible = browsing


func settings_changed(_scope: SettingsScope.Kind) -> void:
	date_field.value = rules().format_date(viewed_date)
	date_field.error_text = ""
	refresh_draft("")
	var calendar: CalendarData = read_calendar()
	if calendar != null:
		refresh_calendar(calendar)

func rules() -> CalendarRules:
	var result: CalendarRules = CalendarRules.new()
	if sdk != null:
		result.read(sdk.settings.world)
	return result

func read_viewed_date(value: String) -> bool:
	var parsed: GregorianDate = rules().parse_date(value)
	return parsed != null and viewed_date.read_iso(parsed.iso())

func display_date(date: GregorianDate) -> String:
	return rules().format_date(date, sdk != null and sdk.settings.user.text(DATE_FORMAT) == "Day month year")


func copy_date() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null or not calendar.initialized:
		return
	var result: SDK.IntegrationResult = sdk.clipboard.write_text(display_date(calendar.date))
	status.text = translated("Date copied.") if result.ok else result.message

func copy_note() -> void:
	var calendar: CalendarData = read_calendar()
	if calendar == null:
		return
	var selected: CalendarNote = calendar.note_by_id(selected_note_id)
	if selected == null:
		return
	var result: SDK.IntegrationResult = sdk.clipboard.write_text(selected.title + "\n" + selected.body)
	status.text = translated("Note copied.") if result.ok else result.message
