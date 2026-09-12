extends RefCounted

## Short-lived interpretation/calculation of a supplied value. Never retained by UI or persisted separately.
const GregorianDate = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/gregorian_date.gd")
const CalendarNote = preload("res://rookframe/packages/aae579da-5392-4507-8eaa-0d918af58076/logic/calendar_note.gd")
var initialized: bool = false
var date: GregorianDate = GregorianDate.new()
var notes: Array[CalendarNote] = []
var next_note_id: int = 1

func read(value: Variant) -> bool:
	if value == null:
		initialized = false
		date = GregorianDate.new()
		notes = []
		next_note_id = 1
		return true
	if typeof(value) != TYPE_DICTIONARY:
		return false
	var record: Dictionary = value
	if record.size() != 4 or typeof(record.get("schema")) != TYPE_INT or typeof(record.get("date")) != TYPE_STRING or typeof(record.get("notes")) != TYPE_ARRAY or typeof(record.get("next_note_id")) != TYPE_INT:
		return false
	var schema: int = record.get("schema")
	var current_date: String = record.get("date")
	var next_id: int = record.get("next_note_id")
	var raw_notes: Array = record.get("notes")
	var parsed_date: GregorianDate = GregorianDate.new()
	if schema != 1 or next_id < 1 or not parsed_date.read_iso(current_date):
		return false
	var parsed_notes: Array[CalendarNote] = []
	var ids: Array[int] = []
	for raw_note in raw_notes:
		var note: CalendarNote = CalendarNote.new()
		if not note.read(raw_note) or note.id >= next_id or note.id in ids:
			return false
		ids.append(note.id)
		parsed_notes.append(note)
	date = parsed_date
	notes = parsed_notes
	next_note_id = next_id
	initialized = true
	return true

func to_value() -> Variant:
	if not initialized:
		return null
	var values: Array[Dictionary] = []
	for note in notes:
		values.append(note.to_value())
	return {"schema": 1, "date": date.iso(), "notes": values, "next_note_id": next_note_id}

func set_date(value: String) -> bool:
	if not date.read_iso(value):
		return false
	initialized = true
	return true

func advance_day() -> bool:
	return initialized and date.advance_day()

func notes_for(value: String) -> Array[CalendarNote]:
	var matching: Array[CalendarNote] = []
	for note in notes:
		if note.date == value:
			matching.append(note)
	return matching

func note_by_id(id: int) -> CalendarNote:
	for note in notes:
		if note.id == id:
			return note
	return null

func create_note(for_date: String, title: String, body: String) -> int:
	if not initialized or next_note_id == 9223372036854775807:
		return 0
	var note: CalendarNote = CalendarNote.new()
	if not note.read({"id": next_note_id, "date": for_date, "title": title.strip_edges(), "body": body.strip_edges()}):
		return 0
	notes.append(note)
	next_note_id += 1
	return note.id

func update_note(id: int, for_date: String, title: String, body: String) -> bool:
	var note: CalendarNote = note_by_id(id)
	return note != null and note.read({"id": id, "date": for_date, "title": title.strip_edges(), "body": body.strip_edges()})

func delete_note(id: int) -> bool:
	var note: CalendarNote = note_by_id(id)
	if note == null:
		return false
	var retained: Array[CalendarNote] = []
	for other in notes:
		if other.id != id:
			retained.append(other)
	notes = retained
	return true
