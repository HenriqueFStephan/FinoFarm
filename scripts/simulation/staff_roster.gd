class_name StaffRoster
extends RefCounted

## Who has been hired, and who is at the one workshop bench.

var hired: Array[String] = []
var workshop_worker_id := ""


func hire(worker_id: String) -> String:
	if StaffCatalog.worker(worker_id).is_empty():
		return "unknown_worker"
	if hired.has(worker_id):
		return "already_hired"
	hired.append(worker_id)
	return ""


func assign_workshop(worker_id: String) -> String:
	if StaffCatalog.worker(worker_id).is_empty():
		return "unknown_worker"
	if not hired.has(worker_id):
		return "not_hired"
	workshop_worker_id = worker_id
	return ""


func assigned_worker() -> Dictionary:
	if workshop_worker_id == "":
		return {}
	return StaffCatalog.worker(workshop_worker_id)


func export_state() -> Dictionary:
	var ids: Array = []
	for worker_id in hired:
		ids.append(worker_id)
	return {
		"hired": ids,
		"workshop": workshop_worker_id,
	}


func import_state(data: Dictionary) -> void:
	hired.clear()
	var raw: Array = data.get("hired", [])
	for item in raw:
		hired.append(str(item))
	workshop_worker_id = str(data.get("workshop", ""))
