extends SceneTree

## Headless production, sale, and upgrade checks. Does not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("growth_catalog_is_a_timer", _growth_catalog)
	_check("plot_ready_on_the_exact_tick", _plot_ready)
	_check("early_harvest_does_not_touch_inventory", _early_harvest)
	_check("extra_ticks_do_not_multiply_yield", _extra_ticks)
	_check("growth_clock_splits_match", _growth_clock)
	_check("order_missing_goods_do_not_pay", _order_missing)
	_check("order_pays_once", _order_pays_once)
	_check("upgrade_short_funds_are_unchanged", _upgrade_short)
	_check("upgrade_debits_once", _upgrade_once)
	_check("sale_is_required_before_the_loft", _sale_required)
	_check("guided_cycle_reaches_the_loft", _guided_cycle)
	_check("loop_state_round_trips", _round_trip)
	_check("old_save_without_loop_keys_loads", _old_save)
	_check("bad_plot_is_rejected", _bad_plot)
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


func _growth_catalog() -> String:
	var spec := ResourceCatalog.growth("verdant_fiber")
	if int(spec["ticks_per_stage"]) != 2 or int(spec["stage_count"]) != 4:
		return "timing"
	if int(spec["yield_amount"]) != 2 or int(spec["grade"]) != GradeScale.COMMON:
		return "yield"
	if not ResourceCatalog.growth("packed_textile").is_empty():
		return "goods do not grow"
	if ResourceCatalog.stage_label(0) != "row" or ResourceCatalog.stage_label(3) != "ready":
		return "labels"
	var order := ResourceCatalog.order("intro_bundle")
	if int(order["reward_funds"]) != 180:
		return "reward"
	var requires: Array = order["requires"]
	if str(requires[0]["id"]) != "fiber_bundle" or int(requires[0]["amount"]) != 1:
		return "order input"
	if int(ResourceCatalog.upgrade("barn_loft")["cost"]) != 400:
		return "cost"
	if not ResourceCatalog.order("nope").is_empty():
		return "unknown order"
	return ""


func _ready_ticks() -> int:
	var spec := ResourceCatalog.growth("verdant_fiber")
	return (int(spec["stage_count"]) - 1) * int(spec["ticks_per_stage"])


func _plot_ready() -> String:
	var plot := CropPlot.new()
	if plot.plant() != "":
		return "plant"
	var total := _ready_ticks()
	if plot.tick(total - 1) == "ready" or plot.is_ready():
		return "ready early"
	if plot.stage_name() == "ready":
		return "label early"
	if plot.tick(1) != "ready" or not plot.is_ready():
		return "not ready on the duration"
	if plot.stage_name() != "ready":
		return "label"
	return ""


func _early_harvest() -> String:
	var plot := CropPlot.new()
	plot.plant()
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 1, GradeScale.COMMON)
	if plot.harvest(inventory) != "not_ready":
		return "harvested early"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 1:
		return "inventory changed"
	if not plot.planted:
		return "plot cleared"
	return ""


func _extra_ticks() -> String:
	var plot := CropPlot.new()
	plot.plant()
	plot.tick(100)
	var inventory := FarmInventory.new()
	if plot.harvest(inventory) != "":
		return "harvest"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "yield"
	if plot.harvest(inventory) == "":
		return "second harvest"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "yield grew"
	if plot.planted:
		return "still planted"
	return ""


func _growth_clock() -> String:
	var single := _planted_stepper()
	var split := _planted_stepper()
	single.step(6.0)
	for _i in 12:
		split.step(0.5)
	if not single.plot.is_ready() or not split.plot.is_ready():
		return "not ready"
	if single.plot.stage != split.plot.stage or single.plot.ticks_remaining != split.plot.ticks_remaining:
		return "stages diverged"
	if single.clock.tick_index != split.clock.tick_index or single.clock.remainder_ms != split.clock.remainder_ms:
		return "clock diverged"
	var early := _planted_stepper()
	early.step(5.0)
	if early.plot.is_ready():
		return "ready at 5 seconds"
	early.step(1.0)
	if not early.plot.is_ready():
		return "not ready at 6 seconds"
	return ""


func _planted_stepper() -> SimStepper:
	var inventory := FarmInventory.new()
	var workshop := Workshop.new(inventory)
	var stepper := SimStepper.new(SimClock.new(), workshop)
	var plot := CropPlot.new()
	plot.plant()
	stepper.plot = plot
	return stepper


func _order_missing() -> String:
	var board := OrderBoard.new()
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 4, GradeScale.COMMON)
	var result := board.try_fulfill("intro_bundle", inventory, 240)
	if str(result["error"]) != "missing_goods" or int(result["funds"]) != 240:
		return str(result)
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 4:
		return "fiber consumed"
	if str(board.status["intro_bundle"]) != "open":
		return "closed"
	return ""


func _order_pays_once() -> String:
	var board := OrderBoard.new()
	var inventory := FarmInventory.new()
	inventory.add("fiber_bundle", 1, GradeScale.FINE)
	var paid := board.try_fulfill("intro_bundle", inventory, 10)
	if str(paid["error"]) != "" or int(paid["funds"]) != 190 or int(paid["grade"]) != GradeScale.FINE:
		return str(paid)
	if inventory.amount("fiber_bundle", GradeScale.FINE) != 0:
		return "bundle remained"
	var again := board.try_fulfill("intro_bundle", inventory, int(paid["funds"]))
	if str(again["error"]) != "already_done" or int(again["funds"]) != 190:
		return str(again)
	return ""


func _upgrade_short() -> String:
	var shop := UpgradeShop.new()
	var result := shop.try_purchase("barn_loft", 399)
	if str(result["error"]) != "short_funds" or int(result["funds"]) != 399:
		return str(result)
	if shop.owns("barn_loft"):
		return "owned"
	if shop.try_purchase("nope", 399)["error"] != "unknown_upgrade":
		return "unknown"
	return ""


func _upgrade_once() -> String:
	var shop := UpgradeShop.new()
	var bought := shop.try_purchase("barn_loft", 400)
	if str(bought["error"]) != "" or int(bought["funds"]) != 0:
		return str(bought)
	if not shop.owns("barn_loft"):
		return "missing"
	var again := shop.try_purchase("barn_loft", 0)
	if str(again["error"]) != "already_owned" or int(again["funds"]) != 0:
		return str(again)
	return ""


func _sale_required() -> String:
	var poor: Dictionary = SaveGame.create_new("Lean Acre", "innovation_plains")
	var rich: Dictionary = SaveGame.create_new("Wide Acre", "tropical_valley")
	if not poor["ok"] or not rich["ok"]:
		return "create"
	var poor_game: SaveGame = poor["game"]
	var rich_game: SaveGame = rich["game"]
	var shop := UpgradeShop.new()
	var denied := shop.try_purchase("barn_loft", poor_game.funds)
	if str(denied["error"]) != "short_funds" or int(denied["funds"]) != poor_game.funds:
		return "poor buy %s" % str(denied)
	var rich_denied := shop.try_purchase("barn_loft", rich_game.funds)
	if str(rich_denied["error"]) != "short_funds":
		return "rich could buy before the sale"
	var reward := int(ResourceCatalog.order("intro_bundle")["reward_funds"])
	var cost := int(ResourceCatalog.upgrade("barn_loft")["cost"])
	if poor_game.funds + reward < cost:
		return "poorest region still cannot afford the loft after one order"
	if rich_game.funds >= cost:
		return "richest region can skip the sale"
	return ""


func _guided_cycle() -> String:
	var created: Dictionary = SaveGame.create_new("Loop Farm", "innovation_plains")
	if not created["ok"]:
		return str(created["error"])
	var game: SaveGame = created["game"]
	var starting := game.funds
	var loop := FarmLoop.new()
	if loop.read_from(game) != "":
		return "read"
	if loop.harvest() != "tutorial":
		return "harvest before the plot"
	if loop.buy_loft(game) != "tutorial" or game.funds != starting:
		return "bought early"
	if loop.plant_if_needed() != "" or loop.tutorial.step != TutorialTrack.GROW:
		return "place"
	loop.advance(5.0)
	if loop.plot.is_ready() or loop.tutorial.step != TutorialTrack.GROW:
		return "grew early"
	loop.advance(1.0)
	if not loop.plot.is_ready() or loop.tutorial.step != TutorialTrack.HARVEST:
		return "ready step"
	if loop.start_bundle() != "tutorial":
		return "workshop before harvest"
	if loop.harvest() != "":
		return "harvest"
	if loop.tutorial.step != TutorialTrack.WORKSHOP:
		return "after harvest"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 6:
		return "fiber %d" % loop.inventory.amount("verdant_fiber", GradeScale.COMMON)
	if loop.start_bundle() != "" or loop.tutorial.step != TutorialTrack.BUNDLE:
		return "start"
	if loop.inventory.amount("verdant_fiber", GradeScale.COMMON) != 4:
		return "inputs"
	loop.advance(3.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle early"
	loop.advance(1.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "bundle"
	if loop.tutorial.step != TutorialTrack.ORDER:
		return "order step"
	if loop.fulfill_intro(game) != "":
		return "fulfill"
	if game.funds != starting + 180 or loop.tutorial.step != TutorialTrack.UPGRADE:
		return "funds %d step %d" % [game.funds, loop.tutorial.step]
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle remained"
	if loop.buy_loft(game) != "":
		return "buy"
	if game.funds != starting + 180 - 400 or not loop.upgrades.owns("barn_loft"):
		return "loft funds %d" % game.funds
	if loop.tutorial.step != TutorialTrack.DONE:
		return "not done"
	if loop.buy_loft(game) != "already_owned" or game.funds != starting + 180 - 400:
		return "second buy"
	return ""


func _round_trip() -> String:
	var created: Dictionary = SaveGame.create_new("Stored Loop", "golden_fields")
	var game: SaveGame = created["game"]
	var loop := FarmLoop.new()
	loop.read_from(game)
	loop.plant_if_needed()
	loop.advance(3.0)
	loop.orders.status["intro_bundle"] = "done"
	loop.upgrades.owned["barn_loft"] = true
	loop.tutorial.step = TutorialTrack.BUNDLE
	loop.write_to(game)
	var loaded: Dictionary = SaveGame.from_dict(game.to_dict())
	if not loaded["ok"]:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	var again := FarmLoop.new()
	if again.read_from(copy) != "":
		return "read"
	if not again.plot.planted or again.plot.stage != loop.plot.stage:
		return "plot"
	if again.plot.ticks_remaining != loop.plot.ticks_remaining:
		return "ticks"
	if str(again.orders.status["intro_bundle"]) != "done":
		return "order"
	if not again.upgrades.owns("barn_loft"):
		return "loft"
	if again.tutorial.step != TutorialTrack.BUNDLE:
		return "tutorial"
	if copy.schema != 1:
		return "schema"
	return ""


func _old_save() -> String:
	var created: Dictionary = SaveGame.create_new("Legacy", "northern_homestead")
	var game: SaveGame = created["game"]
	var data := game.to_dict()
	data.erase("plot")
	data.erase("orders")
	data.erase("upgrades")
	var loaded: Dictionary = SaveGame.from_dict(data)
	if not loaded["ok"]:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if bool(copy.plot["planted"]):
		return "planted"
	if str(copy.orders["intro_bundle"]) != "open":
		return "order"
	if not copy.upgrades.is_empty():
		return "upgrades"
	if copy.funds != game.funds or copy.schema != 1:
		return "identity"
	return ""


func _bad_plot() -> String:
	var created: Dictionary = SaveGame.create_new("Bad Plot", "tropical_valley")
	var data: Dictionary = (created["game"] as SaveGame).to_dict()
	data["plot"] = {
		"planted": true,
		"resource_id": "verdant_fiber",
		"stage": 9,
		"ticks_remaining": 0,
		"grade": 1,
	}
	var loaded: Dictionary = SaveGame.from_dict(data)
	if loaded["ok"] or loaded["game"] != null:
		return "accepted"
	if str(loaded["error"]) != "bad_plot":
		return str(loaded["error"])
	return ""
