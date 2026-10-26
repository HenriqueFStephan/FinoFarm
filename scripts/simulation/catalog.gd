class_name ResourceCatalog
extends RefCounted

## Fictional textile-chain data. Timers, grades, and recipe ratios only.
## This is not a cultivation, extraction, or dosage model.

static func resources() -> Dictionary:
	return {
		"verdant_fiber": {"label": "Verdant Fiber", "category": "raw"},
		"seal_wax": {"label": "Seal Wax", "category": "input"},
		"fiber_bundle": {"label": "Fiber Bundle", "category": "intermediate"},
		"packed_textile": {"label": "Packed Textile", "category": "good"},
	}


static func recipes() -> Array:
	var found: Array = []
	for recipe_id in ["bundle_fiber", "pack_textile"]:
		found.append(recipe(recipe_id))
	return found


static func recipe(recipe_id: String) -> Dictionary:
	for entry in _definitions():
		if str(entry["id"]) == recipe_id:
			return (entry as Dictionary).duplicate(true)
	return {}


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
