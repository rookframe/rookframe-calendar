extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/implementation.gd"

const Settings = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/settings.gd")

func describe_settings() -> SDK.SettingsRegistration:
	var registration: SDK.SettingsRegistration = SDK.SettingsRegistration.new()
	registration.user = [Settings.DATE_FORMAT]
	registration.world = [Settings.CALENDAR_TITLE, Settings.CALENDAR_TYPE, Settings.MONTH_NAMES, Settings.MONTH_LENGTHS, Settings.WEEKDAY_NAMES]
	return registration

func validate_settings(candidate: SDK.SettingsCandidate) -> SDK.SettingsValidation:
	if candidate.scope != SDK.SettingsScope.Kind.WORLD:
		return SDK.SettingsValidation.new()
	if candidate.text(Settings.CALENDAR_TITLE).strip_edges().is_empty():
		return SDK.SettingsValidation.new("Enter a calendar title containing visible text.")
	var months: SDK.TextList = candidate.text_list(Settings.MONTH_NAMES)
	var lengths: SDK.IntegerList = candidate.integer_list(Settings.MONTH_LENGTHS)
	var weekdays: SDK.TextList = candidate.text_list(Settings.WEEKDAY_NAMES)
	if months.size() != lengths.size():
		return SDK.SettingsValidation.new("Every month needs a name and its own length.")
	if months.is_empty() or months.size() > 64 or weekdays.is_empty() or weekdays.size() > 32:
		return SDK.SettingsValidation.new("Use 1–64 months and 1–32 days per week.")
	for index in range(lengths.size()):
		if lengths.at(index) < 1 or lengths.at(index) > 366:
			return SDK.SettingsValidation.new("Each month must contain 1–366 days.")
	for names in [months, weekdays]:
		for index in range(names.size()):
			var name: String = names.at(index).strip_edges()
			if name.is_empty() or name.length() > 40:
				return SDK.SettingsValidation.new("Month and weekday names need 1–40 visible characters.")
			for earlier in range(index):
				if name.to_lower() == names.at(earlier).strip_edges().to_lower():
					return SDK.SettingsValidation.new("Give each month and each weekday a distinct name.")
	return SDK.SettingsValidation.new()
