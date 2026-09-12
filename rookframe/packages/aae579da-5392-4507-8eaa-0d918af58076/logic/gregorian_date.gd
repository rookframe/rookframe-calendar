extends RefCounted

## Temporary Gregorian calculation helper. This is a viewed date, never World data.
var year: int = 1
var month: int = 1
var day: int = 1

func read_iso(value: String) -> bool:
	var parts: PackedStringArray = value.split("-")
	if parts.size() != 3:
		return false
	if not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int():
		return false
	var next_year: int = parts[0].to_int()
	var next_month: int = parts[1].to_int()
	var next_day: int = parts[2].to_int()
	if next_year < 1 or next_year > 9999 or next_month < 1 or next_month > 12:
		return false
	if next_day < 1 or next_day > days_in_month(next_year, next_month):
		return false
	year = next_year
	month = next_month
	day = next_day
	return true

func days_in_month(for_year: int, for_month: int) -> int:
	if for_month == 2:
		if for_year % 400 == 0 or (for_year % 4 == 0 and for_year % 100 != 0):
			return 29
		return 28
	if for_month == 4 or for_month == 6 or for_month == 9 or for_month == 11:
		return 30
	return 31

func advance_day() -> bool:
	if year == 9999 and month == 12 and day == 31:
		return false
	day += 1
	if day > days_in_month(year, month):
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1
	return true

func iso() -> String:
	return "%04d-%02d-%02d" % [year, month, day]
