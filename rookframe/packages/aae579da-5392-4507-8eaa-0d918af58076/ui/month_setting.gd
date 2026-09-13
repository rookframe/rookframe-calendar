extends VBoxContainer
const TextField = preload("res://rookframe/ui/components/forms/text_field.gd")
signal changed
@onready var month_name: TextField = get_node("Row/Name")
@onready var days: TextField = get_node("Row/Days")
@onready var weeks: Label = get_node("Weeks")
var week_length: int = 7

func configure(title: String, length: int, number: int, days_per_week: int) -> void:
	month_name.label_text = "Month %d" % number
	month_name.value = title
	days.value = str(length)
	week_length = days_per_week
	refresh()

func length_value() -> int:
	if days.value.length() > 3 or not days.value.is_valid_int():
		return 0
	var length: int = int(days.value)
	return length if length >= 1 and length <= 366 else 0

func refresh() -> void:
	var length: int = length_value()
	days.error_text = "Enter a whole number from 1 to 366." if length == 0 else ""
	weeks.visible = length > 0
	weeks.text = "%d full weeks + %d days" % [int(length / week_length), length % week_length]

func name_changed(_value: String) -> void:
	changed.emit()

func length_changed(_value: String) -> void:
	refresh()
	changed.emit()
