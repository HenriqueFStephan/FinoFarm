class_name RegionCatalog
extends RefCounted

## Fictional starting regions. Numbers are untuned gameplay tuning.
## There is no latitude, soil, statute, or cultivation data in this table.

const PURSE := 500

const _FORBIDDEN_KEYS := [
	"latitude", "longitude", "soil", "statute", "dosage", "thc", "cultivation",
]


static func ids() -> PackedStringArray:
	var found := PackedStringArray()
	for entry in _rows():
		found.append(str(entry["id"]))
	return found


static func all() -> Array:
	var found: Array = []
	for region_id in ids():
		found.append(get_region(region_id))
	return found


static func get_region(region_id: String) -> Dictionary:
	for entry in _rows():
		if str(entry["id"]) == region_id:
			var copy: Dictionary = (entry as Dictionary).duplicate(true)
			copy["starting_funds"] = starting_funds(int(copy["property_cost"]))
			return copy
	return {}


static func starting_funds(property_cost: int) -> int:
	return maxi(0, PURSE - property_cost)


static func difficulty_label(value: float) -> String:
	if value < 0.4:
		return "low"
	if value < 0.65:
		return "medium"
	return "high"


static func forbidden_key_present() -> String:
	for entry in _rows():
		for key in (entry as Dictionary).keys():
			if str(key) in _FORBIDDEN_KEYS:
				return str(key)
	return ""


static func _rows() -> Array:
	return [
		{
			"id": "northern_homestead",
			"display_name": "Northern Homestead",
			"climate_label": "Cooler seasons",
			"season_amplitude": 0.9,
			"property_cost": 180,
			"upkeep_modifier": 1.25,
			"infrastructure_difficulty": 0.72,
			"opportunity": "Indoor workshops stay busy through the long cool season.",
			"challenge": "Heated buildings cost more fictional upkeep.",
			"map_x": 0.22,
			"map_y": 0.18,
		},
		{
			"id": "tropical_valley",
			"display_name": "Tropical Valley",
			"climate_label": "Vibrant and changeable",
			"season_amplitude": 0.55,
			"property_cost": 140,
			"upkeep_modifier": 1.0,
			"infrastructure_difficulty": 0.4,
			"opportunity": "Short seasons open more event contracts.",
			"challenge": "Weather swings delay outdoor staging.",
			"map_x": 0.70,
			"map_y": 0.66,
		},
		{
			"id": "innovation_plains",
			"display_name": "Innovation Plains",
			"climate_label": "Mild compact land",
			"season_amplitude": 0.35,
			"property_cost": 260,
			"upkeep_modifier": 1.4,
			"infrastructure_difficulty": 0.84,
			"opportunity": "Research rooms unlock sooner.",
			"challenge": "Plots are expensive and infrastructure costs more.",
			"map_x": 0.24,
			"map_y": 0.70,
		},
		{
			"id": "golden_fields",
			"display_name": "Golden Fields",
			"climate_label": "Dry golden seasons",
			"season_amplitude": 0.62,
			"property_cost": 200,
			"upkeep_modifier": 1.1,
			"infrastructure_difficulty": 0.5,
			"opportunity": "Premium contracts pay more for select grades.",
			"challenge": "Dry seasons raise utility upkeep in the game economy.",
			"map_x": 0.68,
			"map_y": 0.22,
		},
	]
