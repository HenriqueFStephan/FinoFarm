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


func read_from(game: SaveGame) -> String:
	if not game.read_inventory_into(inventory):
		return "bad_inventory"
	game.read_workshop_into(workshop)
	plot.import_state(game.plot)
	orders.import_state(game.orders)
	upgrades.import_state(game.upgrades)
	tutorial.step = clampi(game.tutorial_step, 0, TutorialTrack.DONE)
	return ""


func write_to(game: SaveGame) -> void:
	game.write_inventory_from(inventory)
	game.write_workshop_from(workshop)
	game.plot = plot.export_state()
	game.orders = orders.export_state()
	game.upgrades = upgrades.export_state()
	game.tutorial_step = tutorial.step


func advance(delta_seconds: float) -> void:
	var was_ready := plot.is_ready()
	var was_busy := workshop.is_busy()
	stepper.step(delta_seconds)
	if not was_ready and plot.is_ready():
		tutorial.notify("ready")
		last_event = "The fiber plot is ready."
	if was_busy and not workshop.is_busy():
		tutorial.notify("bundled")
		last_event = "The workshop finished a Fiber Bundle."


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


func start_bundle() -> String:
	if not tutorial.allows("workshop"):
		last_event = "Follow Mara's step before starting the workshop."
		return "tutorial"
	var recipe := ResourceCatalog.recipe("bundle_fiber")
	if recipe.is_empty():
		return "unknown_recipe"
	var inputs: Array = recipe["inputs"]
	var resource_id := str(inputs[0]["id"])
	var amount := int(inputs[0]["amount"])
	var grade := inventory.lowest_grade_with(resource_id, amount)
	if grade == 0:
		last_event = "Need %d Verdant Fiber." % amount
		return "missing_inputs"
	var err := workshop.try_start("bundle_fiber", {resource_id: grade})
	if err == "":
		tutorial.notify("started")
		last_event = "Workshop started. %d ticks until a Fiber Bundle." % int(recipe["duration_ticks"])
		return ""
	if err == "missing_inputs":
		last_event = "Need %d Verdant Fiber." % amount
	elif err == "busy":
		last_event = "The workshop is already running."
	else:
		last_event = err
	return err


func fulfill_intro(game: SaveGame) -> String:
	if not tutorial.allows("order"):
		last_event = "Follow Mara's step before delivering."
		return "tutorial"
	var result := orders.try_fulfill("intro_bundle", inventory, game.funds)
	var err := str(result["error"])
	if err != "":
		if err == "missing_goods":
			last_event = "Need 1 Fiber Bundle."
		elif err == "already_done":
			last_event = "That order is already delivered."
		else:
			last_event = err
		return err
	game.funds = int(result["funds"])
	tutorial.notify("sold")
	var spec := ResourceCatalog.order("intro_bundle")
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


func inventory_line() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for resource_id in ["verdant_fiber", "seal_wax", "fiber_bundle", "packed_textile"]:
		var bits: PackedStringArray = PackedStringArray()
		for grade in [GradeScale.COMMON, GradeScale.FINE, GradeScale.SELECT]:
			var count := inventory.amount(resource_id, grade)
			if count > 0:
				bits.append("%d %s" % [count, GradeScale.label(grade)])
		if bits.size() > 0:
			var label := str(ResourceCatalog.resources()[resource_id]["label"])
			parts.append("%s %s" % [label, ", ".join(bits)])
	if parts.is_empty():
		return "Inventory: empty"
	return "Inventory: %s" % " · ".join(parts)
