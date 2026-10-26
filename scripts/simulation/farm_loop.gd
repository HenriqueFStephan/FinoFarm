class_name FarmLoop
extends RefCounted

## The scene calls this. Durations and grades stay in the catalog and the workshop.

var inventory: FarmInventory
var workshop: Workshop
var clock: SimClock
var stepper: SimStepper
var plot: CropPlot
var orders: OrderBoard
var upgrades: UpgradeShop
var tutorial: TutorialTrack
var roster: StaffRoster
var last_event := ""


func _init() -> void:
	inventory = FarmInventory.new()
	workshop = Workshop.new(inventory)
	clock = SimClock.new()
	stepper = SimStepper.new(clock, workshop)
	plot = CropPlot.new()
	stepper.plot = plot
	orders = OrderBoard.new()
	upgrades = UpgradeShop.new()
	tutorial = TutorialTrack.new()
	roster = StaffRoster.new()


func read_from(game: SaveGame) -> String:
	if not game.read_inventory_into(inventory):
		return "bad_inventory"
	game.read_workshop_into(workshop)
	plot.import_state(game.plot)
	orders.import_state(game.orders)
	upgrades.import_state(game.upgrades)
	roster.import_state(game.staff)
	tutorial.step = clampi(game.tutorial_step, 0, TutorialTrack.DONE)
	return ""


func write_to(game: SaveGame) -> void:
	game.write_inventory_from(inventory)
	game.write_workshop_from(workshop)
	game.plot = plot.export_state()
	game.orders = orders.export_state()
	game.upgrades = upgrades.export_state()
	game.staff = roster.export_state()
	game.tutorial_step = tutorial.step


func advance(delta_seconds: float) -> void:
	var was_ready := plot.is_ready()
	var produced := stepper.step(delta_seconds)
	if not was_ready and plot.is_ready():
		tutorial.notify("ready")
		last_event = "The fiber plot is ready."
	if produced.is_empty():
		return
	var output_id := str(produced.get("id", ""))
	if output_id == "fiber_bundle":
		tutorial.notify("bundled")
		last_event = "The workshop finished a Fiber Bundle."
	elif ResourceCatalog.resources().has(output_id):
		var label := str(ResourceCatalog.resources()[output_id]["label"])
		last_event = "The workshop finished a %s." % label
	else:
		last_event = "The workshop finished."


func plant_if_needed() -> String:
	if plot.planted:
		if tutorial.step == TutorialTrack.PLACE:
			tutorial.notify("placed")
		return ""
	var err := plot.plant()
	if err == "":
		tutorial.notify("placed")
		last_event = "Verdant Fiber is growing."
	return err


func uproot() -> void:
	plot.clear()
	tutorial.rewind_to_place()


func harvest() -> String:
	if not tutorial.allows("harvest"):
		last_event = "Follow Mara's step before harvesting."
		return "tutorial"
	var resource_id := plot.resource_id
	var grown_grade := plot.grade
	var err := plot.harvest(inventory)
	if err != "":
		last_event = "The plot is not ready yet."
		return err
	var spec := ResourceCatalog.growth(resource_id)
	var label := str(ResourceCatalog.resources()[resource_id]["label"])
	last_event = "Harvested %d %s %s." % [
		int(spec["yield_amount"]),
		GradeScale.label(grown_grade),
		label,
	]
	tutorial.notify("harvested")
	return ""


func job_ticks(recipe_id: String) -> int:
	return WorkerPace.job_ticks(recipe_id, roster.assigned_worker(), _speed_bonus())


func start_bundle() -> String:
	return _start_recipe("bundle_fiber")


func start_cord() -> String:
	return _start_recipe("twist_cord")


func _start_recipe(recipe_id: String) -> String:
	var recipe := ResourceCatalog.recipe(recipe_id)
	if recipe.is_empty():
		return "unknown_recipe"
	var output_id := str(recipe["output_id"])
	var output_label := str(ResourceCatalog.resources()[output_id]["label"])
	if recipe_id == "bundle_fiber":
		if not tutorial.allows("workshop"):
			last_event = "Follow Mara's step before starting the workshop."
			return "tutorial"
	elif tutorial.step < TutorialTrack.DONE:
		last_event = "Finish Mara's lesson before making a %s." % output_label
		return "tutorial"
	var grades := {}
	for input in recipe["inputs"]:
		var resource_id := str(input["id"])
		var amount := int(input["amount"])
		var grade := inventory.lowest_grade_with(resource_id, amount)
		if grade == 0:
			var label := str(ResourceCatalog.resources()[resource_id]["label"])
			last_event = "Need %d %s." % [amount, label]
			return "missing_inputs"
		grades[resource_id] = grade
	var pace := job_ticks(recipe_id)
	var err := workshop.try_start(recipe_id, grades, pace)
	if err == "":
		if recipe_id == "bundle_fiber":
			tutorial.notify("started")
		last_event = "Workshop started. %d ticks until a %s." % [pace, output_label]
		return ""
	if err == "missing_inputs":
		last_event = "Need more inputs for a %s." % output_label
	elif err == "busy":
		last_event = "The workshop is already running."
	else:
		last_event = err
	return err


func fulfill_intro(game: SaveGame) -> String:
	return _fulfill_order("intro_bundle", game, true)


func fulfill_cord(game: SaveGame) -> String:
	if tutorial.step < TutorialTrack.DONE:
		last_event = "Follow Mara's step before delivering the cord."
		return "tutorial"
	return _fulfill_order("lane_cord", game, false)


func _fulfill_order(order_id: String, game: SaveGame, advances_tutorial: bool) -> String:
	if advances_tutorial and not tutorial.allows("order"):
		last_event = "Follow Mara's step before delivering."
		return "tutorial"
	var spec := ResourceCatalog.order(order_id)
	if spec.is_empty():
		last_event = "unknown_order"
		return "unknown_order"
	var result := orders.try_fulfill(order_id, inventory, game.funds)
	var err := str(result["error"])
	if err != "":
		if err == "missing_goods":
			var requires: Array = spec["requires"]
			var need_id := str(requires[0]["id"])
			var label := str(ResourceCatalog.resources()[need_id]["label"])
			last_event = "Need %d %s." % [int(requires[0]["amount"]), label]
		elif err == "already_done":
			last_event = "That order is already delivered."
		else:
			last_event = err
		return err
	game.funds = int(result["funds"])
	if advances_tutorial:
		tutorial.notify("sold")
	last_event = "Order paid %d." % int(spec["reward_funds"])
	return ""


func buy_loft(game: SaveGame) -> String:
	if not tutorial.allows("upgrade"):
		last_event = "Follow Mara's step before buying the loft."
		return "tutorial"
	var before := game.funds
	var result := upgrades.try_purchase("barn_loft", game.funds)
	var err := str(result["error"])
	if err != "":
		if err == "short_funds":
			last_event = "Not enough funds for the loft."
		elif err == "already_owned":
			last_event = "The loft is already built."
		else:
			last_event = err
		return err
	game.funds = int(result["funds"])
	tutorial.notify("upgraded")
	var spec := ResourceCatalog.upgrade("barn_loft")
	last_event = "Barn loft purchased for %d. Funds %d." % [int(spec["cost"]), game.funds]
	if game.funds != before - int(spec["cost"]):
		last_event = "Barn loft purchased for %d." % int(spec["cost"])
	return ""


func buy_shuttle(game: SaveGame) -> String:
	if tutorial.step < TutorialTrack.DONE:
		last_event = "Follow Mara's step before buying the shuttle rack."
		return "tutorial"
	if not upgrades.owns("barn_loft"):
		last_event = "Raise the loft before the shuttle rack."
		return "needs_loft"
	var before := game.funds
	var result := upgrades.try_purchase("shuttle_rack", game.funds)
	var err := str(result["error"])
	if err != "":
		if err == "short_funds":
			last_event = "Not enough funds for the shuttle rack."
		elif err == "already_owned":
			last_event = "The shuttle rack is already built."
		else:
			last_event = err
		return err
	game.funds = int(result["funds"])
	var spec := ResourceCatalog.upgrade("shuttle_rack")
	last_event = "Shuttle rack purchased for %d. Funds %d." % [int(spec["cost"]), game.funds]
	if game.funds != before - int(spec["cost"]):
		last_event = "Shuttle rack purchased for %d." % int(spec["cost"])
	return ""


func _speed_bonus() -> int:
	if not upgrades.owns("shuttle_rack"):
		return 0
	return int(ResourceCatalog.upgrade("shuttle_rack").get("speed_ticks", 0))


func hire_worker(worker_id: String) -> String:
	var err := roster.hire(worker_id)
	if err == "":
		var person := StaffCatalog.worker(worker_id)
		last_event = "Hired %s." % str(person["name"])
	elif err == "already_hired":
		last_event = "Already hired."
	else:
		last_event = "No such candidate."
	return err


func assign_workshop(worker_id: String) -> String:
	var err := roster.assign_workshop(worker_id)
	if err == "":
		var person := StaffCatalog.worker(worker_id)
		var pace := WorkerPace.bundle_ticks(person)
		last_event = "%s is at the workshop. A bundle takes %d ticks." % [str(person["name"]), pace]
	elif err == "not_hired":
		last_event = "Hire them first."
	else:
		last_event = "No such candidate."
	return err


func inventory_line() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for resource_id in ["verdant_fiber", "seal_wax", "packed_textile"]:
		var phrase := _stack_phrase(resource_id)
		if phrase != "":
			parts.append(phrase)
	for resource_id in ["fiber_bundle", "fiber_cord"]:
		var phrase := _stack_phrase(resource_id)
		if phrase == "":
			var label := str(ResourceCatalog.resources()[resource_id]["label"])
			parts.append("%s 0" % label)
		else:
			parts.append(phrase)
	return "Inventory: %s" % " · ".join(parts)


func _stack_phrase(resource_id: String) -> String:
	var bits: PackedStringArray = PackedStringArray()
	for grade in [GradeScale.COMMON, GradeScale.FINE, GradeScale.SELECT]:
		var count := inventory.amount(resource_id, grade)
		if count > 0:
			bits.append("%d %s" % [count, GradeScale.label(grade)])
	if bits.is_empty():
		return ""
	var label := str(ResourceCatalog.resources()[resource_id]["label"])
	return "%s %s" % [label, ", ".join(bits)]
