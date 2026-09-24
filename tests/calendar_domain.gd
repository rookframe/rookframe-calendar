extends GdUnitTestSuite

const Date = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
const CalendarData = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_data.gd")

func test_calendar_domain() -> void:
	var date := Date.new()
	for pair in [["2024-02-28", "2024-02-29"], ["2024-02-29", "2024-03-01"], ["1900-02-28", "1900-03-01"], ["2000-02-28", "2000-02-29"], ["2023-12-31", "2024-01-01"]]:
		assert_bool(date.read_iso(pair[0])).is_true()
		assert_bool(date.advance_day()).is_true()
		assert_bool(date.iso() == pair[1]).is_true()
	assert_bool(date.read_iso("9999-12-31")).is_true()
	assert_bool(not date.advance_day()).is_true()
	assert_bool(date.iso() == "9999-12-31").is_true()
	for invalid in ["0000-01-01", "10000-01-01", "2023-02-29", "2024-04-31", "2024-13-01", "2024-2-01", "+2024-02-01"]:
		assert_bool(not date.read_iso(invalid)).override_failure_message("Accepted invalid date: " + invalid).is_true()
	var calendar := CalendarData.new()
	assert_bool(calendar.read(null)).is_true()
	assert_bool(not calendar.initialized).is_true()
	assert_bool(not calendar.advance_day()).is_true()
	assert_bool(calendar.set_date("2024-02-28")).is_true()
	var id := calendar.create_note("2024-02-28", "Arrival", "At the harbor")
	assert_bool(id == 1).is_true()
	assert_bool(calendar.create_note("2024-02-29", "Leap day", "Festival") == 2).is_true()
	assert_bool(calendar.notes_for("2024-02-28").size() == 1).is_true()
	assert_bool(calendar.update_note(id, "2024-02-28", "Arrival changed", "At the inn")).is_true()
	assert_bool(calendar.notes_for("2024-02-28")[0].body == "At the inn").is_true()
	var before: Variant = calendar.to_value()
	assert_bool(not calendar.set_date("2023-02-29")).is_true()
	assert_bool(not calendar.update_note(999, "2024-02-28", "Missing", "Unknown")).is_true()
	assert_bool(calendar.create_note("2024-02-30", "Invalid", "Date") == 0).is_true()
	assert_bool(calendar.to_value() == before).is_true()
	var fresh := CalendarData.new()
	assert_bool(fresh.read(calendar.to_value())).is_true()
	assert_bool(fresh.advance_day()).is_true()
	assert_bool(fresh.date.iso() == "2024-02-29").is_true()
	assert_bool(fresh.delete_note(id)).is_true()
	assert_bool(fresh.notes_for("2024-02-28").is_empty()).is_true()
	assert_bool(fresh.notes_for("2024-02-29").size() == 1).is_true()
	assert_bool(not fresh.read({"schema": 999, "date": "2024-02-28", "notes": []})).is_true()
	var implementation = load("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/implementation.gd").new()
	var invalid_rules := {"calendar_title": "Campaign", "calendar_type": "Custom", "month_names": ["Dawn", "Dusk"], "month_lengths": [30], "weekday_names": ["Sun", "Moon"]}
	assert_bool(not implementation._rookframe_validate_settings(1, invalid_rules).is_empty()).override_failure_message("Custom calendar accepted mismatched month names and lengths").is_true()
	implementation.free()
	var SDK = load("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
	var Rules = load("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_rules.gd")
	var rules = Rules.new()
	rules.custom = true
	rules.month_names = SDK.TextList.new(["Dawn", "Dusk"])
	rules.month_lengths = SDK.IntegerList.new([3, 2])
	rules.weekday_names = SDK.TextList.new(["Sun", "Moon"])
	assert_bool(date.read_iso("0001-01-04")).is_true()
	assert_bool(rules.format_date(date) == "0001-02-01").is_true()
	assert_bool(rules.format_date(date, true) == "Moon, 1 Dusk 0001").is_true()
	assert_bool(rules.parse_date("0001-02-02").iso() == "0001-01-05").is_true()
	assert_bool(rules.parse_date("0002-01-01").iso() == "0001-01-06").is_true()
	assert_bool(rules.parse_date("0001-02-03") == null).is_true()
	var retained: Variant = calendar.to_value()
	var note_day = Date.new()
	assert_bool(note_day.read_iso("2024-02-28")).is_true()
	assert_bool(rules.parse_date(rules.format_date(note_day)).iso() == "2024-02-28").is_true()
	rules.month_lengths = SDK.IntegerList.new([5, 8])
	assert_bool(rules.parse_date(rules.format_date(note_day)).iso() == "2024-02-28").is_true()
	assert_bool(calendar.to_value() == retained).is_true()
	for boundary in ["0001-01-01", "1900-03-01", "2000-02-29", "2024-02-29", "9999-12-31"]:
		assert_bool(date.read_iso(boundary)).is_true()
		var copy := Date.new()
		assert_bool(copy.read_day_index(date.day_index())).is_true()
		assert_bool(copy.iso() == boundary).is_true()


func test_month_editor() -> void:
	var row = load("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/month_setting.tscn").instantiate()
	add_child(auto_free(row))
	row.configure("Dawn", 3, 1, 2)
	for malformed in ["3.5", "3x0", "", "0", "-1", "367", "18446744073709551619"]:
		row.days.value = malformed
		row.length_changed(malformed)
		assert_bool(not row.days.error_text.is_empty()).override_failure_message("Month editor accepted malformed length: " + malformed).is_true()
	for valid in ["1", "30", "366"]:
		row.days.value = valid
		row.length_changed(valid)
		assert_bool(row.days.error_text.is_empty()).override_failure_message("Month editor rejected valid length: " + valid).is_true()
	row.free()



func after_test() -> void:
	await get_tree().process_frame
