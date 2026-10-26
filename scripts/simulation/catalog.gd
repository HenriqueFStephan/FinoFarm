class_name ResourceCatalog
extends RefCounted

## Fictional textile-chain data. Timers, grades, and recipe ratios only.
## This is not a cultivation, extraction, or dosage model.

static func resources() -> Dictionary:
	return {
		"verdant_fiber": {"label": "Verdant Fiber", "category": "raw"},
		"seal_wax": {"label": "Seal Wax", "category": "input"},
		"fiber_bundle": {"label": "Fiber Bundle", "category": "intermediate"},
		"fiber_cord": {"label": "Fiber Cord", "category": "intermediate"},
		"packed_textile": {"label": "Packed Textile", "category": "good"},
	}


static func recipes() -> Array:
	var found: Array = []
	for recipe_id in ["bundle_fiber", "twist_cord", "pack_textile"]:
		found.append(recipe(recipe_id))
	return found


static func recipe(recipe_id: String) -> Dictionary:
	for entry in _definitions():
		if str(entry["id"]) == recipe_id:
			return (entry as Dictionary).duplicate(true)
	return {}


## Visual stages and a tick timer for one fictional raw good.
## Grade is assigned by this table. It is not a cultivation result.
static func growth(resource_id: String) -> Dictionary:
	if resource_id != "verdant_fiber":
		return {}
	return {
		"id": "verdant_fiber",
		"stage_count": 4,
		"ticks_per_stage": 2,
		"yield_amount": 2,
		"grade": GradeScale.COMMON,
	}


static func stage_label(stage: int) -> String:
	match stage:
		0:
			return "row"
		1:
			return "sprout"
		2:
			return "leaf"
		3:
			return "ready"
		_:
			return "empty"


static func orders() -> Array:
	var found: Array = []
	for entry in _orders():
		found.append((entry as Dictionary).duplicate(true))
	return found


static func order(order_id: String) -> Dictionary:
	for entry in _orders():
		if str(entry["id"]) == order_id:
			return (entry as Dictionary).duplicate(true)
	return {}


static func upgrade(upgrade_id: String) -> Dictionary:
	for entry in _upgrades():
		if str(entry["id"]) == upgrade_id:
			return (entry as Dictionary).duplicate(true)
	return {}


static func _orders() -> Array:
	return [
		{
			"id": "intro_bundle",
			"label": "Trail stall bundle",
			"detail": "The valley stall wants one Fiber Bundle.",
			"requires": [{"id": "fiber_bundle", "amount": 1}],
			"reward_funds": 180,
		},
		{
			"id": "lane_cord",
			"label": "Lane counter cord",
			"detail": "The lane counter pays a different price for one Fiber Cord.",
			"requires": [{"id": "fiber_cord", "amount": 1}],
			"reward_funds": 240,
		},
	]


static func _upgrades() -> Array:
	return [
		{
			"id": "barn_loft",
			"label": "Barn loft",
			"detail": "Adds a storage loft on the barn.",
			"cost": 400,
		},
		{
			"id": "shuttle_rack",
			"label": "Shuttle rack",
			"detail": "A second shuttle on the loom. The next job finishes one tick sooner.",
			"cost": 160,
			"speed_ticks": 1,
		},
	]


static func _definitions() -> Array:
	return [
		{
			"id": "bundle_fiber",
			"inputs": [{"id": "verdant_fiber", "amount": 2}],
			"output_id": "fiber_bundle",
			"output_amount": 1,
			"duration_ticks": 4,
		},
		{
			"id": "twist_cord",
			"inputs": [{"id": "verdant_fiber", "amount": 2}],
			"output_id": "fiber_cord",
			"output_amount": 1,
			"duration_ticks": 5,
		},
		{
			"id": "pack_textile",
			"inputs": [
				{"id": "fiber_bundle", "amount": 1},
				{"id": "seal_wax", "amount": 1},
			],
			"output_id": "packed_textile",
			"output_amount": 1,
			"duration_ticks": 3,
		},
	]
