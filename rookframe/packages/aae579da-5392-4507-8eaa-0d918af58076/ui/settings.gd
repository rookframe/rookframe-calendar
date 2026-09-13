extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/settings_view.gd"
const SDK = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
const Settings = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/settings.gd")
const TextField = preload("res://rookframe/ui/components/forms/text_field.gd")
const MonthSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/month_setting.gd")
const MONTH_SCENE: PackedScene = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/month_setting.tscn")
const TEXT_SCENE: PackedScene = preload("res://rookframe/ui/components/forms/text_field.tscn")
@onready var title_field: TextField = get_node("World/Title")



var _populating: bool = false
var months: Array[MonthSetting] = []
var weekdays: Array[TextField] = []

func edit() -> void:
	_populating = true
	get_node("World").visible = scope == SettingsScope.Kind.WORLD
	get_node("User").visible = scope == SettingsScope.Kind.USER
	if scope == SettingsScope.Kind.USER:
		refresh_format()
	else:
		title_field.value = draft.text(Settings.CALENDAR_TITLE)
		populate_months()
		populate_weekdays()
		show_section("Months")
	_populating = false
	refresh()

func populate_months() -> void:
	var parent: VBoxContainer = get_node("World/Custom/Months/Rows")
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	months = []
	var names: SDK.TextList = draft.text_list(Settings.MONTH_NAMES)
	var lengths: SDK.IntegerList = draft.integer_list(Settings.MONTH_LENGTHS)
	for index in range(names.size()):
		var row: MonthSetting = MONTH_SCENE.instantiate()
		parent.add_child(row)
		row.configure(names.at(index), lengths.at(index), index + 1, draft.text_list(Settings.WEEKDAY_NAMES).size())
		row.changed.connect(months_changed)
		months.append(row)

func populate_weekdays() -> void:
	var parent: VBoxContainer = get_node("World/Custom/Week/Rows")
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	weekdays = []
	var names: SDK.TextList = draft.text_list(Settings.WEEKDAY_NAMES)
	for index in range(names.size()):
		var row: TextField = TEXT_SCENE.instantiate()
		parent.add_child(row)
		row.label_text = "Day %d" % [index + 1]
		row.value = names.at(index)
		row.value_changed.connect(weekdays_changed)
		weekdays.append(row)

func title_changed(value: String) -> void:
	if not _populating:
		draft.set_text(Settings.CALENDAR_TITLE, value)

func type_changed(index: int) -> void:
	if not _populating:
		draft.set_text(Settings.CALENDAR_TYPE, "Custom" if index == 1 else "Classic")
		refresh()

func format_changed(index: int) -> void:
	if not _populating:
		draft.set_text(Settings.DATE_FORMAT, "ISO" if index == 0 else "Day month year")
		refresh_format()

func month_count_changed(value: int) -> void:
	if _populating:
		return
	var names: SDK.TextList = draft.text_list(Settings.MONTH_NAMES)
	var lengths: SDK.IntegerList = draft.integer_list(Settings.MONTH_LENGTHS)
	var next_names: SDK.TextList = SDK.TextList.new()
	var next_lengths: SDK.IntegerList = SDK.IntegerList.new()
	for index in range(value):
		next_names.append(names.at(index) if index < names.size() else "Month %d" % [index + 1])
		next_lengths.append(lengths.at(index) if index < lengths.size() else 30)
	names = next_names
	lengths = next_lengths
	draft.set_text_list(Settings.MONTH_NAMES, names)
	draft.set_integer_list(Settings.MONTH_LENGTHS, lengths)
	populate_months()
	refresh()

func weekday_count_changed(value: int) -> void:
	if _populating:
		return
	var names: SDK.TextList = draft.text_list(Settings.WEEKDAY_NAMES)
	var next_names: SDK.TextList = SDK.TextList.new()
	for index in range(value):
		next_names.append(names.at(index) if index < names.size() else "Day %d" % [index + 1])
	names = next_names
	draft.set_text_list(Settings.WEEKDAY_NAMES, names)
	populate_weekdays()
	for row in months:
		row.week_length = int(value)
		row.refresh()
	refresh()

func months_changed() -> void:
	var names: SDK.TextList = SDK.TextList.new()
	var lengths: SDK.IntegerList = SDK.IntegerList.new()
	for row in months:
		names.append(row.month_name.value)
		lengths.append(int(row.days.value))
	draft.set_text_list(Settings.MONTH_NAMES, names)
	draft.set_integer_list(Settings.MONTH_LENGTHS, lengths)
	refresh()

func weekdays_changed(_value: String) -> void:
	var names: SDK.TextList = SDK.TextList.new()
	for row in weekdays:
		names.append(row.value)
	draft.set_text_list(Settings.WEEKDAY_NAMES, names)
	refresh()

func refresh() -> void:
	if scope != SettingsScope.Kind.WORLD:
		return
	var custom: bool = draft.text(Settings.CALENDAR_TYPE) == "Custom"
	get_node("World/Type/Classic").theme_type_variation = "RookframeManagedControl" if custom else "RookframeManagedSelected"
	get_node("World/Type/Custom").theme_type_variation = "RookframeManagedSelected" if custom else "RookframeManagedControl"
	refresh_count("Months", months.size(), 64)
	refresh_count("Week", weekdays.size(), 32)
	get_node("World/Custom").visible = custom
	get_node("World/Classic").visible = not custom
	var days: int = 0
	var lengths: SDK.IntegerList = draft.integer_list(Settings.MONTH_LENGTHS)
	for index in range(lengths.size()):
		days += lengths.at(index)
	get_node("World/Custom/Summary").text = "%d months · %d days per year · %d days per week" % [months.size(), days, weekdays.size()]

func show_section(section: String) -> void:
	for name in ["Months", "Week"]:
		get_node("World/Custom/" + name).visible = section == name
		get_node("World/Custom/Sections/" + name).theme_type_variation = "RookframeManagedSelected" if section == name else "RookframeManagedControl"

func show_months() -> void:
	show_section("Months")

func show_week() -> void:
	show_section("Week")

func classic() -> void:
	type_changed(0)

func custom() -> void:
	type_changed(1)

func numeric_format() -> void:
	format_changed(0)

func named_format() -> void:
	format_changed(1)

func refresh_format() -> void:
	var numeric: bool = draft.text(Settings.DATE_FORMAT) == "ISO"
	get_node("User/Numeric").theme_type_variation = "RookframeManagedSelected" if numeric else "RookframeManagedControl"
	get_node("User/Named").theme_type_variation = "RookframeManagedControl" if numeric else "RookframeManagedSelected"

func add_month() -> void:
	month_count_changed(months.size() + 1)

func remove_month() -> void:
	month_count_changed(months.size() - 1)

func add_weekday() -> void:
	weekday_count_changed(weekdays.size() + 1)

func remove_weekday() -> void:
	weekday_count_changed(weekdays.size() - 1)

func refresh_count(section: String, count: int, maximum: int) -> void:
	get_node("World/Custom/" + section + "/Count/Value").text = str(count)
	get_node("World/Custom/" + section + "/Count/Minus").disabled = count <= 1
	get_node("World/Custom/" + section + "/Count/Plus").disabled = count >= maximum
