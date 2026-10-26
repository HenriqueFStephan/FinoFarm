class_name Workshop
extends RefCounted

var inventory: FarmInventory
var active_recipe_id := ""
var ticks_remaining := 0
var locked_grade := 0


func _init(starting_inventory: FarmInventory) -> void:
	inventory = starting_inventory


func try_start(recipe_id: String, grades_by_input: Dictionary) -> String:
	if active_recipe_id != "":
		return "busy"
	var recipe := ResourceCatalog.recipe(recipe_id)
	if recipe.is_empty():
		return "unknown_recipe"
	var grades: Array = []
	for input in recipe["inputs"]:
		var resource_id := str(input["id"])
		if not grades_by_input.has(resource_id):
			return "missing_grade"
		var grade := int(grades_by_input[resource_id])
		if not GradeScale.is_valid(grade):
			return "bad_grade"
		if inventory.amount(resource_id, grade) < int(input["amount"]):
			return "missing_inputs"
		grades.append(grade)
	for input in recipe["inputs"]:
		var resource_id := str(input["id"])
		var grade := int(grades_by_input[resource_id])
		if not inventory.remove(resource_id, grade, int(input["amount"])):
			return "missing_inputs"
	active_recipe_id = recipe_id
	ticks_remaining = int(recipe["duration_ticks"])
	locked_grade = GradeScale.minimum(grades)
	return ""


func tick(count: int = 1) -> Dictionary:
	if count <= 0 or active_recipe_id == "":
		return {}
	var produced := {}
	for _step in count:
		if active_recipe_id == "":
			break
		ticks_remaining -= 1
		if ticks_remaining > 0:
			continue
		var recipe := ResourceCatalog.recipe(active_recipe_id)
		inventory.add(str(recipe["output_id"]), int(recipe["output_amount"]), locked_grade)
		produced = {
			"recipe_id": active_recipe_id,
			"id": str(recipe["output_id"]),
			"amount": int(recipe["output_amount"]),
			"grade": locked_grade,
		}
		active_recipe_id = ""
		ticks_remaining = 0
		locked_grade = 0
	return produced


func is_busy() -> bool:
	return active_recipe_id != ""
