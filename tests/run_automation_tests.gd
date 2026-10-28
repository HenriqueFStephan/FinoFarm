extends SceneTree

## Headless loom-rule checks. Does not instance a 3D scene.


var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("loom_rule_is_paid_in_currency", _paid)
	_check("priorities_start_different_recipes", _priorities)
	_check("running_job_is_not_replaced", _running)
	_check("locked_rule_stays_manual", _locked)
	_check("lesson_stays_manual", _lesson)
	_check("assignment_still_splits_auto_jobs", _assignment)
	_check("one_harvest_still_cannot_fill_both_orders", _one_harvest)
	_check("old_save_omits_the_loom_rule", _old_save)
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


func _paid() -> String:
	var spec := ResourceCatalog.research("loom_rule")
	if spec.is_empty() or int(spec["cost"]) != 120:
		return "cost"
	var created: Dictionary = SaveGame.create_new("Lesson", "tropical_valley")
	var game: SaveGame = created["game"]
	var lesson := FarmLoop.new()
	lesson.read_from(game)
	var funds := game.funds
	if lesson.buy_loom_rule(game) != "tutorial" or game.funds != funds or lesson.research.owns("loom_rule"):
		return "during lesson"
	if lesson.set_loom_priority("bundle_fiber") != "tutorial":
		return "priority during lesson"
	var loop := _done_loop()
	game.funds = 119
	if loop.buy_loom_rule(game) != "short_funds" or game.funds != 119 or loop.research.owns("loom_rule"):
		return "short"
	if loop.set_loom_priority("bundle_fiber") != "locked":
		return "priority while locked"
	game.funds = 120
	if loop.buy_loom_rule(game) != "" or game.funds != 0 or not loop.research.owns("loom_rule"):
		return "buy"
	if loop.buy_loom_rule(game) != "already_owned" or game.funds != 0:
		return "second"
	return ""


func _priorities() -> String:
	var bundle := _arm("alex_morgan")
	if bundle == null:
		return "bundle arm"
	if bundle.set_loom_priority("bundle_fiber") != "":
		return "bundle priority"
	if bundle.workshop.active_recipe_id != "bundle_fiber":
		return "bundle recipe %s" % bundle.workshop.active_recipe_id
	if bundle.workshop.ticks_remaining != 2:
		return "alex bundle ticks %d" % bundle.workshop.ticks_remaining
	if bundle.plot.is_ready() or bundle.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "bundle harvest left"
	var cord := _arm("alex_morgan")
	if cord == null:
		return "cord arm"
	if cord.set_loom_priority("twist_cord") != "":
		return "cord priority"
	if cord.workshop.active_recipe_id != "twist_cord":
		return "cord recipe %s" % cord.workshop.active_recipe_id
	if cord.workshop.ticks_remaining != 3:
		return "alex cord ticks %d" % cord.workshop.ticks_remaining
	if bundle.workshop.active_recipe_id == cord.workshop.active_recipe_id:
		return "same recipe"
	if cord.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "cord made a bundle"
	if bundle.inventory.amount("fiber_cord", GradeScale.COMMON) != 0:
		return "bundle made a cord"
	return ""


func _running() -> String:
	var loop := _done_loop()
	if loop.hire_worker("alex_morgan") != "" or loop.assign_workshop("alex_morgan") != "":
		return "crew"
	loop.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	if loop.start_bundle() != "" or loop.workshop.ticks_remaining != 2:
		return "start"
	if loop.workshop.active_recipe_id != "bundle_fiber":
		return "recipe"
	var game := _purse()
	game.funds = 120
	if loop.buy_loom_rule(game) != "":
		return "buy"
	if not _force_ready(loop):
		return "plot"
	if loop.set_loom_priority("twist_cord") != "":
		return "priority"
	if loop.workshop.active_recipe_id != "bundle_fiber" or loop.workshop.ticks_remaining != 2:
		return "replaced %s %d" % [loop.workshop.active_recipe_id, loop.workshop.ticks_remaining]
	if not loop.plot.is_ready():
		return "harvested a running job"
	if loop.apply_loom_rule() != "busy":
		return "second apply"
	if loop.workshop.ticks_remaining != 2 or loop.workshop.active_recipe_id != "bundle_fiber":
		return "second apply edited the job"
	loop.advance(1.0)
	if loop.workshop.active_recipe_id != "bundle_fiber" or loop.workshop.ticks_remaining != 1:
		return "early finish"
	if not loop.plot.is_ready():
		return "harvested early"
	loop.advance(1.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "bundle output"
	if loop.workshop.active_recipe_id != "twist_cord" or loop.workshop.ticks_remaining != 3:
		return "next %s %d" % [loop.workshop.active_recipe_id, loop.workshop.ticks_remaining]
	if loop.plot.is_ready() or loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "next harvest"
	return ""


func _locked() -> String:
	var loop := _done_loop()
	if loop.hire_worker("alex_morgan") != "" or loop.assign_workshop("alex_morgan") != "":
		return "crew"
	if loop.plot.plant() != "":
		return "plant"
	var spec := ResourceCatalog.growth("verdant_fiber")
	var ticks := (int(spec["stage_count"]) - 1) * int(spec["ticks_per_stage"])
	loop.advance(float(ticks))
	if not loop.plot.is_ready() or loop.workshop.is_busy():
		return "ready"
	if loop.apply_loom_rule() != "locked":
		return "unlocked"
	if not loop.plot.is_ready() or loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "locked mutated"
	if loop.harvest() != "" or loop.start_bundle() != "":
		return "manual"
	if loop.workshop.active_recipe_id != "bundle_fiber" or loop.workshop.ticks_remaining != 2:
		return "manual pace"
	var idle := _done_loop()
	var game := _purse()
	game.funds = 120
	if idle.buy_loom_rule(game) != "" or idle.set_loom_priority("bundle_fiber") != "":
		return "rule"
	if not _force_ready(idle):
		return "idle plot"
	if idle.apply_loom_rule() != "unassigned":
		return "unassigned"
	if not idle.plot.is_ready() or idle.workshop.is_busy():
		return "unassigned mutated"
	return ""


func _lesson() -> String:
	var loop := FarmLoop.new()
	loop.research.owned["loom_rule"] = true
	loop.research.priority = "bundle_fiber"
	if loop.hire_worker("alex_morgan") != "" or loop.assign_workshop("alex_morgan") != "":
		return "crew"
	if loop.plot.plant() != "":
		return "plant"
	loop.tutorial.step = TutorialTrack.GROW
	var spec := ResourceCatalog.growth("verdant_fiber")
	var ticks := (int(spec["stage_count"]) - 1) * int(spec["ticks_per_stage"])
	loop.advance(float(ticks - 1))
	if loop.plot.is_ready() or loop.workshop.is_busy():
		return "early"
	loop.advance(1.0)
	if not loop.plot.is_ready() or loop.workshop.is_busy():
		return "ready"
	if loop.tutorial.step != TutorialTrack.HARVEST:
		return "step %d" % loop.tutorial.step
	if loop.apply_loom_rule() != "tutorial":
		return "applied"
	if not loop.plot.is_ready() or loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "lesson mutated"
	if loop.harvest() != "" or loop.tutorial.step != TutorialTrack.WORKSHOP:
		return "harvest"
	if loop.start_bundle() != "":
		return "manual start"
	if loop.workshop.active_recipe_id != "bundle_fiber":
		return "manual recipe"
	var prompt := loop.tutorial.prompt()
	if not prompt.begins_with("Mara:"):
		return "mara"
	return ""


func _assignment() -> String:
	var alex := _arm("alex_morgan")
	var bram := _arm("bram_holt")
	if alex == null or bram == null:
		return "arm"
	if alex.set_loom_priority("bundle_fiber") != "" or bram.set_loom_priority("bundle_fiber") != "":
		return "priority"
	if alex.workshop.ticks_remaining != 2 or bram.workshop.ticks_remaining != 3:
		return "ticks %d %d" % [alex.workshop.ticks_remaining, bram.workshop.ticks_remaining]
	if alex.job_ticks("twist_cord") != 3 or bram.job_ticks("twist_cord") != 4:
		return "cord pace"
	var sooner := mini(alex.workshop.ticks_remaining, bram.workshop.ticks_remaining)
	alex.advance(float(sooner))
	bram.advance(float(sooner))
	if alex.inventory.snapshot() == bram.inventory.snapshot():
		return "same snapshot"
	if alex.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "alex output"
	if bram.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0 or not bram.workshop.is_busy():
		return "bram finished early"
	return ""


func _one_harvest() -> String:
	var bundle := _arm("alex_morgan")
	if bundle == null or bundle.set_loom_priority("bundle_fiber") != "":
		return "bundle"
	bundle.advance(1.0)
	if bundle.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0 or not bundle.workshop.is_busy():
		return "bundle early"
	bundle.advance(1.0)
	if bundle.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "bundle output"
	if bundle.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "fiber left"
	if bundle.start_cord() != "missing_inputs":
		return "cord started"
	var game := _purse()
	var funds := game.funds
	if bundle.fulfill_cord(game) != "missing_goods" or game.funds != funds:
		return "cord paid"
	if str(bundle.orders.status["lane_cord"]) != "open":
		return "cord closed"
	if bundle.fulfill_intro(game) != "" or game.funds != funds + 180:
		return "intro"
	if bundle.fulfill_cord(game) != "missing_goods" or game.funds != funds + 180:
		return "both paid"
	var cord := _arm("bram_holt")
	if cord == null or cord.set_loom_priority("twist_cord") != "":
		return "cord"
	if cord.workshop.ticks_remaining != 4:
		return "bram cord ticks %d" % cord.workshop.ticks_remaining
	cord.advance(3.0)
	if cord.inventory.amount("fiber_cord", GradeScale.COMMON) != 0:
		return "cord early"
	cord.advance(1.0)
	if cord.inventory.amount("fiber_cord", GradeScale.COMMON) != 1:
		return "cord output"
	if cord.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "cord fiber left"
	if cord.start_bundle() != "missing_inputs":
		return "bundle started"
	var purse := _purse()
	var cord_funds := purse.funds
	if cord.fulfill_intro(purse) != "missing_goods" or purse.funds != cord_funds:
		return "intro paid"
	if str(cord.orders.status["intro_bundle"]) != "open":
		return "intro closed"
	if cord.fulfill_cord(purse) != "" or purse.funds != cord_funds + 240:
		return "lane"
	if cord.fulfill_intro(purse) != "missing_goods" or purse.funds != cord_funds + 240:
		return "both from cord"
	return ""


func _old_save() -> String:
	var created: Dictionary = SaveGame.create_new("Legacy Rule", "northern_homestead")
	var game: SaveGame = created["game"]
	var data := game.to_dict()
	data.erase("research")
	var loaded: Dictionary = SaveGame.from_dict(data)
	if not loaded["ok"] or loaded["game"] == null:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1:
		return "schema"
	if str(copy.research.get("priority", "x")) != "":
		return "priority"
	if bool(copy.research.get("loom_rule", false)):
		return "owned"
	var loop := FarmLoop.new()
	if loop.read_from(copy) != "" or loop.research.owns("loom_rule") or loop.research.priority != "":
		return "read"
	data = game.to_dict()
	data["research"] = {"loom_rule": true, "priority": "twist_cord"}
	var kept: Dictionary = SaveGame.from_dict(data)
	if not kept["ok"]:
		return "kept"
	var saved: SaveGame = kept["game"]
	if not bool(saved.research.get("loom_rule", false)) or str(saved.research["priority"]) != "twist_cord":
		return "round trip"
	data = game.to_dict()
	data["research"] = {"priority": "pack_textile"}
	var bad: Dictionary = SaveGame.from_dict(data)
	if bad["ok"] or bad["game"] != null:
		return "pack priority"
	data = game.to_dict()
	data["research"] = {"loom_rule": true, "priority": "bundle_fiber"}
	var again: Dictionary = SaveGame.from_dict(data)
	if not again["ok"]:
		return "bundle priority"
	data = game.to_dict()
	data["schema"] = 2
	var future: Dictionary = SaveGame.from_dict(data)
	if future["ok"] or future["game"] != null:
		return "schema 2"
	return ""


func _arm(worker_id: String) -> FarmLoop:
	var loop := _done_loop()
	if loop.hire_worker(worker_id) != "" or loop.assign_workshop(worker_id) != "":
		return null
	var game := _purse()
	game.funds = int(ResourceCatalog.research("loom_rule")["cost"])
	if loop.buy_loom_rule(game) != "":
		return null
	if loop.plot.plant() != "":
		return null
	var spec := ResourceCatalog.growth("verdant_fiber")
	var ticks := (int(spec["stage_count"]) - 1) * int(spec["ticks_per_stage"])
	loop.advance(float(ticks))
	if not loop.plot.is_ready() or loop.workshop.is_busy():
		return null
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return null
	return loop


func _force_ready(loop: FarmLoop) -> bool:
	if loop.plot.plant() != "":
		return false
	var spec := ResourceCatalog.growth("verdant_fiber")
	loop.plot.stage = int(spec["stage_count"]) - 1
	loop.plot.ticks_remaining = 0
	return loop.plot.is_ready()


func _done_loop() -> FarmLoop:
	var loop := FarmLoop.new()
	loop.tutorial.step = TutorialTrack.DONE
	return loop


func _purse() -> SaveGame:
	return SaveGame.create_new("Purse", "tropical_valley")["game"]
