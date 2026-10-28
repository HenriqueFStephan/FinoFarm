extends SceneTree

## Supply chain, research fork, wages, and one experience gain. No 3D scene.


var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("research_branches_are_independent", _branches)
	_check("wrap_uses_the_workshop_output", _wrap)
	_check("one_harvest_cannot_skip_the_bench", _chain)
	_check("wages_charge_on_an_interval", _wages)
	_check("one_experience_gain_raises_efficiency", _experience)
	_check("regions_list_play_style_and_economy", _regions)
	_check("old_save_omits_the_packing_bench", _old_save)
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


func _branches() -> String:
	var loom := ResourceCatalog.research("loom_rule")
	var pack := ResourceCatalog.research("pack_line")
	if int(loom["cost"]) != 120 or int(pack["cost"]) != 100:
		return "costs"
	if str(loom["branch"]) == str(pack["branch"]):
		return "same branch"
	var created: Dictionary = SaveGame.create_new("Fork Farm", "tropical_valley")
	var game: SaveGame = created["game"]
	var lesson := FarmLoop.new()
	lesson.read_from(game)
	var funds := game.funds
	if lesson.buy_pack_line(game) != "tutorial" or game.funds != funds or lesson.research.owns("pack_line"):
		return "lesson"
	lesson.tutorial.step = TutorialTrack.DONE
	game.funds = 99
	if lesson.buy_pack_line(game) != "short_funds" or game.funds != 99 or lesson.research.owns("pack_line"):
		return "short"
	game.funds = 100
	if lesson.buy_pack_line(game) != "" or game.funds != 0 or not lesson.research.owns("pack_line"):
		return "buy"
	if lesson.research.owns("loom_rule"):
		return "packing bought the loom"
	if lesson.buy_pack_line(game) != "already_owned" or game.funds != 0:
		return "twice"
	game.funds = 120
	if lesson.buy_loom_rule(game) != "" or not lesson.research.owns("loom_rule") or not lesson.research.owns("pack_line"):
		return "both"
	if lesson.set_loom_priority("wrap_bundle") == "":
		return "wrap became a loom priority"
	return ""


func _wrap() -> String:
	var recipe := ResourceCatalog.recipe("wrap_bundle")
	if str(recipe["output_id"]) != "packed_textile":
		return "output"
	var inputs: Array = recipe["inputs"]
	if inputs.size() != 1 or str(inputs[0]["id"]) != "fiber_bundle" or int(inputs[0]["amount"]) != 1:
		return "input"
	var loop := _ready_loop()
	if loop.inventory.add("fiber_bundle", 1, GradeScale.COMMON) != true:
		return "seed"
	if loop.start_wrap() != "locked":
		return "locked"
	if loop.packer.is_busy() or loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "consumed while locked"
	var game := _purse(loop)
	game.funds = 100
	if loop.buy_pack_line(game) != "":
		return "unlock"
	if loop.start_wrap() != "":
		return "start"
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle left"
	if loop.workshop.is_busy():
		return "loom started"
	loop.advance(2.0)
	if loop.inventory.amount("packed_textile", GradeScale.COMMON) != 0 or not loop.packer.is_busy():
		return "early"
	loop.advance(1.0)
	if loop.inventory.amount("packed_textile", GradeScale.COMMON) != 1 or loop.packer.is_busy():
		return "finish"
	if loop.fulfill_packed(game) != "" or game.funds != 220:
		return "pay %d" % game.funds
	if loop.fulfill_packed(game) != "already_done" or game.funds != 220:
		return "twice"
	return ""


func _chain() -> String:
	var loop := _ready_loop()
	if not loop.inventory.remove("verdant_fiber", GradeScale.COMMON, 2):
		return "trim"
	if loop.start_bundle() != "":
		return "bundle"
	loop.advance(float(loop.workshop.ticks_remaining))
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "workshop output"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "fiber left"
	if loop.start_cord() != "missing_inputs":
		return "cord"
	var game := _purse(loop)
	game.funds = 100
	if loop.buy_pack_line(game) != "" or loop.start_wrap() != "":
		return "wrap"
	loop.advance(float(loop.packer.ticks_remaining))
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle remained"
	if loop.inventory.amount("packed_textile", GradeScale.COMMON) != 1:
		return "textile"
	var funds := game.funds
	if loop.fulfill_intro(game) != "missing_goods" or game.funds != funds:
		return "intro paid from a wrap"
	if loop.fulfill_packed(game) != "":
		return "crate"
	return ""


func _wages() -> String:
	var created: Dictionary = SaveGame.create_new("Wage Clock", "tropical_valley")
	var game: SaveGame = created["game"]
	var funds := game.funds
	var loop := FarmLoop.new()
	loop.read_from(game)
	if loop.hire_worker("alex_morgan") != "" or game.funds != funds:
		return "hire charged"
	loop.tutorial.step = TutorialTrack.DONE
	if loop.charge_wages(game, StaffRoster.WAGE_INTERVAL - 1) != 0 or game.funds != funds:
		return "early charge"
	var wage := int(StaffCatalog.worker("alex_morgan")["wage"])
	if loop.charge_wages(game, 1) != wage or game.funds != funds - wage:
		return "interval %d" % game.funds
	if loop.hire_worker("bram_holt") != "" or game.funds != funds - wage:
		return "second hire"
	var both := wage + int(StaffCatalog.worker("bram_holt")["wage"])
	if loop.charge_wages(game, StaffRoster.WAGE_INTERVAL) != both:
		return "both"
	var lesson := FarmLoop.new()
	lesson.read_from(SaveGame.create_new("Lesson Wages", "golden_fields")["game"])
	var quiet: SaveGame = SaveGame.create_new("Lesson Purse", "golden_fields")["game"]
	lesson.hire_worker("alex_morgan")
	var before := quiet.funds
	if lesson.charge_wages(quiet, 40) != 0 or quiet.funds != before:
		return "lesson charged"
	return ""


func _experience() -> String:
	var loop := _ready_loop()
	if loop.hire_worker("bram_holt") != "" or loop.assign_workshop("bram_holt") != "":
		return "assign"
	var before := int(loop.roster.assigned_worker()["efficiency"])
	if before != 3:
		return "base %d" % before
	if loop.start_bundle() != "":
		return "start"
	var ticks := loop.workshop.ticks_remaining
	if ticks < 2:
		return "pace %d" % ticks
	loop.advance(float(ticks - 1))
	if int(loop.roster.assigned_worker()["efficiency"]) != before:
		return "early xp"
	if loop.workshop.ticks_remaining != 1:
		return "ticks moved"
	loop.advance(1.0)
	var person := loop.roster.assigned_worker()
	if int(person["efficiency"]) != before + 1:
		return "efficiency %d" % int(person["efficiency"])
	if int(loop.roster.experience.get("bram_holt", 0)) != 1:
		return "xp"
	if StaffCatalog.worker("bram_holt")["efficiency"] != 3:
		return "catalog changed"
	loop.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	var faster := WorkerPace.bundle_ticks(person)
	if loop.start_bundle() != "":
		return "second"
	if loop.workshop.ticks_remaining != faster or faster >= ticks:
		return "next ticks %d vs %d" % [loop.workshop.ticks_remaining, ticks]
	loop.advance(float(faster))
	if int(loop.roster.experience.get("bram_holt", 0)) != 1:
		return "second gain"
	return ""


func _regions() -> String:
	var styles := {}
	for region_id in RegionCatalog.ids():
		var region := RegionCatalog.get_region(region_id)
		if str(region.get("play_style", "")) == "" or str(region.get("economy_profile", "")) == "":
			return "missing %s" % region_id
		styles[str(region["play_style"])] = true
		var text := RegionCatalog.detail_text(region)
		for piece in ["Play style", "Economy", str(region["opportunity"]), str(region["challenge"])]:
			if not text.contains(piece):
				return "detail %s" % region_id
	if styles.size() != 4:
		return "styles overlap"
	return ""


func _old_save() -> String:
	var created: Dictionary = SaveGame.create_new("Legacy Bench", "northern_homestead")
	var data := (created["game"] as SaveGame).to_dict()
	data.erase("packer")
	var staff: Dictionary = data["staff"]
	staff.erase("packing")
	staff.erase("experience")
	staff.erase("wage_progress")
	data["staff"] = staff
	var loaded: Dictionary = SaveGame.from_dict(data)
	if not loaded["ok"]:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1 or str(copy.packer.get("recipe_id", "x")) != "":
		return "packer"
	var loop := FarmLoop.new()
	if loop.read_from(copy) != "" or loop.packer.is_busy() or loop.research.owns("pack_line"):
		return "read"
	data = (created["game"] as SaveGame).to_dict()
	data["staff"] = {"hired": ["alex_morgan"], "workshop": "", "packing": "bram_holt"}
	if SaveGame.from_dict(data)["ok"]:
		return "packing without hire"
	return ""


func _ready_loop() -> FarmLoop:
	var created: Dictionary = SaveGame.create_new("Bench Test", "innovation_plains")
	var loop := FarmLoop.new()
	loop.read_from(created["game"])
	loop.tutorial.step = TutorialTrack.DONE
	return loop


func _purse(loop: FarmLoop) -> SaveGame:
	var game: SaveGame = SaveGame.create_new("Purse", "tropical_valley")["game"]
	loop.write_to(game)
	return game
