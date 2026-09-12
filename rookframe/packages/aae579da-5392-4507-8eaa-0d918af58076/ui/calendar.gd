extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/window.gd"

const GregorianDate = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
const TextField = preload("res://rookframe/ui/components/forms/text_field.gd")
const TextArea = preload("res://rookframe/ui/components/forms/text_area.gd")
const StructuredRow = preload("res://rookframe/ui/components/data/structured_row.gd")

@onready var date_field: TextField = get_node("Layout/Body/Fields/Date")
@onready var note_title: TextField = get_node("Layout/Body/Fields/NoteTitle")
@onready var note_body: TextArea = get_node("Layout/Body/Fields/NoteBody")
@onready var draft_row: StructuredRow = get_node("Layout/Body/Fields/Draft")
@onready var status: Label = get_node("Layout/Status")
var viewed_date: GregorianDate = GregorianDate.new()

func ready() -> void:
	get_node("Layout/Header").text = translated("Calendar")
	get_node("Layout/WorldDate").text = translated("World date not set")
	date_field.label_text = translated("View date")
	date_field.help_text = translated("Gregorian calendar · YYYY-MM-DD")
	note_title.label_text = translated("Note title")
	note_body.label_text = translated("Note")
	note_body.placeholder = translated("Write a note for this date…")
	get_node("Layout/Body/Fields/DateActions/SetDate").text = translated("Set world date")
	get_node("Layout/Body/Fields/DateActions/Advance").text = translated("Advance one day")
	get_node("Layout/Body/Fields/NotesHeading").text = translated("Dated notes")
	get_node("Layout/SaveNote").text = translated("Save note")
	status.text = translated("Drafts stay here until you leave the World.")
	date_field.value = viewed_date.iso()
	refresh_draft("")

func translated(message: String) -> String:
	if sdk == null:
		return message
	return sdk.translations.text(message)

func view_date(value: String) -> void:
	if not viewed_date.read_iso(value):
		date_field.error_text = translated("Enter a Gregorian date from 0001-01-01 to 9999-12-31.")
		return
	date_field.error_text = ""
	refresh_draft("")

func advance_date() -> void:
	if not viewed_date.read_iso(date_field.value):
		view_date(date_field.value)
		return
	if not viewed_date.advance_day():
		date_field.error_text = translated("This is the last supported date.")
		return
	date_field.value = viewed_date.iso()
	date_field.error_text = ""
	refresh_draft("")
	status.text = translated("Viewing the next day. The World date is unchanged.")

func refresh_draft(_value: String) -> void:
	draft_row.title = note_title.value if not note_title.value.is_empty() else translated("Untitled note")
	draft_row.detail = viewed_date.iso()
	draft_row.status_text = translated("Draft")

func request_set_date() -> void:
	if not viewed_date.read_iso(date_field.value):
		view_date(date_field.value)
		return
	status.text = translated("This World cannot save Calendar changes yet. Your draft is still here.")

func request_save_note() -> void:
	if note_title.value.strip_edges().is_empty() or note_body.value.strip_edges().is_empty():
		note_body.error_text = translated("Add a title and a note before saving.")
		return
	note_body.error_text = ""
	status.text = translated("This World cannot save Calendar changes yet. Your draft is still here.")
