extends RefCounted
const SDK = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
const DATE_FORMAT: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/date_format.tres")
const CALENDAR_TITLE: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_title.tres")
const CALENDAR_TYPE: SDK.TextSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_type.tres")
const MONTH_NAMES: SDK.TextListSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/month_names.tres")
const MONTH_LENGTHS: SDK.IntegerListSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/month_lengths.tres")
const WEEKDAY_NAMES: SDK.TextListSetting = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/weekday_names.tres")
