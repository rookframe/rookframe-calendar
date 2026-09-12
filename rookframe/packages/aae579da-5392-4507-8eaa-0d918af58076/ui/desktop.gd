extends "res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/presentation.gd"

const WINDOW_BUTTON: SDK.WindowButton = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window_button.tres")

func compose() -> void:
	sdk.rails.left.push(WINDOW_BUTTON)
