extends RefCounted

## Temporary Gregorian calculation helper. Years 0001–9999; no independent persistence.
var year: int = 1
var month: int = 1
var day: int = 1

func read_iso(value: String) -> bool:
	if value.length() != 10:
		return false
	var parts: PackedStringArray = value.split("-")
	if parts.size() != 3 or parts[0].length() != 4 or parts[1].length() != 2 or parts[2].length() != 2:
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
	if "%04d-%02d-%02d" % [next_year, next_month, next_day] != value:
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

## Stable day identity used by every calendar. Day zero is 0001-01-01.
func day_index() -> int:
	var prior: int = year - 1
	var result: int = prior * 365 + int(prior / 4) - int(prior / 100) + int(prior / 400)
	for earlier in range(1, month):
		result += days_in_month(year, earlier)
	return result + day - 1

func read_day_index(index: int) -> bool:
	if index < 0 or index > 3652058:
		return false
	var low: int = 1
	var high: int = 9999
	while low < high:
		var middle: int = int((low + high + 1) / 2)
		var prior: int = middle - 1
		var start: int = prior * 365 + int(prior / 4) - int(prior / 100) + int(prior / 400)
		if start <= index:
			low = middle
		else:
			high = middle - 1
	year = low
	month = 1
	day = 1
	var remaining: int = index - day_index()
	while remaining >= days_in_month(year, month):
		remaining -= days_in_month(year, month)
		month += 1
	day = remaining + 1
	return true
