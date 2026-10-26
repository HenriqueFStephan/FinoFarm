class_name SaveGame
extends RefCounted

## Schema 1 save for one farm. Callers persist it through FarmLibrary.
## Unknown schema versions are rejected and do not return a partial game.

const SCHEMA := 1

var schema := SCHEMA
var farm_id := ""
var farm_name := ""
var region_id := ""
var funds := 0
var level := 1
var playtime_seconds := 0.0
var last_saved_unix := 0
var inventory: Dictionary = {}
var workshop: Dictionary = {
	"recipe_id": "",
	"ticks_remaining": 0,
	"locked_grade": 0,
}
var camera: Dictionary = {
	"focus": [0.0, 1.2, 0.0],
	"yaw": 0.9,
	"pitch": 0.58,
	"distance": 15.0,
}
var tutorial_step := 0
var marker: Dictionary = {}
var plot: Dictionary = {
	"planted": false,
	"resource_id": "verdant_fiber",
	"stage": 0,
	"ticks_remaining": 0,
	"grade": 1,
}
var orders: Dictionary = {"intro_bundle": "open"}
var upgrades: Dictionary = {}


static func create_new(farm_name: String, region_id: String) -> Dictionary:
	var cleaned := farm_name.strip_edges()
	if cleaned == "":
		return _fail("name_required")
	if cleaned.length() > 32:
		return _fail("name_too_long")
	var region := RegionCatalog.get_region(region_id)
	if region.is_empty():
		return _fail("unknown_region")
	var game := SaveGame.new()
	game.farm_id = "farm_%d_%d" % [Time.get_ticks_usec(), randi() % 100000]
	game.farm_name = cleaned
	game.region_id = region_id
	game.funds = int(region["starting_funds"])
	game.level = 1
	game.playtime_seconds = 0.0
	game.last_saved_unix = int(Time.get_unix_time_from_system())
	game.tutorial_step = 0
	var stacks := FarmInventory.new()
	# Starter stack so a new file has a real inventory snapshot. Not a grow recipe.
	stacks.add("verdant_fiber", 4, GradeScale.COMMON)
	game.inventory = stacks.snapshot()
	return {"ok": true, "error": "", "game": game}


func to_dict() -> Dictionary:
	return {
		"schema": schema,
		"farm_id": farm_id,
		"farm_name": farm_name,
		"region_id": region_id,
		"funds": funds,
		"level": level,
		"playtime_seconds": playtime_seconds,
		"last_saved_unix": last_saved_unix,
		"inventory": inventory.duplicate(true),
		"workshop": workshop.duplicate(true),
		"camera": camera.duplicate(true),
		"tutorial_step": tutorial_step,
		"marker": marker.duplicate(true),
		"plot": plot.duplicate(true),
		"orders": orders.duplicate(true),
		"upgrades": upgrades.duplicate(true),
	}


static func from_dict(data: Dictionary) -> Dictionary:
	if not data.has("schema"):
		return _fail("missing_schema")
	var schema_value: Variant = data["schema"]
	if typeof(schema_value) != TYPE_INT and typeof(schema_value) != TYPE_FLOAT:
		return _fail("unsupported_schema")
	if float(schema_value) != float(SCHEMA):
		return _fail("unsupported_schema")
	for field in ["farm_id", "farm_name", "region_id", "funds"]:
		if not data.has(field):
			return _fail("missing_field")
	var region := RegionCatalog.get_region(str(data["region_id"]))
	if region.is_empty():
		return _fail("unknown_region")
	var inventory_value: Variant = data.get("inventory", {})
	if typeof(inventory_value) != TYPE_DICTIONARY:
		return _fail("bad_inventory")
	var stacks := FarmInventory.new()
	if not stacks.apply_snapshot(inventory_value):
		return _fail("bad_inventory")
	var camera_value := _camera_from(data.get("camera", {}))
	if camera_value.is_empty():
		return _fail("bad_camera")
	var workshop_value := _workshop_from(data.get("workshop", {}))
	if workshop_value.is_empty():
		return _fail("bad_workshop")
	var marker_value: Variant = _marker_from(data.get("marker", {}))
	if marker_value == null:
		return _fail("bad_marker")
	var plot_value: Variant = _plot_from(data.get("plot", {}))
	if plot_value == null:
		return _fail("bad_plot")
	var orders_value: Variant = _orders_from(data.get("orders", {}))
	if orders_value == null:
		return _fail("bad_orders")
	var upgrades_value: Variant = _upgrades_from(data.get("upgrades", {}))
	if upgrades_value == null:
		return _fail("bad_upgrades")
	var game := SaveGame.new()
	game.schema = SCHEMA
	game.farm_id = str(data["farm_id"])
	game.farm_name = str(data["farm_name"])
	game.region_id = str(data["region_id"])
	game.funds = int(data["funds"])
	game.level = int(data.get("level", 1))
	game.playtime_seconds = float(data.get("playtime_seconds", 0.0))
	game.last_saved_unix = int(data.get("last_saved_unix", 0))
	game.inventory = stacks.snapshot()
	game.workshop = workshop_value
	game.camera = camera_value
	game.tutorial_step = int(data.get("tutorial_step", 0))
	game.marker = (marker_value as Dictionary).duplicate(true)
	game.plot = (plot_value as Dictionary).duplicate(true)
	game.orders = (orders_value as Dictionary).duplicate(true)
	game.upgrades = (upgrades_value as Dictionary).duplicate(true)
	return {"ok": true, "error": "", "game": game}


func summary() -> Dictionary:
	var region := RegionCatalog.get_region(region_id)
	var region_name := region_id
	if not region.is_empty():
		region_name = str(region["display_name"])
	return {
		"farm_id": farm_id,
		"farm_name": farm_name,
		"region_id": region_id,
		"region_name": region_name,
		"level": level,
		"funds": funds,
		"playtime_seconds": playtime_seconds,
		"last_saved_unix": last_saved_unix,
	}


static func card_text(row: Dictionary) -> String:
	return "%s\n%s  ·  Level %d\nFunds %d  ·  %s\nSaved %s" % [
		str(row["farm_name"]),
		str(row["region_name"]),
		int(row["level"]),
		int(row["funds"]),
		format_playtime(float(row["playtime_seconds"])),
		format_saved_at(int(row["last_saved_unix"])),
	]


static func format_playtime(seconds: float) -> String:
	var total := maxi(0, int(seconds))
	var hours := int(total / 3600.0)
	var minutes := int(total % 3600 / 60.0)
	var secs := total % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	return "%dm %02ds" % [minutes, secs]


static func format_saved_at(unix_time: int) -> String:
	if unix_time <= 0:
		return "not saved"
	var stamp := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%04d-%02d-%02d %02d:%02d UTC" % [
		int(stamp["year"]),
		int(stamp["month"]),
		int(stamp["day"]),
		int(stamp["hour"]),
		int(stamp["minute"]),
	]


func write_inventory_from(stacks: FarmInventory) -> void:
	inventory = stacks.snapshot()


func read_inventory_into(stacks: FarmInventory) -> bool:
	return stacks.apply_snapshot(inventory)


func write_workshop_from(shop: Workshop) -> void:
	workshop = shop.export_job()


func read_workshop_into(shop: Workshop) -> void:
	shop.import_job(workshop)


static func _camera_from(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var raw: Dictionary = value
	if raw.is_empty():
		return {
			"focus": [0.0, 1.2, 0.0],
			"yaw": 0.9,
			"pitch": 0.58,
			"distance": 15.0,
		}
	var focus: Variant = raw.get("focus", null)
	if typeof(focus) != TYPE_ARRAY or (focus as Array).size() != 3:
		return {}
	var focus_array: Array = focus
	return {
		"focus": [float(focus_array[0]), float(focus_array[1]), float(focus_array[2])],
		"yaw": float(raw.get("yaw", 0.9)),
		"pitch": float(raw.get("pitch", 0.58)),
		"distance": float(raw.get("distance", 15.0)),
	}


static func _workshop_from(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var raw: Dictionary = value
	return {
		"recipe_id": str(raw.get("recipe_id", "")),
		"ticks_remaining": int(raw.get("ticks_remaining", 0)),
		"locked_grade": int(raw.get("locked_grade", 0)),
	}


static func _marker_from(value: Variant) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		return null
	var raw: Dictionary = value
	if raw.is_empty():
		return {}
	if not raw.has("x") or not raw.has("z"):
		return null
	return {"x": int(raw["x"]), "z": int(raw["z"])}


static func _default_plot() -> Dictionary:
	return {
		"planted": false,
		"resource_id": "verdant_fiber",
		"stage": 0,
		"ticks_remaining": 0,
		"grade": GradeScale.COMMON,
	}


static func _plot_from(value: Variant) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		return null
	var raw: Dictionary = value
	if raw.is_empty():
		return _default_plot()
	var resource_id := str(raw.get("resource_id", "verdant_fiber"))
	var spec := ResourceCatalog.growth(resource_id)
	if spec.is_empty():
		return null
	var stage := int(raw.get("stage", 0))
	var ticks := int(raw.get("ticks_remaining", 0))
	var grade := int(raw.get("grade", GradeScale.COMMON))
	if stage < 0 or stage >= int(spec["stage_count"]) or ticks < 0:
		return null
	if not GradeScale.is_valid(grade):
		return null
	return {
		"planted": bool(raw.get("planted", false)),
		"resource_id": resource_id,
		"stage": stage,
		"ticks_remaining": ticks,
		"grade": grade,
	}


static func _orders_from(value: Variant) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		return null
	var raw: Dictionary = value
	if raw.is_empty():
		return {"intro_bundle": "open"}
	var cleaned := {}
	for key in raw.keys():
		var order_id := str(key)
		if ResourceCatalog.order(order_id).is_empty():
			return null
		var state := str(raw[key])
		if state != "open" and state != "done":
			return null
		cleaned[order_id] = state
	if not cleaned.has("intro_bundle"):
		cleaned["intro_bundle"] = "open"
	return cleaned


static func _upgrades_from(value: Variant) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		return null
	var raw: Dictionary = value
	var cleaned := {}
	for key in raw.keys():
		var upgrade_id := str(key)
		if ResourceCatalog.upgrade(upgrade_id).is_empty():
			return null
		if typeof(raw[key]) != TYPE_BOOL:
			return null
		if bool(raw[key]):
			cleaned[upgrade_id] = true
	return cleaned


static func _fail(reason: String) -> Dictionary:
	return {"ok": false, "error": reason, "game": null}
