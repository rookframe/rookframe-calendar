extends Control

const SDK = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
const RAIL = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/rail.tscn")
const WINDOW = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/ui/window.tscn")
var sdk: RefCounted
var _window: Control


func compose_presentation(host: Object) -> Control:
	sdk = SDK.new()
	sdk.bind(host)
	var rail := RAIL.instantiate() as Button
	rail.pressed.connect(_open_window)
	if not sdk.mount_rail("left", rail):
		rail.free()
	return self


func _open_window() -> void:
	if _window == null:
		_window = WINDOW.instantiate() as Control
	sdk.open_extension_surface(_window)
