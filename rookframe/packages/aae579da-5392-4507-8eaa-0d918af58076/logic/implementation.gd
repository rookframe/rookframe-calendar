extends Node

const SDK = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/sdk/package_sdk_facade.gd")
var sdk: RefCounted


func _ready() -> void:
	sdk = SDK.new()
	if has_meta("rookframe_sdk"):
		sdk.bind(get_meta("rookframe_sdk"))
