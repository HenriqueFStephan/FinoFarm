extends SceneTree

## Headless production-priority checks. Does not instance a 3D scene.


var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("cord_competes_for_the_same_fiber", _cord_competes)
	_check("lane_order_pays_differently", _lane_pays)
	_check("one_harvest_fills_only_the_bundle_order", _harvest_bundle)
	_check("one_harvest_fills_only_the_cord_order", _harvest_cord)
	_check("inventory_line_shows_both_goods", _inventory_line)
	_check("shuttle_rack_shortens_the_next_job", _shuttle_speed)
	_check("shuttle_rack_leaves_a_running_job", _shuttle_running)
	_check("assignment_still_splits_the_two_goods", _assignment)
	_check("lesson_blocks_cord_and_shuttle", _lesson_blocks)
	_check("old_save_keeps_schema_and_opens_the_cord_order", _old_save)
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


func _cord_competes() -> String:
	var growth := ResourceCatalog.growth("verdant_fiber")
	var bundle := ResourceCatalog.recipe("bundle_fiber")
	var cord := ResourceCatalog.recipe("twist_cord")
	if cord.is_empty() or str(cord["output_id"]) != "fiber_cord":
		return "recipe"
	if int(cord["output_amount"]) != 1 or int(cord["duration_ticks"]) != 5:
		return "cord timing"
	var bundle_inputs: Array = bundle["inputs"]
	var cord_inputs: Array = cord["inputs"]
	if str(bundle_inputs[0]["id"]) != "verdant_fiber" or str(cord_inputs[0]["id"]) != "verdant_fiber":
		return "input"
	var yield_amount := int(growth["yield_amount"])
	var needed := int(bundle_inputs[0]["amount"]) + int(cord_inputs[0]["amount"])
	if yield_amount >= needed:
		return "one harvest covers both"
	if int(bundle_inputs[0]["amount"]) != yield_amount:
		return "bundle does not spend the harvest"
	if int(cord_inputs[0]["amount"]) != yield_amount:
		return "cord does not spend the harvest"
	return ""


func _lane_pays() -> String:
	var intro := ResourceCatalog.order("intro_bundle")
	var lane := ResourceCatalog.order("lane_cord")
	if lane.is_empty():
		return "missing"
	var intro_pay := int(intro["reward_funds"])
	var lane_pay := int(lane["reward_funds"])
	if intro_pay == lane_pay or lane_pay != 240 or intro_pay != 180:
		return "pay %d %d" % [intro_pay, lane_pay]
	var requires: Array = lane["requires"]
	if str(requires[0]["id"]) != "fiber_cord" or int(requires[0]["amount"]) != 1:
		return "requires"
	if int(ResourceCatalog.upgrade("shuttle_rack")["cost"]) != 160:
		return "cost"
	if int(ResourceCatalog.upgrade("shuttle_rack")["speed_ticks"]) != 1:
		return "speed"
	return ""


func _harvest_bundle() -> String:
	var loop := _one_harvest()
	if loop == null:
		return "harvest"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "yield"
	if loop.start_bundle() != "":
		return "bundle"
	loop.advance(4.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "fiber left"
	if loop.start_cord() != "missing_inputs":
		return "cord started"
	if loop.inventory.amount("fiber_cord", GradeScale.COMMON) != 0:
		return "cord output"
	var game := _purse()
	var funds := game.funds
	if loop.fulfill_cord(game) != "missing_goods" or game.funds != funds:
		return "cord paid"
	if str(loop.orders.status["lane_cord"]) != "open":
		return "cord closed"
	if loop.fulfill_intro(game) != "":
		return "intro"
	if game.funds != funds + 180:
		return "intro funds %d" % game.funds
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle remained"
	if loop.fulfill_cord(game) != "missing_goods" or game.funds != funds + 180:
		return "both paid"
	return ""


func _harvest_cord() -> String:
	var loop := _one_harvest()
	if loop == null:
		return "harvest"
	if loop.start_cord() != "":
		return "cord"
	var cord_ticks := int(ResourceCatalog.recipe("twist_cord")["duration_ticks"])
	loop.advance(float(cord_ticks - 1))
	if loop.inventory.amount("fiber_cord", GradeScale.COMMON) != 0:
		return "early"
	loop.advance(1.0)
	if loop.inventory.amount("fiber_cord", GradeScale.COMMON) != 1:
		return "output"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "fiber left"
	if loop.start_bundle() != "missing_inputs":
		return "bundle started"
	var game := _purse()
	var funds := game.funds
	if loop.fulfill_intro(game) != "missing_goods" or game.funds != funds:
		return "intro paid"
	if str(loop.orders.status["intro_bundle"]) != "open":
		return "intro closed"
	if loop.fulfill_cord(game) != "":
		return "lane"
	if game.funds != funds + 240:
		return "lane funds %d" % game.funds
	if loop.fulfill_intro(game) != "missing_goods" or game.funds != funds + 240:
		return "both paid"
	return ""


func _inventory_line() -> String:
	var loop := FarmLoop.new()
	var empty := loop.inventory_line()
	if not empty.contains("Fiber Bundle 0") or not empty.contains("Fiber Cord 0"):
		return "empty %s" % empty
	loop.inventory.add("fiber_bundle", 1, GradeScale.COMMON)
	loop.inventory.add("fiber_cord", 2, GradeScale.FINE)
	var line := loop.inventory_line()
	if not line.contains("Fiber Bundle 1 common") or not line.contains("Fiber Cord 2 fine"):
		return line
	return ""


func _shuttle_speed() -> String:
	var poor := _done_loop()
	poor.upgrades.owned["barn_loft"] = true
	var game := _purse()
	game.funds = 159
	if poor.buy_shuttle(game) != "short_funds" or game.funds != 159 or poor.upgrades.owns("shuttle_rack"):
		return "short"
	game.funds = 160
	if poor.buy_shuttle(game) != "" or game.funds != 0 or not poor.upgrades.owns("shuttle_rack"):
		return "buy"
	if poor.buy_shuttle(game) != "already_owned" or game.funds != 0:
		return "second"
	poor.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	if poor.start_bundle() != "":
		return "start"
	if poor.workshop.ticks_remaining != 3:
		return "paced %d" % poor.workshop.ticks_remaining
	poor.advance(3.0)
	if poor.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	var plain := _done_loop()
	plain.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	if plain.start_bundle() != "" or plain.workshop.ticks_remaining != 4:
		return "catalog pace"
	if WorkerPace.bundle_ticks(StaffCatalog.worker("alex_morgan")) != 2:
		return "alex catalog"
	if WorkerPace.bundle_ticks(StaffCatalog.worker("bram_holt")) != 3:
		return "bram catalog"
	return ""


func _shuttle_running() -> String:
	var loop := _done_loop()
	loop.upgrades.owned["barn_loft"] = true
	loop.inventory.add("verdant_fiber", 4, GradeScale.COMMON)
	if loop.start_bundle() != "" or loop.workshop.ticks_remaining != 4:
		return "start"
	var game := _purse()
	game.funds = 160
	if loop.buy_shuttle(game) != "":
		return "buy"
	if loop.workshop.ticks_remaining != 4:
		return "edited %d" % loop.workshop.ticks_remaining
	loop.advance(3.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0 or not loop.workshop.is_busy():
		return "early"
	loop.advance(1.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	if loop.start_bundle() != "" or loop.workshop.ticks_remaining != 3:
		return "next %d" % loop.workshop.ticks_remaining
	return ""


func _assignment() -> String:
	var alex := _done_loop()
	var bram := _done_loop()
	alex.hire_worker("alex_morgan")
	alex.assign_workshop("alex_morgan")
	bram.hire_worker("bram_holt")
	bram.assign_workshop("bram_holt")
	if alex.job_ticks("bundle_fiber") == bram.job_ticks("bundle_fiber"):
		return "bundle pace"
	if alex.job_ticks("twist_cord") == bram.job_ticks("twist_cord"):
		return "cord pace"
	if alex.job_ticks("bundle_fiber") != 2 or bram.job_ticks("bundle_fiber") != 3:
		return "bundle numbers"
	if alex.job_ticks("twist_cord") != 3 or bram.job_ticks("twist_cord") != 4:
		return "cord numbers"
	alex.upgrades.owned["shuttle_rack"] = true
	if alex.job_ticks("bundle_fiber") != 1:
		return "alex rack"
	alex.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	bram.inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	if alex.start_bundle() != "" or bram.start_bundle() != "":
		return "start"
	var sooner := mini(alex.workshop.ticks_remaining, bram.workshop.ticks_remaining)
	alex.advance(float(sooner))
	bram.advance(float(sooner))
	if alex.inventory.snapshot() == bram.inventory.snapshot():
		return "same snapshot"
	return ""


func _lesson_blocks() -> String:
	var created: Dictionary = SaveGame.create_new("Lesson", "tropical_valley")
	var game: SaveGame = created["game"]
	var loop := FarmLoop.new()
	loop.read_from(game)
	var fiber := loop.inventory.amount("verdant_fiber", GradeScale.COMMON)
	var funds := game.funds
	if loop.start_cord() != "tutorial" or loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != fiber:
		return "cord during place"
	if loop.buy_shuttle(game) != "tutorial" or game.funds != funds:
		return "shuttle during place"
	loop.tutorial.step = TutorialTrack.WORKSHOP
	if loop.start_cord() != "tutorial":
		return "cord during bundle step"
	if loop.buy_shuttle(game) != "tutorial":
		return "shuttle before the loft"
	loop.tutorial.step = TutorialTrack.DONE
	if loop.buy_shuttle(game) != "needs_loft":
		return "rack before loft"
	return ""


func _old_save() -> String:
	var created: Dictionary = SaveGame.create_new("Legacy Orders", "northern_homestead")
	var game: SaveGame = created["game"]
	var data := game.to_dict()
	data["orders"] = {"intro_bundle": "done"}
	var loaded: Dictionary = SaveGame.from_dict(data)
	if not loaded["ok"] or loaded["game"] == null:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1:
		return "schema"
	if str(copy.orders["intro_bundle"]) != "done":
		return "intro"
	if str(copy.orders["lane_cord"]) != "open":
		return "lane"
	data = game.to_dict()
	data.erase("orders")
	data.erase("upgrades")
	var again: Dictionary = SaveGame.from_dict(data)
	if not again["ok"]:
		return "erased"
	var blank: SaveGame = again["game"]
	if str(blank.orders["intro_bundle"]) != "open" or str(blank.orders["lane_cord"]) != "open":
		return "defaults"
	if not blank.upgrades.is_empty() or blank.schema != 1:
		return "upgrades"
	data = game.to_dict()
	data["upgrades"] = {"shuttle_rack": true}
	var rack: Dictionary = SaveGame.from_dict(data)
	if not rack["ok"] or not bool((rack["game"] as SaveGame).upgrades.get("shuttle_rack", false)):
		return "rack save"
	data = game.to_dict()
	data["schema"] = 2
	var future: Dictionary = SaveGame.from_dict(data)
	if future["ok"] or future["game"] != null:
		return "schema 2"
	return ""


func _one_harvest() -> FarmLoop:
	var loop := _done_loop()
	if loop.plot.plant() != "":
		return null
	var spec := ResourceCatalog.growth("verdant_fiber")
	var ticks := (int(spec["stage_count"]) - 1) * int(spec["ticks_per_stage"])
	loop.advance(float(ticks))
	if not loop.plot.is_ready() or loop.harvest() != "":
		return null
	return loop


func _done_loop() -> FarmLoop:
	var loop := FarmLoop.new()
	loop.tutorial.step = TutorialTrack.DONE
	return loop


func _purse() -> SaveGame:
	return SaveGame.create_new("Purse", "tropical_valley")["game"]
