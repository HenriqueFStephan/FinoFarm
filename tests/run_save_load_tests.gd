extends SceneTree

## Save schema checks. Must not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("round_trip_dict", _round_trip)
	_check("schema_rejects_missing_zero_and_future", _schema_errors)
	_check("two_farms_do_not_mix", _two_farms)
	_check("reopen_library_keeps_active_farm", _reopen)
	_check("workshop_job_survives_the_file", _workshop_job)
	_check("card_text_lists_the_save_fields", _card_text)
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


func _round_trip() -> String:
	var created: Dictionary = SaveGame.create_new("North Plot", "northern_homestead")
	if not created["ok"]:
		return str(created["error"])
	var game: SaveGame = created["game"]
	game.funds = 40
	game.level = 1
	game.playtime_seconds = 12.5
	game.tutorial_step = 3
	game.camera = {"focus": [1.0, 1.2, -2.0], "yaw": 0.4, "pitch": 0.7, "distance": 18.0}
	game.marker = {"x": 3, "z": -2}
	game.inventory = {"verdant_fiber#1": 2, "seal_wax#2": 1}
	var loaded: Dictionary = SaveGame.from_dict(game.to_dict())
	if not loaded["ok"] or loaded["game"] == null:
		return "load %s" % str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1 or copy.farm_name != "North Plot":
		return "identity"
	if copy.region_id != "northern_homestead" or copy.funds != 40:
		return "funds"
	if copy.level != 1 or copy.tutorial_step != 3:
		return "level"
	if absf(copy.playtime_seconds - 12.5) > 0.001:
		return "playtime"
	if int(copy.inventory.get("verdant_fiber#1", 0)) != 2:
		return "inventory"
	if int(copy.inventory.get("seal_wax#2", 0)) != 1:
		return "wax"
	if absf(float(copy.camera["yaw"]) - 0.4) > 0.001:
		return "camera"
	if int(copy.marker.get("x", 0)) != 3 or int(copy.marker.get("z", 0)) != -2:
		return "marker"
	var stacks := FarmInventory.new()
	if not copy.read_inventory_into(stacks):
		return "restore"
	if stacks.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "restored amount"
	return ""


func _schema_errors() -> String:
	var future := {"schema": 2, "funds": 99, "farm_name": "Nope", "farm_id": "x", "region_id": "tropical_valley"}
	var loaded: Dictionary = SaveGame.from_dict(future)
	if loaded["ok"] or loaded["game"] != null:
		return "schema 2 applied data"
	if str(loaded["error"]) != "unsupported_schema":
		return "schema 2 error"
	var zero: Dictionary = SaveGame.from_dict({"schema": 0, "funds": 5})
	if zero["ok"] or zero["game"] != null:
		return "schema 0"
	var missing: Dictionary = SaveGame.from_dict({"funds": 5, "farm_name": "A"})
	if missing["ok"] or missing["game"] != null:
		return "missing schema"
	if str(missing["error"]) != "missing_schema":
		return "missing error"
	var unnamed: Dictionary = SaveGame.create_new("   ", "tropical_valley")
	if unnamed["ok"] or unnamed["game"] != null:
		return "blank name"
	return ""


func _two_farms() -> String:
	var library := _library()
	var north: SaveGame = SaveGame.create_new("North Plot", "northern_homestead")["game"]
	var gold: SaveGame = SaveGame.create_new("Gold Acre", "golden_fields")["game"]
	north.funds = 11
	north.playtime_seconds = 15.0
	north.inventory = {"verdant_fiber#1": 2}
	gold.funds = 77
	gold.playtime_seconds = 90.0
	gold.inventory = {"seal_wax#2": 5}
	if library.write(north) != "" or library.write(gold) != "":
		return "write"
	north.funds = 999
	gold.inventory = {"verdant_fiber#1": 8}
	var loaded_north: SaveGame = library.load_farm(north.farm_id)["game"]
	var loaded_gold: SaveGame = library.load_farm(gold.farm_id)["game"]
	if loaded_north == null or loaded_gold == null:
		return "reload"
	if loaded_north.funds != 11 or loaded_gold.funds != 77:
		return "funds mixed"
	if int(loaded_north.inventory.get("verdant_fiber#1", 0)) != 2:
		return "north inventory"
	if int(loaded_gold.inventory.get("seal_wax#2", 0)) != 5:
		return "gold inventory"
	if loaded_north.inventory.has("seal_wax#2") or loaded_gold.inventory.has("verdant_fiber#1"):
		return "stacks mixed"
	if loaded_north.region_id == loaded_gold.region_id:
		return "region mixed"
	if absf(loaded_north.playtime_seconds - 15.0) > 0.001:
		return "playtime mixed"
	if absf(loaded_gold.playtime_seconds - 90.0) > 0.001:
		return "gold playtime"
	if loaded_north.schema != 1 or loaded_gold.schema != 1:
		return "schema"
	library.wipe()
	return ""


func _reopen() -> String:
	var root := "user://finofarm-tests/reopen-%d" % Time.get_ticks_usec()
	var first := FarmLibrary.new()
	first.root_path = root
	var game: SaveGame = SaveGame.create_new("Second Wind", "innovation_plains")["game"]
	game.funds = 240
	if first.write(game) != "":
		return "write"
	var second := FarmLibrary.new()
	second.root_path = root
	if second.active_id() != game.farm_id:
		return "active id"
	var loaded: SaveGame = second.load_farm(second.active_id())["game"]
	if loaded.farm_name != "Second Wind" or loaded.funds != 240:
		return "reopen values"
	if loaded.region_id != "innovation_plains":
		return "region"
	second.wipe()
	return ""


func _workshop_job() -> String:
	var stacks := FarmInventory.new()
	stacks.add("verdant_fiber", 4, GradeScale.COMMON)
	var shop := Workshop.new(stacks)
	if shop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.COMMON}) != "":
		return "start"
	var game: SaveGame = SaveGame.create_new("Job Farm", "tropical_valley")["game"]
	game.write_inventory_from(stacks)
	game.write_workshop_from(shop)
	var loaded: Dictionary = SaveGame.from_dict(game.to_dict())
	if not loaded["ok"]:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	var stacks_again := FarmInventory.new()
	if not copy.read_inventory_into(stacks_again):
		return "inventory"
	var shop_again := Workshop.new(stacks_again)
	copy.read_workshop_into(shop_again)
	if shop_again.ticks_remaining != 4 or shop_again.active_recipe_id != "bundle_fiber":
		return "job fields"
	shop_again.tick(4)
	if stacks_again.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	if stacks_again.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "inputs"
	return ""


func _card_text() -> String:
	var game: SaveGame = SaveGame.create_new("Card Farm", "golden_fields")["game"]
	game.funds = 300
	game.level = 1
	game.playtime_seconds = 65
	game.last_saved_unix = 1700000000
	var text := SaveGame.card_text(game.summary())
	for piece in ["Card Farm", "Golden Fields", "Level 1", "Funds 300", "1m 05s", "UTC"]:
		if not text.contains(piece):
			return "card missing %s in %s" % [piece, text]
	return ""


func _library() -> FarmLibrary:
	var library := FarmLibrary.new()
	library.root_path = "user://finofarm-tests/pair-%d" % Time.get_ticks_usec()
	library.wipe()
	return library
