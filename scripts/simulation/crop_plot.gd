class_name CropPlot
extends RefCounted

## One fictional plot. Stages are visual labels advanced by a tick timer.
## Nothing here is a cultivation, extraction, or dosage rule.

var resource_id := "verdant_fiber"
var planted := false
var stage := 0
var ticks_remaining := 0
var grade := GradeScale.COMMON


func plant() -> String:
	if planted:
		return "already_planted"
	var spec := ResourceCatalog.growth(resource_id)
	if spec.is_empty():
		return "unknown_crop"
	planted = true
	stage = 0
	ticks_remaining = int(spec["ticks_per_stage"])
	grade = int(spec["grade"])
	return ""


func tick(count: int) -> String:
	if count <= 0 or not planted:
		return ""
	var spec := ResourceCatalog.growth(resource_id)
	var per := int(spec["ticks_per_stage"])
	var last := int(spec["stage_count"]) - 1
	var became := ""
	for _step in count:
		if stage >= last:
			ticks_remaining = 0
			break
		ticks_remaining -= 1
		if ticks_remaining > 0:
			continue
		stage += 1
		if stage >= last:
			stage = last
			ticks_remaining = 0
			became = "ready"
			break
		ticks_remaining = per
	return became


func is_ready() -> bool:
	if not planted:
		return false
	var spec := ResourceCatalog.growth(resource_id)
	return stage >= int(spec["stage_count"]) - 1


func harvest(inventory: FarmInventory) -> String:
	if not is_ready():
		return "not_ready"
	var spec := ResourceCatalog.growth(resource_id)
	var amount := int(spec["yield_amount"])
	if not inventory.add(resource_id, amount, grade):
		return "rejected"
	clear()
	return ""


func clear() -> void:
	planted = false
	stage = 0
	ticks_remaining = 0


func stage_name() -> String:
	if not planted:
		return "empty"
	return ResourceCatalog.stage_label(stage)


func export_state() -> Dictionary:
	return {
		"planted": planted,
		"resource_id": resource_id,
		"stage": stage,
		"ticks_remaining": ticks_remaining,
		"grade": grade,
	}


func import_state(data: Dictionary) -> void:
	planted = bool(data.get("planted", false))
	resource_id = str(data.get("resource_id", "verdant_fiber"))
	stage = int(data.get("stage", 0))
	ticks_remaining = int(data.get("ticks_remaining", 0))
	grade = int(data.get("grade", GradeScale.COMMON))
