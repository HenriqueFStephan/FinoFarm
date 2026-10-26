class_name ResearchBoard
extends RefCounted

## One paid unlock and the loom priority it stores. This is not a production method.

var owned := {}
var priority := ""


func owns(research_id: String) -> bool:
	return bool(owned.get(research_id, false))


func try_purchase(research_id: String, funds: int) -> Dictionary:
	var spec := ResourceCatalog.research(research_id)
	if spec.is_empty():
		return {"error": "unknown_research", "funds": funds}
	if owns(research_id):
		return {"error": "already_owned", "funds": funds}
	var cost := int(spec["cost"])
	if funds < cost:
		return {"error": "short_funds", "funds": funds}
	owned[research_id] = true
	return {"error": "", "funds": funds - cost}


func set_priority(recipe_id: String) -> String:
	if not owns("loom_rule"):
		return "locked"
	if not ResourceCatalog.is_loom_priority(recipe_id):
		return "unknown_priority"
	priority = recipe_id
	return ""


func export_state() -> Dictionary:
	var copy := {"priority": priority}
	for key in owned.keys():
		if bool(owned[key]):
			copy[str(key)] = true
	return copy


func import_state(data: Dictionary) -> void:
	owned = {}
	priority = str(data.get("priority", ""))
	for key in data.keys():
		var research_id := str(key)
		if research_id == "priority":
			continue
		if bool(data[key]):
			owned[research_id] = true
