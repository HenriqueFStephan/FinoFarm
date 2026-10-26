extends SceneTree

## Headless hiring and assignment checks. Does not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("catalog_lists_two_workers", _catalog)
	_check("attribute_total_changes_bundle_time", _totals)
	_check("unassigned_bundle_keeps_catalog_time", _unassigned)
	_check("assignments_do_not_match", _assignments)
	_check("assigned_job_off_by_one", _off_by_one)
	_check("assigned_clock_splits_match", _splits)
	_check("hire_failures_do_not_mutate", _hire_failures)
	_check("running_job_keeps_its_ticks", _running_job)
	_check("hire_does_not_charge_a_wage", _wage)
	_check("staff_round_trip", _round_trip)
	_check("old_save_without_staff_loads", _old_save)
	_check("bad_staff_is_rejected", _bad_staff)
	_check("tutorial_lines_unchanged", _tutorial_lines)
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


func _catalog() -> String:
	var rows := StaffCatalog.workers()
	if rows.size() < 2:
		return "count %d" % rows.size()
	var seen := {}
	for person in rows:
		var worker_id := str(person["id"])
		if seen.has(worker_id):
			return "duplicate %s" % worker_id
		seen[worker_id] = true
		if str(person["name"]) == "" or str(person["role"]) == "":
			return "name"
		for key in StaffCatalog.ATTRIBUTE_KEYS:
			var value := int(person[key])
			if value < 1 or value > 10:
				return "%s %s %d" % [worker_id, key, value]
		if StaffCatalog.attribute_total(person) != _sum(person):
			return "total"
	if not seen.has("alex_morgan") or not seen.has("bram_holt"):
		return "ids"
	var alex := StaffCatalog.worker("alex_morgan")
	if int(alex["efficiency"]) != 6 or int(alex["technical"]) != 8:
		return "alex"
	if int(alex["creativity"]) != 4 or int(alex["organization"]) != 5:
		return "alex mid"
	if int(alex["social"]) != 3 or int(alex["adaptability"]) != 7:
		return "alex last"
	if StaffCatalog.worker("nope").is_empty() == false:
		return "unknown"
	var copy := StaffCatalog.worker("alex_morgan")
	copy["technical"] = 1
	if int(StaffCatalog.worker("alex_morgan")["technical"]) != 8:
		return "catalog mutated"
	return ""


func _sum(person: Dictionary) -> int:
	var total := 0
	for key in StaffCatalog.ATTRIBUTE_KEYS:
		total += int(person[key])
	return total


func _totals() -> String:
	var low := {
		"efficiency": 1,
		"technical": 1,
		"creativity": 1,
		"organization": 1,
		"social": 1,
		"adaptability": 1,
	}
	var high := {
		"efficiency": 10,
		"technical": 10,
		"creativity": 10,
		"organization": 10,
		"social": 10,
		"adaptability": 10,
	}
	if WorkerPace.bundle_ticks(low) == WorkerPace.bundle_ticks(high):
		return "totals ignored"
	if WorkerPace.bundle_ticks({}) != int(ResourceCatalog.recipe("bundle_fiber")["duration_ticks"]):
		return "empty worker"
	var alex := StaffCatalog.attribute_total(StaffCatalog.worker("alex_morgan"))
	var bram := StaffCatalog.attribute_total(StaffCatalog.worker("bram_holt"))
	if alex == bram:
		return "candidate totals match"
	if WorkerPace.bundle_ticks(StaffCatalog.worker("alex_morgan")) == WorkerPace.bundle_ticks(StaffCatalog.worker("bram_holt")):
		return "candidate paces match"
	return ""


func _unassigned() -> String:
	var loop := _prepared("")
	var before := loop.inventory.snapshot()
	if loop.start_bundle() != "":
		return "start"
	var catalog_ticks := int(ResourceCatalog.recipe("bundle_fiber")["duration_ticks"])
	if loop.workshop.ticks_remaining != catalog_ticks:
		return "ticks %d" % loop.workshop.ticks_remaining
	loop.advance(float(catalog_ticks - 1))
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "early"
	loop.advance(1.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	if loop.workshop.is_busy():
		return "busy"
	if int(before.get("verdant_fiber#1", 0)) - 2 != loop.inventory.amount("verdant_fiber", GradeScale.COMMON):
		return "inputs"
	return ""


func _assignments() -> String:
	var alex := _prepared("alex_morgan")
	var bram := _prepared("bram_holt")
	if alex.start_bundle() != "" or bram.start_bundle() != "":
		return "start"
	if alex.workshop.ticks_remaining == bram.workshop.ticks_remaining:
		return "same ticks"
	var sooner := mini(alex.workshop.ticks_remaining, bram.workshop.ticks_remaining)
	alex.advance(float(sooner))
	bram.advance(float(sooner))
	if alex.clock.tick_index != bram.clock.tick_index or alex.clock.remainder_ms != bram.clock.remainder_ms:
		return "clock"
	if alex.inventory.snapshot() == bram.inventory.snapshot():
		return "snapshots match"
	var alex_done := alex.inventory.amount("fiber_bundle", GradeScale.COMMON) > 0
	var bram_done := bram.inventory.amount("fiber_bundle", GradeScale.COMMON) > 0
	if alex_done == bram_done:
		return "same output state"
	return ""


func _off_by_one() -> String:
	for worker_id in ["alex_morgan", "bram_holt"]:
		var loop := _prepared(worker_id)
		if loop.start_bundle() != "":
			return "start"
		var duration := loop.workshop.ticks_remaining
		var expected := WorkerPace.bundle_ticks(StaffCatalog.worker(worker_id))
		if duration != expected:
			return "%s ticks %d" % [worker_id, duration]
		loop.advance(float(duration - 1))
		if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0 or not loop.workshop.is_busy():
			return "%s early" % worker_id
		loop.advance(1.0)
		if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1 or loop.workshop.is_busy():
			return "%s finish" % worker_id
	return ""


func _splits() -> String:
	var single := _prepared("alex_morgan")
	var split := _prepared("alex_morgan")
	if single.start_bundle() != "" or split.start_bundle() != "":
		return "start"
	var duration := single.workshop.ticks_remaining
	single.advance(float(duration))
	for _step in duration * 2:
		split.advance(0.5)
	if single.inventory.snapshot() != split.inventory.snapshot():
		return "inventory"
	if single.clock.tick_index != split.clock.tick_index:
		return "ticks"
	if single.clock.remainder_ms != split.clock.remainder_ms:
		return "remainder"
	if single.workshop.is_busy() or split.workshop.is_busy():
		return "busy"
	return ""


func _hire_failures() -> String:
	var loop := _prepared("")
	if loop.hire_worker("nope") != "unknown_worker" or loop.roster.hired.size() != 0:
		return "unknown hire"
	if loop.assign_workshop("alex_morgan") != "not_hired" or loop.roster.workshop_worker_id != "":
		return "assign first"
	if loop.hire_worker("alex_morgan") != "":
		return "hire"
	if loop.hire_worker("alex_morgan") != "already_hired" or loop.roster.hired.size() != 1:
		return "twice"
	if loop.assign_workshop("bram_holt") != "not_hired":
		return "other"
	if loop.assign_workshop("nope") != "unknown_worker":
		return "unknown assign"
	if loop.roster.workshop_worker_id != "":
		return "assigned anyway"
	return ""


func _running_job() -> String:
	var loop := _prepared("")
	loop.hire_worker("alex_morgan")
	loop.hire_worker("bram_holt")
	loop.assign_workshop("alex_morgan")
	if loop.start_bundle() != "":
		return "start"
	var ticks := loop.workshop.ticks_remaining
	if loop.assign_workshop("bram_holt") != "":
		return "switch"
	if loop.workshop.ticks_remaining != ticks or loop.roster.workshop_worker_id != "bram_holt":
		return "running job changed"
	loop.advance(float(ticks))
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		return "output"
	return ""


func _wage() -> String:
	var created: Dictionary = SaveGame.create_new("Wage Farm", "tropical_valley")
	var game: SaveGame = created["game"]
	var funds := game.funds
	var loop := FarmLoop.new()
	loop.read_from(game)
	loop.tutorial.step = TutorialTrack.DONE
	if loop.hire_worker("alex_morgan") != "" or loop.hire_worker("bram_holt") != "":
		return "hire"
	loop.write_to(game)
	if game.funds != funds:
		return "charged"
	return ""


func _round_trip() -> String:
	var created: Dictionary = SaveGame.create_new("Crew File", "golden_fields")
	var game: SaveGame = created["game"]
	var loop := FarmLoop.new()
	loop.read_from(game)
	loop.hire_worker("bram_holt")
	loop.hire_worker("alex_morgan")
	loop.assign_workshop("alex_morgan")
	loop.write_to(game)
	var loaded: Dictionary = SaveGame.from_dict(game.to_dict())
	if not loaded["ok"]:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1:
		return "schema"
	var again := FarmLoop.new()
	if again.read_from(copy) != "":
		return "read"
	if again.roster.hired.size() != 2:
		return "hired"
	if again.roster.hired[0] != "bram_holt" or again.roster.hired[1] != "alex_morgan":
		return "order"
	if again.roster.assigned_worker().is_empty():
		return "missing assignee"
	if str(again.roster.assigned_worker()["id"]) != "alex_morgan":
		return "assignee"
	return ""


func _old_save() -> String:
	var created: Dictionary = SaveGame.create_new("Legacy Crew", "northern_homestead")
	var data := (created["game"] as SaveGame).to_dict()
	data.erase("staff")
	var loaded: Dictionary = SaveGame.from_dict(data)
	if not loaded["ok"] or loaded["game"] == null:
		return str(loaded["error"])
	var copy: SaveGame = loaded["game"]
	if copy.schema != 1:
		return "schema"
	var loop := FarmLoop.new()
	if loop.read_from(copy) != "":
		return "read"
	if loop.roster.hired.size() != 0 or loop.roster.workshop_worker_id != "":
		return "staff appeared"
	if loop.start_bundle() != "tutorial":
		return "lesson"
	return ""


func _bad_staff() -> String:
	var created: Dictionary = SaveGame.create_new("Bad Crew", "innovation_plains")
	var base: Dictionary = (created["game"] as SaveGame).to_dict()
	var unknown := base.duplicate(true)
	unknown["staff"] = {"hired": ["nope"], "workshop": ""}
	if _accepted(unknown):
		return "unknown id"
	var skipped := base.duplicate(true)
	skipped["staff"] = {"hired": [], "workshop": "alex_morgan"}
	if _accepted(skipped):
		return "assign without hire"
	var doubled := base.duplicate(true)
	doubled["staff"] = {"hired": ["alex_morgan", "alex_morgan"], "workshop": "alex_morgan"}
	if _accepted(doubled):
		return "duplicate"
	var shape := base.duplicate(true)
	shape["staff"] = "alex"
	if _accepted(shape):
		return "shape"
	return ""


func _accepted(data: Dictionary) -> bool:
	var loaded: Dictionary = SaveGame.from_dict(data)
	return loaded["ok"] or loaded["game"] != null


func _tutorial_lines() -> String:
	var track := TutorialTrack.new()
	var lines := [
		"Mara: The row is empty. Place a plot on open ground, away from the barn.",
		"Mara: Verdant Fiber is on a timer. Wait until the plot reads ready.",
		"Mara: It's ready. Harvest the fiber into your inventory.",
		"Mara: Click the workshop and bundle two fibers.",
		"Mara: The workshop is running. Wait for the Fiber Bundle.",
		"Mara: The stall wants that bundle. Open the order board and deliver it.",
		"Mara: The payment landed. Buy the barn loft.",
		"Mara: You grew fiber, sold a bundle, and raised the loft. That is the loop.",
	]
	for step in lines.size():
		track.step = step
		if track.prompt() != lines[step]:
			return "step %d %s" % [step, track.prompt()]
	if TutorialTrack.DONE != 7:
		return "done moved"
	return ""


func _prepared(worker_id: String) -> FarmLoop:
	var created: Dictionary = SaveGame.create_new("Crew Test", "tropical_valley")
	var game: SaveGame = created["game"]
	var loop := FarmLoop.new()
	loop.read_from(game)
	loop.tutorial.step = TutorialTrack.DONE
	if worker_id != "":
		loop.hire_worker(worker_id)
		loop.assign_workshop(worker_id)
	return loop
