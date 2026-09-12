extends RefCounted

const GregorianDate = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
var id: int
var date: String
var title: String
var body: String

func read(value: Variant) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	var record: Dictionary = value
	if record.size() != 4 or typeof(record.get("id")) != TYPE_INT or typeof(record.get("date")) != TYPE_STRING or typeof(record.get("title")) != TYPE_STRING or typeof(record.get("body")) != TYPE_STRING:
		return false
	var next_id: int = record.get("id")
	var next_date: String = record.get("date")
	var next_title: String = record.get("title")
	var next_body: String = record.get("body")
	var checked_date: GregorianDate = GregorianDate.new()
	if next_id < 1 or not checked_date.read_iso(next_date) or next_title.strip_edges().is_empty() or next_body.strip_edges().is_empty():
		return false
	id = next_id
	date = next_date
	title = next_title
	body = next_body
	return true

func to_value() -> Dictionary:
	return {"id": id, "date": date, "title": title, "body": body}
