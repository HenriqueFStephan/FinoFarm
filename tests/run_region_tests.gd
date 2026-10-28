extends SceneTree

## Region catalog checks. Must not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("four_regions_and_labels", _four_regions)
	_check("costs_and_starting_funds", _costs)
	_check("unknown_region_is_empty", _unknown)
	_check("no_real_world_fields", _no_real_world)
	_check("difficulty_bands", _difficulty)
	print("%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _check(test_name: String, body: Callable) -> void:
	var reason: String = body.call()
	if reason == "":
		_passed += 1
		print("ok %s" % test_name)
	else:
		_failed += 1
		print("not ok %s — %s" % [test_name, reason])


func _four_regions() -> String:
	var expected := {
		"northern_homestead": "Northern Homestead",
		"tropical_valley": "Tropical Valley",
		"innovation_plains": "Innovation Plains",
		"golden_fields": "Golden Fields",
	}
	if RegionCatalog.ids().size() != 4:
		return "expected 4 ids"
	for region_id in expected.keys():
		var region := RegionCatalog.get_region(region_id)
		if region.is_empty():
			return "missing %s" % region_id
		if str(region["display_name"]) != str(expected[region_id]):
			return "label %s" % region_id
		for field in [
			"climate_label",
			"season_amplitude",
			"property_cost",
			"upkeep_modifier",
			"infrastructure_difficulty",
			"opportunity",
			"challenge",
			"starting_funds",
			"map_x",
			"map_y",
			"economy_profile",
			"play_style",
		]:
			if not region.has(field):
				return "missing field %s" % field
		if str(region["opportunity"]) == "" or str(region["challenge"]) == "":
			return "empty copy %s" % region_id
	return ""


func _costs() -> String:
	var seen_funds := {}
	for region_id in RegionCatalog.ids():
		var region := RegionCatalog.get_region(region_id)
		var cost := int(region["property_cost"])
		var funds := int(region["starting_funds"])
		if cost <= 0:
			return "cost"
		if funds != RegionCatalog.starting_funds(cost):
			return "funds formula"
		if funds != RegionCatalog.PURSE - cost:
			return "purse"
		seen_funds[funds] = true
		if float(region["season_amplitude"]) <= 0.0:
			return "amplitude"
		if float(region["upkeep_modifier"]) <= 0.0:
			return "upkeep"
	if seen_funds.size() < 4:
		return "starting funds should differ"
	return ""


func _unknown() -> String:
	if not RegionCatalog.get_region("real_country").is_empty():
		return "unknown id returned data"
	return ""


func _no_real_world() -> String:
	var found := RegionCatalog.forbidden_key_present()
	if found != "":
		return found
	return ""


func _difficulty() -> String:
	if RegionCatalog.difficulty_label(0.2) != "low":
		return "low"
	if RegionCatalog.difficulty_label(0.5) != "medium":
		return "medium"
	if RegionCatalog.difficulty_label(0.84) != "high":
		return "high"
	return ""
