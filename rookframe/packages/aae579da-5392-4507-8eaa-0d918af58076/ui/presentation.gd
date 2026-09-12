extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/presentation.gd"

const CALENDAR_WINDOW_BUTTON: SDK.WindowButton = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window_button.tres")


func compose() -> void:
	var rail: SDK.Rail = sdk.rails.left
	rail.push(CALENDAR_WINDOW_BUTTON)
