class_name StaffRoster
extends RefCounted

## Who has been hired, who is at the loom, and who is at the packing bench.

const WAGE_INTERVAL := 10

var hired: Array[String] = []
var workshop_worker_id := ""
var packing_worker_id := ""
var experience := {}
var wage_progress := 0


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


func assign_packing(worker_id: String) -> String:
	if StaffCatalog.worker(worker_id).is_empty():
		return "unknown_worker"
	if not hired.has(worker_id):
		return "not_hired"
	packing_worker_id = worker_id
	return ""


func assigned_worker() -> Dictionary:
	return presented(workshop_worker_id)


func packing_worker() -> Dictionary:
	return presented(packing_worker_id)


## One finished job raises Efficiency by 1, once. The catalog row stays put.
func grant_experience(worker_id: String) -> bool:
	if worker_id == "" or not hired.has(worker_id):
		return false
	if int(experience.get(worker_id, 0)) >= 1:
		return false
	experience[worker_id] = 1
	return true


func presented(worker_id: String) -> Dictionary:
	if worker_id == "":
		return {}
	var person := StaffCatalog.worker(worker_id)
	if person.is_empty():
		return {}
	var gained := int(experience.get(worker_id, 0))
	if gained > 0:
		person["efficiency"] = mini(10, int(person["efficiency"]) + gained)
	return person


func export_state() -> Dictionary:
	var ids: Array = []
	for worker_id in hired:
		ids.append(worker_id)
	var gained := {}
	for key in experience.keys():
		if int(experience[key]) > 0:
			gained[str(key)] = int(experience[key])
	return {
		"hired": ids,
		"workshop": workshop_worker_id,
		"packing": packing_worker_id,
		"experience": gained,
		"wage_progress": wage_progress,
	}


func import_state(data: Dictionary) -> void:
	hired.clear()
	var raw: Array = data.get("hired", [])
	for item in raw:
		hired.append(str(item))
	workshop_worker_id = str(data.get("workshop", ""))
	packing_worker_id = str(data.get("packing", ""))
	wage_progress = int(data.get("wage_progress", 0))
	experience = {}
	var raw_xp: Dictionary = data.get("experience", {})
	for key in raw_xp.keys():
		experience[str(key)] = int(raw_xp[key])
