extends RefCounted

## Transient interpretation of Settings; retained World dates and notes keep their day identity.
const Settings = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/settings.gd")
const SDK = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
const Date = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
var custom: bool = false
var month_names: SDK.TextList
var month_lengths: SDK.IntegerList
var weekday_names: SDK.TextList

func _init() -> void:
	month_names = SDK.TextList.new(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"])
	month_lengths = SDK.IntegerList.new([31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])
	weekday_names = SDK.TextList.new(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])

func read(values: SDK.SettingsValues) -> void:
	custom = values.text(Settings.CALENDAR_TYPE) == "Custom"
	if custom:
		month_names = values.text_list(Settings.MONTH_NAMES)
		month_lengths = values.integer_list(Settings.MONTH_LENGTHS)
		weekday_names = values.text_list(Settings.WEEKDAY_NAMES)

func year_length() -> int:
	var length: int = 0
	for index in range(month_lengths.size()):
		length += month_lengths.at(index)
	return length

func format_date(date: Date, named: bool = false) -> String:
	var year: int = date.year
	var month: int = date.month
	var day: int = date.day
	if custom:
		var index: int = date.day_index()
		year = int(index / year_length()) + 1
		var remaining: int = index % year_length()
		month = 1
		while remaining >= month_lengths.at(month - 1):
			remaining -= month_lengths.at(month - 1)
			month += 1
		day = remaining + 1
	if named:
		var weekday: String = weekday_names.at(date.day_index() % weekday_names.size())
		return "%s, %d %s %04d" % [weekday, day, month_names.at(month - 1), year]
	return "%04d-%02d-%02d" % [year, month, day]

func parse_date(value: String) -> Date:
	var date: Date = Date.new()
	if not custom:
		return date if date.read_iso(value) else null
	var parts: PackedStringArray = value.split("-")
	if parts.size() != 3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int():
		return null
	var year: int = parts[0].to_int()
	var month: int = parts[1].to_int()
	var day: int = parts[2].to_int()
	if year < 1 or year > 3652059 or month < 1 or month > month_lengths.size():
		return null
	if day < 1 or day > month_lengths.at(month - 1) or "%04d-%02d-%02d" % [year, month, day] != value:
		return null
	var index: int = (year - 1) * year_length() + day - 1
	for earlier in range(month - 1):
		index += month_lengths.at(earlier)
	return date if date.read_day_index(index) else null
