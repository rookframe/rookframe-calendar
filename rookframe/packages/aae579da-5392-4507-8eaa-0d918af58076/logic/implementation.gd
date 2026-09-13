extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/implementation.gd"

const DATE_FORMAT: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/date_format.tres")
const CALENDAR_TITLE: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_title.tres")

func describe_settings() -> SDK.SettingsRegistration:
	var registration: SDK.SettingsRegistration = SDK.SettingsRegistration.new()
	registration.user = [DATE_FORMAT]
	registration.world = [CALENDAR_TITLE]
	return registration

func validate_settings(candidate: SDK.SettingsCandidate) -> SDK.SettingsValidation:
	if candidate.scope == SDK.SettingsScope.Kind.WORLD and candidate.text(CALENDAR_TITLE).strip_edges().is_empty():
		return SDK.SettingsValidation.new("Enter a calendar title containing visible text.")
	return SDK.SettingsValidation.new()
