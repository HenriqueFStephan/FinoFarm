extends SceneTree

## Headless simulation checks. This script must not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("grades_and_labels", _grades_and_labels)
	_check("inventory_stacks_by_grade", _inventory_stacks_by_grade)
	_check("inventory_rejects_bad_input", _inventory_rejects_bad_input)
	_check("catalog_recipes_are_abstract_timers", _catalog_recipes)
	_check("workshop_missing_inputs_do_not_consume", _workshop_missing)
	_check("workshop_rejects_bad_grade_and_unknown_recipe", _workshop_rejects)
	_check("bundle_completes_on_duration_and_keeps_grade", _bundle_grade)
	_check("output_grade_is_the_minimum_input", _pack_minimum_grade)
	_check("second_start_while_busy_does_not_double_consume", _busy)
	_check("extra_ticks_do_not_repeat_the_job", _no_repeat)
	_check("clock_splits_time_without_frame_dependency", _clock)
	_check("stepper_paths_match", _stepper_paths)
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


func _grades_and_labels() -> String:
	if not GradeScale.is_valid(1) or not GradeScale.is_valid(3):
		return "expected grades 1 and 3 to be valid"
	if GradeScale.is_valid(0) or GradeScale.is_valid(4):
		return "grades outside 1..3 must be invalid"
	if GradeScale.minimum([3, 1, 2]) != 1:
		return "minimum grade"
	if GradeScale.label(2) != "fine" or GradeScale.label(9) != "invalid":
		return "labels"
	return ""


func _inventory_stacks_by_grade() -> String:
	var inventory := FarmInventory.new()
	if not inventory.add("verdant_fiber", 2, GradeScale.COMMON):
		return "add common"
	if not inventory.add("verdant_fiber", 3, GradeScale.SELECT):
		return "add select"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "common stack changed"
	if inventory.amount("verdant_fiber", GradeScale.SELECT) != 3:
		return "select stack changed"
	if not inventory.remove("verdant_fiber", GradeScale.COMMON, 2):
		return "remove"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 0:
		return "common stack remained"
	if inventory.amount("verdant_fiber", GradeScale.SELECT) != 3:
		return "other grade was touched"
	if inventory.remove("verdant_fiber", GradeScale.SELECT, 4):
		return "remove past zero should fail"
	return ""


func _inventory_rejects_bad_input() -> String:
	var inventory := FarmInventory.new()
	if inventory.add("verdant_fiber", 0, 1):
		return "zero amount"
	if inventory.add("verdant_fiber", 1, 0):
		return "bad grade"
	if inventory.add("not_a_resource", 1, 1):
		return "unknown resource"
	if not inventory.snapshot().is_empty():
		return "snapshot should stay empty"
	return ""


func _catalog_recipes() -> String:
	var bundle := ResourceCatalog.recipe("bundle_fiber")
	var pack := ResourceCatalog.recipe("pack_textile")
	if int(bundle["duration_ticks"]) != 4 or int(pack["duration_ticks"]) != 3:
		return "durations drifted"
	if str(bundle["output_id"]) != "fiber_bundle":
		return "bundle output"
	if str(pack["output_id"]) != "packed_textile":
		return "pack output"
	if ResourceCatalog.resources().has("cannabis"):
		return "catalog must stay on fictional goods"
	if not ResourceCatalog.recipe("nope").is_empty():
		return "unknown recipe should be empty"
	return ""


func _workshop_missing() -> String:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 1, GradeScale.FINE)
	var workshop := Workshop.new(inventory)
	var error := workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.FINE})
	if error != "missing_inputs":
		return error
	if inventory.amount("verdant_fiber", GradeScale.FINE) != 1:
		return "inputs changed on failure"
	if workshop.is_busy():
		return "failed start left the workshop busy"
	return ""


func _workshop_rejects() -> String:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	var workshop := Workshop.new(inventory)
	if workshop.try_start("nope", {}) != "unknown_recipe":
		return "unknown"
	if workshop.try_start("bundle_fiber", {}) != "missing_grade":
		return "missing grade"
	if workshop.try_start("bundle_fiber", {"verdant_fiber": 9}) != "bad_grade":
		return "bad grade"
	if inventory.amount("verdant_fiber", GradeScale.COMMON) != 2:
		return "rejected start consumed inputs"
	return ""


func _bundle_grade() -> String:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 2, GradeScale.SELECT)
	var workshop := Workshop.new(inventory)
	if workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.SELECT}) != "":
		return "start"
	if workshop.tick(3).size() != 0:
		return "finished early"
	if inventory.amount("fiber_bundle", GradeScale.SELECT) != 0:
		return "output appeared early"
	var produced := workshop.tick(1)
	if int(produced["amount"]) != 1 or int(produced["grade"]) != GradeScale.SELECT:
		return "produced %s" % str(produced)
	if inventory.amount("fiber_bundle", GradeScale.SELECT) != 1:
		return "inventory output"
	if inventory.amount("verdant_fiber", GradeScale.SELECT) != 0:
		return "inputs remained"
	if workshop.is_busy():
		return "still busy"
	return ""


func _pack_minimum_grade() -> String:
	var inventory := FarmInventory.new()
	inventory.add("fiber_bundle", 1, GradeScale.SELECT)
	inventory.add("seal_wax", 1, GradeScale.COMMON)
	var workshop := Workshop.new(inventory)
	var error := workshop.try_start("pack_textile", {
		"fiber_bundle": GradeScale.SELECT,
		"seal_wax": GradeScale.COMMON,
	})
	if error != "":
		return error
	var produced := workshop.tick(3)
	if int(produced["grade"]) != GradeScale.COMMON:
		return "grade %s" % str(produced)
	if inventory.amount("packed_textile", GradeScale.COMMON) != 1:
		return "packed amount"
	return ""


func _busy() -> String:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 4, GradeScale.FINE)
	var workshop := Workshop.new(inventory)
	if workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.FINE}) != "":
		return "first start"
	if workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.FINE}) != "busy":
		return "second start"
	if inventory.amount("verdant_fiber", GradeScale.FINE) != 2:
		return "second start consumed more fiber"
	return ""


func _no_repeat() -> String:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 2, GradeScale.COMMON)
	var workshop := Workshop.new(inventory)
	workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.COMMON})
	workshop.tick(100)
	if inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "job repeated"
	return ""


func _clock() -> String:
	var split := SimClock.new()
	if split.advance(0.5) != 0:
		return "half second ticked"
	if split.advance(0.5) != 1 or split.tick_index != 1 or split.remainder_ms != 0:
		return "two halves"
	var whole := SimClock.new()
	if whole.advance(4.0) != 4 or whole.remainder_ms != 0:
		return "four seconds"
	var parts := SimClock.new()
	if parts.advance(2.0) + parts.advance(2.0) != 4:
		return "split four seconds"
	var negative := SimClock.new()
	negative.advance(1.0)
	if negative.advance(-5.0) != 0 or negative.tick_index != 1:
		return "negative delta changed the clock"
	var partial := SimClock.new()
	if partial.advance(2.5) != 2 or partial.remainder_ms != 500:
		return "remainder"
	return ""


func _stepper_paths() -> String:
	var single := _run_path(func(stepper: SimStepper) -> void:
		stepper.step(4.0)
	)
	var halves := _run_path(func(stepper: SimStepper) -> void:
		for _i in 8:
			stepper.step(0.5)
	)
	if single["snapshot"] != halves["snapshot"]:
		return "snapshots differ %s vs %s" % [str(single["snapshot"]), str(halves["snapshot"])]
	if single["ticks"] != halves["ticks"] or single["remainder"] != halves["remainder"]:
		return "clock diverged"
	if int(single["snapshot"].get("fiber_bundle#3", 0)) != 1:
		return "expected one select bundle"
	var early := _fresh_stepper()
	if early.step(3.0).size() != 0:
		return "finished at 3 seconds"
	var late := early.step(1.0)
	if int(late.get("grade", 0)) != GradeScale.SELECT:
		return "late finish"
	return ""


func _run_path(drive: Callable) -> Dictionary:
	var stepper := _fresh_stepper()
	drive.call(stepper)
	return {
		"snapshot": stepper.workshop.inventory.snapshot(),
		"ticks": stepper.clock.tick_index,
		"remainder": stepper.clock.remainder_ms,
	}


func _fresh_stepper() -> SimStepper:
	var inventory := FarmInventory.new()
	inventory.add("verdant_fiber", 2, GradeScale.SELECT)
	var workshop := Workshop.new(inventory)
	if workshop.try_start("bundle_fiber", {"verdant_fiber": GradeScale.SELECT}) != "":
		push_error("fixture failed to start")
	return SimStepper.new(SimClock.new(), workshop)
