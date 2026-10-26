class_name FarmHud
extends CanvasLayer

signal remove_pressed
signal harvest_pressed
signal workshop_pressed
signal workshop_start_pressed
signal workshop_cord_pressed
signal orders_pressed
signal order_deliver_pressed
signal order_deliver_cord_pressed
signal upgrade_pressed
signal crew_pressed
signal hire_requested(worker_id: String)
signal assign_requested(worker_id: String)

var name_label: Label
var region_label: Label
var funds_label: Label
var inventory_label: Label
var tutorial_label: Label
var ledger_label: Label
var barn_label: Label
var remove_button: Button
var harvest_button: Button
var workshop_button: Button
var orders_button: Button
var upgrade_button: Button
var workshop_panel: PanelContainer
var workshop_body: Label
var workshop_start: Button
var workshop_cord: Button
var order_panel: PanelContainer
var order_body: Label
var order_deliver: Button
var order_deliver_cord: Button
var crew_button: Button
var crew_panel: PanelContainer
var workshop_open := false
var orders_open := false
var crew_open := false
var _crew_labels := {}
var _hire_buttons := {}
var _assign_buttons := {}


func _ready() -> void:
	var root := Control.new()
	root.name = "HudRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top := PanelContainer.new()
	top.name = "Top"
	top.position = Vector2(24, 18)
	top.mouse_filter = Control.MOUSE_FILTER_STOP
	top.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(top)

	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 22)
	top.add_child(row)

	name_label = _fact(row, "NameLabel")
	region_label = _fact(row, "RegionLabel")
	funds_label = _fact(row, "FundsLabel")

	inventory_label = _shadow_label("InventoryLabel")
	inventory_label.position = Vector2(24, 78)
	inventory_label.add_theme_font_size_override("font_size", 16)
	root.add_child(inventory_label)

	var tutorial := PanelContainer.new()
	tutorial.name = "TutorialPanel"
	tutorial.position = Vector2(24, 112)
	tutorial.custom_minimum_size = Vector2(460, 0)
	tutorial.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(tutorial)

	tutorial_label = Label.new()
	tutorial_label.name = "TutorialText"
	tutorial_label.custom_minimum_size = Vector2(428, 0)
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.add_theme_font_size_override("font_size", 18)
	tutorial_label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	tutorial.add_child(tutorial_label)

	ledger_label = _shadow_label("LedgerLabel")
	ledger_label.position = Vector2(24, 230)
	ledger_label.custom_minimum_size = Vector2(480, 0)
	ledger_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ledger_label.add_theme_font_size_override("font_size", 16)
	root.add_child(ledger_label)

	barn_label = _shadow_label("BarnLabel")
	barn_label.position = Vector2(24, 268)
	barn_label.visible = false
	barn_label.add_theme_font_size_override("font_size", 16)
	root.add_child(barn_label)

	remove_button = Button.new()
	remove_button.name = "RemoveButton"
	remove_button.text = "Remove plot"
	remove_button.position = Vector2(24, 300)
	remove_button.visible = false
	remove_button.pressed.connect(func() -> void: remove_pressed.emit())
	_style_button(remove_button, false)
	root.add_child(remove_button)

	var column := VBoxContainer.new()
	column.name = "ActionColumn"
	column.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	column.offset_left = -196
	column.offset_top = 18
	column.offset_right = -24
	column.add_theme_constant_override("separation", 8)
	column.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(column)

	harvest_button = _action(column, "HarvestButton", "Harvest fiber")
	harvest_button.pressed.connect(func() -> void: harvest_pressed.emit())
	workshop_button = _action(column, "WorkshopButton", "Workshop")
	workshop_button.pressed.connect(func() -> void: workshop_pressed.emit())
	orders_button = _action(column, "OrdersButton", "Order board")
	orders_button.pressed.connect(func() -> void: orders_pressed.emit())
	upgrade_button = _action(column, "UpgradeButton", "Buy barn loft")
	upgrade_button.pressed.connect(func() -> void: upgrade_pressed.emit())
	crew_button = _action(column, "CrewButton", "Crew")
	crew_button.visible = false
	crew_button.pressed.connect(func() -> void: crew_pressed.emit())

	workshop_panel = _card(root, "WorkshopPanel", Vector2(430, 150))
	var workshop_title := _card_title(workshop_panel, "WorkshopTitle", "Textile workshop")
	workshop_title.text = "Textile workshop"
	workshop_body = _card_body(workshop_panel, "WorkshopBody")
	var workshop_row := HBoxContainer.new()
	workshop_row.add_theme_constant_override("separation", 8)
	workshop_panel.get_node("Box").add_child(workshop_row)
	workshop_start = _action(workshop_row, "WorkshopStart", "Start bundle")
	workshop_start.pressed.connect(func() -> void: workshop_start_pressed.emit())
	workshop_cord = _action(workshop_row, "WorkshopCord", "Start cord")
	workshop_cord.pressed.connect(func() -> void: workshop_cord_pressed.emit())
	var workshop_close := _action(workshop_row, "WorkshopClose", "Close")
	workshop_close.pressed.connect(func() -> void: _set_workshop_open(false))

	order_panel = _card(root, "OrderPanel", Vector2(430, 300))
	_card_title(order_panel, "OrderTitle", "Order board")
	order_body = _card_body(order_panel, "OrderBody")
	var order_row := VBoxContainer.new()
	order_row.add_theme_constant_override("separation", 8)
	order_panel.get_node("Box").add_child(order_row)
	order_deliver = _action(order_row, "OrderDeliver", "Deliver bundle")
	order_deliver.pressed.connect(func() -> void: order_deliver_pressed.emit())
	order_deliver_cord = _action(order_row, "OrderDeliverCord", "Deliver cord")
	order_deliver_cord.pressed.connect(func() -> void: order_deliver_cord_pressed.emit())
	var order_close := _action(order_row, "OrderClose", "Close")
	order_close.pressed.connect(func() -> void: _set_orders_open(false))

	_build_crew(root)

	var hint := _shadow_label("Hint")
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -52
	hint.offset_bottom = -12
	hint.offset_left = 16
	hint.offset_right = -16
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 15)
	hint.text = "Left-click open ground to place the fiber plot. Click the workshop shed to bundle. X removes the plot. Esc saves and returns.\nAfter Mara's lesson, choose a Fiber Bundle or a Fiber Cord. One harvest cannot fill both orders. Crew hires a worker. Right-drag or Q/E orbit. Middle-drag or WASD pan. Wheel or +/- zoom."
	root.add_child(hint)


func bind(game: SaveGame) -> void:
	name_label.text = game.farm_name
	var region := RegionCatalog.get_region(game.region_id)
	region_label.text = str(region.get("display_name", game.region_id))
	funds_label.text = "Funds %d" % game.funds


func refresh(game: SaveGame, loop: FarmLoop, barn_selected: bool) -> void:
	bind(game)
	inventory_label.text = loop.inventory_line()
	tutorial_label.text = loop.tutorial.prompt()
	ledger_label.text = loop.last_event
	var step := loop.tutorial.step
	var ready := loop.plot.is_ready()
	harvest_button.visible = ready and loop.tutorial.allows("harvest")
	workshop_button.visible = step >= TutorialTrack.WORKSHOP
	orders_button.visible = step >= TutorialTrack.ORDER
	var loft_open := step >= TutorialTrack.UPGRADE and not loop.upgrades.owns("barn_loft")
	var rack_open := (
		step >= TutorialTrack.DONE
		and loop.upgrades.owns("barn_loft")
		and not loop.upgrades.owns("shuttle_rack")
	)
	upgrade_button.visible = loft_open or rack_open
	if rack_open:
		var rack_cost := int(ResourceCatalog.upgrade("shuttle_rack")["cost"])
		upgrade_button.text = "Buy shuttle rack (%d)" % rack_cost
	else:
		upgrade_button.text = "Buy barn loft"
	_style_button(harvest_button, step == TutorialTrack.HARVEST)
	_style_button(workshop_button, step == TutorialTrack.WORKSHOP or step == TutorialTrack.BUNDLE)
	_style_button(orders_button, step == TutorialTrack.ORDER)
	_style_button(upgrade_button, step == TutorialTrack.UPGRADE or rack_open)
	crew_button.visible = step >= TutorialTrack.DONE
	_style_button(crew_button, step >= TutorialTrack.DONE and loop.roster.workshop_worker_id == "")
	_fill_crew(loop)
	barn_label.visible = barn_selected
	if barn_selected:
		if loop.upgrades.owns("barn_loft"):
			barn_label.text = "Barn selected. The loft is built."
		else:
			var cost := int(ResourceCatalog.upgrade("barn_loft")["cost"])
			barn_label.text = "Barn selected. The loft costs %d." % cost
	_fill_workshop(loop)
	_fill_order(loop)
	workshop_panel.visible = workshop_open
	order_panel.visible = orders_open
	crew_panel.visible = crew_open


func set_marker_available(has_marker: bool) -> void:
	remove_button.visible = has_marker


func set_barn_selected(selected: bool) -> void:
	barn_label.visible = selected


func open_workshop(open: bool) -> void:
	_set_workshop_open(open)


func open_orders(open: bool) -> void:
	_set_orders_open(open)


func open_crew(open: bool) -> void:
	_set_crew_open(open)


func _set_workshop_open(open: bool) -> void:
	workshop_open = open
	workshop_panel.visible = open
	if open:
		orders_open = false
		order_panel.visible = false
		_close_crew()


func _set_orders_open(open: bool) -> void:
	orders_open = open
	order_panel.visible = open
	if open:
		workshop_open = false
		workshop_panel.visible = false
		_close_crew()


func _fill_workshop(loop: FarmLoop) -> void:
	var bundle_pace := loop.job_ticks("bundle_fiber")
	var cord_pace := loop.job_ticks("twist_cord")
	var line := "Choose one good. Both spend 2 Verdant Fiber.\nFiber Bundle: %d ticks. Fiber Cord: %d ticks." % [bundle_pace, cord_pace]
	var person := loop.roster.assigned_worker()
	if person.is_empty():
		line += "\nNo one is assigned. The bench runs at the lesson pace."
	else:
		line += "\n%s is assigned." % str(person["name"])
	if loop.upgrades.owns("shuttle_rack"):
		line += "\nShuttle rack: the next job is one tick faster."
	if loop.workshop.is_busy():
		line += "\nRunning. %d ticks left." % loop.workshop.ticks_remaining
	else:
		line += "\nIdle."
	if loop.tutorial.step < TutorialTrack.DONE:
		line += "\nThe cord waits until Mara's lesson is done."
	workshop_body.text = line
	workshop_start.disabled = loop.workshop.is_busy() or not loop.tutorial.allows("workshop")
	workshop_cord.disabled = loop.workshop.is_busy() or loop.tutorial.step < TutorialTrack.DONE


func _fill_order(loop: FarmLoop) -> void:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("One harvest of Verdant Fiber covers one of these goods.")
	for spec in ResourceCatalog.orders():
		var order_id := str(spec["id"])
		var state := str(loop.orders.status.get(order_id, "open"))
		var requires: Array = spec["requires"]
		var need_id := str(requires[0]["id"])
		var need_label := str(ResourceCatalog.resources()[need_id]["label"])
		var need_amount := int(requires[0]["amount"])
		var block := "%s\n%s\nReward %d." % [str(spec["label"]), str(spec["detail"]), int(spec["reward_funds"])]
		if state == "done":
			block += "\nDelivered."
		elif _order_ready(loop, order_id):
			block += "\nOpen. Ready to deliver %d %s." % [need_amount, need_label]
		else:
			block += "\nOpen. Needs %d %s." % [need_amount, need_label]
		lines.append(block)
	lines.append("On hand: %s · %s" % [_good_count(loop, "fiber_bundle"), _good_count(loop, "fiber_cord")])
	order_body.text = "\n\n".join(lines)
	order_deliver.disabled = not _order_ready(loop, "intro_bundle")
	order_deliver_cord.disabled = not _order_ready(loop, "lane_cord")


func _order_ready(loop: FarmLoop, order_id: String) -> bool:
	if str(loop.orders.status.get(order_id, "")) != "open":
		return false
	if order_id == "intro_bundle":
		if not loop.tutorial.allows("order"):
			return false
	elif loop.tutorial.step < TutorialTrack.DONE:
		return false
	var spec := ResourceCatalog.order(order_id)
	if spec.is_empty():
		return false
	for input in spec["requires"]:
		if loop.inventory.lowest_grade_with(str(input["id"]), int(input["amount"])) == 0:
			return false
	return true


func _good_count(loop: FarmLoop, resource_id: String) -> String:
	var total := 0
	for grade in [GradeScale.COMMON, GradeScale.FINE, GradeScale.SELECT]:
		total += loop.inventory.amount(resource_id, grade)
	var label := str(ResourceCatalog.resources()[resource_id]["label"])
	return "%s %d" % [label, total]


func _build_crew(root: Control) -> void:
	crew_panel = _card(root, "CrewPanel", Vector2(430, 150))
	_card_title(crew_panel, "CrewTitle", "Recruitment")
	var intro := Label.new()
	intro.name = "CrewIntro"
	intro.custom_minimum_size = Vector2(348, 0)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override("font_size", 15)
	intro.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	intro.text = "Six ratings, each from 1 to 10. A higher total finishes a Fiber Bundle sooner. Listed wages are not charged."
	crew_panel.get_node("Box").add_child(intro)
	for person in StaffCatalog.workers():
		var worker_id := str(person["id"])
		var block := Label.new()
		block.name = "Crew_%s" % worker_id
		block.custom_minimum_size = Vector2(348, 0)
		block.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		block.add_theme_font_size_override("font_size", 15)
		block.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
		crew_panel.get_node("Box").add_child(block)
		_crew_labels[worker_id] = block
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		crew_panel.get_node("Box").add_child(row)
		var hire := _action(row, "Hire_%s" % worker_id, "Hire")
		_wire_hire(hire, worker_id)
		_hire_buttons[worker_id] = hire
		var assign := _action(row, "Assign_%s" % worker_id, "Assign to workshop")
		_wire_assign(assign, worker_id)
		_assign_buttons[worker_id] = assign
	var close := _action(crew_panel.get_node("Box"), "CrewClose", "Close")
	close.pressed.connect(func() -> void: _set_crew_open(false))


func _wire_hire(button: Button, worker_id: String) -> void:
	button.pressed.connect(func() -> void: hire_requested.emit(worker_id))


func _wire_assign(button: Button, worker_id: String) -> void:
	button.pressed.connect(func() -> void: assign_requested.emit(worker_id))


func _fill_crew(loop: FarmLoop) -> void:
	for person in StaffCatalog.workers():
		var worker_id := str(person["id"])
		var hired := loop.roster.hired.has(worker_id)
		var assigned := loop.roster.workshop_worker_id == worker_id
		var label := _crew_labels[worker_id] as Label
		label.text = _crew_text(person, hired, assigned)
		(_hire_buttons[worker_id] as Button).visible = not hired
		(_assign_buttons[worker_id] as Button).visible = hired and not assigned


func _crew_text(person: Dictionary, hired: bool, assigned: bool) -> String:
	var lines := StaffCatalog.attribute_lines(person)
	var ticks := WorkerPace.bundle_ticks(person)
	var status := "Not hired."
	if assigned:
		status = "At the workshop."
	elif hired:
		status = "Hired. Not assigned."
	var trait_bits: PackedStringArray = PackedStringArray()
	var raw_traits: Array = person["traits"]
	for bit in raw_traits:
		trait_bits.append(str(bit))
	return "%s — %s\n%s\n%s\n%s\nTotal %d · bundle %d ticks · wage %d listed\n%s" % [
		str(person["name"]),
		str(person["role"]),
		str(person["background"]),
		lines[0],
		lines[1],
		StaffCatalog.attribute_total(person),
		ticks,
		int(person["wage"]),
		status + " " + ", ".join(trait_bits),
	]


func _set_crew_open(open: bool) -> void:
	crew_open = open
	if crew_panel != null:
		crew_panel.visible = open
	if open:
		workshop_open = false
		orders_open = false
		if workshop_panel != null:
			workshop_panel.visible = false
		if order_panel != null:
			order_panel.visible = false


func _close_crew() -> void:
	crew_open = false
	if crew_panel != null:
		crew_panel.visible = false


func _fact(row: HBoxContainer, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	row.add_child(label)
	return label


func _shadow_label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", Color(0.98, 0.961, 0.902))
	label.add_theme_color_override("font_shadow_color", Color(0.12, 0.14, 0.1, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _action(parent: Node, node_name: String, text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	_style_button(button, false)
	parent.add_child(button)
	return button


func _card(root: Control, node_name: String, origin: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.position = origin
	panel.custom_minimum_size = Vector2(380, 0)
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(panel)
	var box := VBoxContainer.new()
	box.name = "Box"
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	return panel


func _card_title(panel: PanelContainer, node_name: String, text: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	panel.get_node("Box").add_child(label)
	return label


func _card_body(panel: PanelContainer, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.custom_minimum_size = Vector2(348, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	panel.get_node("Box").add_child(label)
	return label


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.953, 0.902, 0.784, 0.94)
	box.border_color = Color(0.776, 0.478, 0.18, 1)
	box.border_width_left = 2
	box.border_width_top = 2
	box.border_width_right = 2
	box.border_width_bottom = 2
	box.corner_radius_top_left = 12
	box.corner_radius_top_right = 12
	box.corner_radius_bottom_left = 12
	box.corner_radius_bottom_right = 12
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box


func _style_button(button: Button, emphasized: bool) -> void:
	var normal := StyleBoxFlat.new()
	if emphasized:
		normal.bg_color = Color(0.92, 0.72, 0.28, 1)
	else:
		normal.bg_color = Color(0.84, 0.62, 0.28, 1)
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", normal)
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.72, 0.66, 0.56, 1)
	disabled.corner_radius_top_left = 8
	disabled.corner_radius_top_right = 8
	disabled.corner_radius_bottom_left = 8
	disabled.corner_radius_bottom_right = 8
	disabled.content_margin_left = 12
	disabled.content_margin_right = 12
	disabled.content_margin_top = 6
	disabled.content_margin_bottom = 6
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(0.23, 0.14, 0.08))
	button.add_theme_color_override("font_disabled_color", Color(0.35, 0.28, 0.2))
	button.add_theme_font_size_override("font_size", 16)
