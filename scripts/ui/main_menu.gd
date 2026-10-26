class_name MainMenu
extends Node3D

## Main menu over the 3D farm. New Game asks for a name, then a region.

const FARM_SCENE := "res://scenes/farm/first_farm.tscn"

var library: FarmLibrary
var continue_button: Button
var region_detail: Label
var error_label: Label
var name_edit: LineEdit

var _screens: Dictionary = {}
var _region_id := ""
var _card_box: VBoxContainer
var _confirm_button: Button


func _ready() -> void:
	if library == null:
		library = FarmLibrary.new()
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)
	var root := Control.new()
	root.name = "MenuRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_screens["home"] = _build_home(root)
	_screens["farms"] = _build_farms(root)
	_screens["name"] = _build_name(root)
	_screens["map"] = _build_map(root)
	_screens["settings"] = _build_text_screen(
		root,
		"settings",
		"Settings",
		"Camera: right-drag or Q and E orbit, R and F change pitch, middle-drag or WASD pans, and the wheel or plus and minus zooms. Audio controls are not in this build."
	)
	_screens["credits"] = _build_text_screen(
		root,
		"credits",
		"Credits",
		"FinoFarm. The barn and the farmhand were modeled in Blender for this project. Terrain, trees, and the plot marker are still placeholders. No third-party model packs are in this build."
	)
	_show("home")


func try_create(farm_name: String, region_id: String) -> String:
	var created := SaveGame.create_new(farm_name, region_id)
	if not created["ok"]:
		return str(created["error"])
	var err := library.write(created["game"])
	if err != "":
		return err
	_refresh_continue()
	return ""


func select_region(region_id: String) -> void:
	_region_id = region_id
	var region := RegionCatalog.get_region(region_id)
	if region.is_empty():
		region_detail.text = ""
		_confirm_button.disabled = true
		return
	region_detail.text = detail_text(region)
	_confirm_button.disabled = _typed_name() == ""
	for id in RegionCatalog.ids():
		var button := find_child("Region_%s" % id, true, false) as Button
		if button == null:
			continue
		button.modulate = Color(1, 0.86, 0.62) if id == region_id else Color.WHITE


func show_farms() -> void:
	_rebuild_cards()
	_show("farms")


func show_settings() -> void:
	_show("settings")


func show_credits() -> void:
	_show("credits")


func show_map() -> void:
	_show("map")
	_confirm_button.disabled = _typed_name() == "" or _region_id == ""


func activate(farm_id: String) -> String:
	return library.set_active(farm_id)


static func detail_text(region: Dictionary) -> String:
	return "\n".join([
		str(region["display_name"]),
		"Climate: %s" % str(region["climate_label"]),
		"Season amplitude: %s" % str(region["season_amplitude"]),
		"Property cost: %d" % int(region["property_cost"]),
		"Upkeep: x%s" % str(region["upkeep_modifier"]),
		"Infrastructure: %s" % RegionCatalog.difficulty_label(float(region["infrastructure_difficulty"])),
		"Starting funds: %d" % int(region["starting_funds"]),
		"",
		"Opportunity: %s" % str(region["opportunity"]),
		"Challenge: %s" % str(region["challenge"]),
		"",
		"Gameplay tuning, not a geographic claim.",
	])


func _build_home(root: Control) -> PanelContainer:
	var panel := _panel(root, "Home", Vector2(48, 40), 420)
	var box := _column(panel)
	var title := Label.new()
	title.text = "FinoFarm"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.45, 0.24, 0.16))
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Start a farm and walk the grounds."
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.32, 0.24, 0.16))
	box.add_child(subtitle)
	continue_button = _menu_button(box, "ContinueButton", "Continue", _on_continue)
	_menu_button(box, "MyFarmsButton", "My Farms", show_farms)
	_menu_button(box, "NewGameButton", "New Game", func() -> void: _show("name"))
	_menu_button(box, "SettingsButton", "Settings", show_settings)
	_menu_button(box, "CreditsButton", "Credits", show_credits)
	_menu_button(box, "ExitButton", "Exit", _on_exit)
	_refresh_continue()
	return panel


func _build_farms(root: Control) -> PanelContainer:
	var panel := _panel(root, "Farms", Vector2(48, 36), 520)
	var box := _column(panel)
	box.add_child(_heading("My Farms"))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(460, 460)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_card_box = VBoxContainer.new()
	_card_box.name = "CardBox"
	_card_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_card_box.add_theme_constant_override("separation", 10)
	scroll.add_child(_card_box)
	_menu_button(box, "FarmsBack", "Back", func() -> void: _show("home"))
	return panel


func _build_name(root: Control) -> PanelContainer:
	var panel := _panel(root, "Name", Vector2(48, 48), 480)
	var box := _column(panel)
	box.add_child(_heading("Name your farm"))
	name_edit = LineEdit.new()
	name_edit.name = "FarmNameEdit"
	name_edit.placeholder_text = "Farm name"
	name_edit.max_length = 32
	name_edit.custom_minimum_size = Vector2(0, 44)
	name_edit.text_changed.connect(func(_text: String) -> void: _refresh_name_next())
	box.add_child(name_edit)
	var next_button := _menu_button(box, "NameNext", "Choose region", show_map)
	next_button.disabled = true
	_menu_button(box, "NameBack", "Back", func() -> void: _show("home"))
	return panel


func _build_map(root: Control) -> PanelContainer:
	var panel := _panel(root, "Map", Vector2(48, 28), 980)
	var box := _column(panel)
	box.add_child(_heading("Choose a region"))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 18)
	box.add_child(columns)
	var pad := Control.new()
	pad.name = "MapPad"
	pad.custom_minimum_size = Vector2(460, 340)
	columns.add_child(pad)
	for region in RegionCatalog.all():
		var button := Button.new()
		button.name = "Region_%s" % str(region["id"])
		button.text = str(region["display_name"])
		button.position = Vector2(float(region["map_x"]) * 250.0, float(region["map_y"]) * 250.0)
		button.custom_minimum_size = Vector2(190, 48)
		button.pressed.connect(select_region.bind(str(region["id"])))
		_paint_button(button)
		pad.add_child(button)
	var side := VBoxContainer.new()
	side.custom_minimum_size = Vector2(420, 340)
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(side)
	region_detail = Label.new()
	region_detail.name = "RegionDetail"
	region_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	region_detail.custom_minimum_size = Vector2(400, 250)
	region_detail.add_theme_font_size_override("font_size", 16)
	region_detail.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	region_detail.text = "Select a marker. The four regions are gameplay settings."
	side.add_child(region_detail)
	error_label = Label.new()
	error_label.name = "CreateError"
	error_label.add_theme_color_override("font_color", Color(0.55, 0.22, 0.14))
	side.add_child(error_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	box.add_child(actions)
	_menu_button(actions, "MapBack", "Back", func() -> void: _show("name"))
	_confirm_button = _menu_button(actions, "ConfirmFarm", "Start farm", _on_confirm)
	_confirm_button.disabled = true
	return panel


func _build_text_screen(root: Control, screen_name: String, title: String, body: String) -> PanelContainer:
	var panel := _panel(root, screen_name.capitalize(), Vector2(48, 48), 640)
	var box := _column(panel)
	box.add_child(_heading(title))
	var label := Label.new()
	label.name = "%sBody" % screen_name.capitalize()
	label.text = body
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(560, 120)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	box.add_child(label)
	_menu_button(box, "%sBack" % screen_name.capitalize(), "Back", func() -> void: _show("home"))
	return panel


func _rebuild_cards() -> void:
	for child in _card_box.get_children():
		_card_box.remove_child(child)
		child.free()
	var rows := library.summaries()
	if rows.is_empty():
		var empty := Label.new()
		empty.text = "No farms yet."
		empty.add_theme_color_override("font_color", Color(0.32, 0.24, 0.16))
		_card_box.add_child(empty)
		return
	for row in rows:
		var button := Button.new()
		button.name = "Card_%s" % str(row["farm_id"])
		button.text = SaveGame.card_text(row)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(430, 96)
		button.add_to_group("farm_card")
		var farm_id := str(row["farm_id"])
		button.pressed.connect(func() -> void: _open_card(farm_id))
		_paint_button(button)
		_card_box.add_child(button)


func _open_card(farm_id: String) -> void:
	var err := activate(farm_id)
	if err != "":
		return
	_open_farm()


func _on_confirm() -> void:
	var err := try_create(_typed_name(), _region_id)
	if err != "":
		error_label.text = _friendly(err)
		return
	error_label.text = ""
	_open_farm()


func _on_continue() -> void:
	if library.active_id() == "":
		return
	_open_farm()


func _on_exit() -> void:
	get_tree().quit()


func _open_farm() -> void:
	get_tree().change_scene_to_file(FARM_SCENE)


func _typed_name() -> String:
	if name_edit == null:
		return ""
	return name_edit.text.strip_edges()


func _refresh_name_next() -> void:
	var next := find_child("NameNext", true, false) as Button
	if next != null:
		next.disabled = _typed_name() == ""


func _refresh_continue() -> void:
	if continue_button == null:
		return
	continue_button.disabled = library.list_ids().is_empty()


func _show(screen_name: String) -> void:
	for key in _screens.keys():
		(_screens[key] as CanvasItem).visible = key == screen_name
	if screen_name == "home":
		_refresh_continue()


func _friendly(code: String) -> String:
	match code:
		"name_required":
			return "Enter a farm name."
		"name_too_long":
			return "Use 32 characters or fewer."
		"unknown_region":
			return "Choose a region."
		_:
			return "Could not create the farm."


func _panel(root: Control, node_name: String, origin: Vector2, width: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.position = origin
	panel.custom_minimum_size = Vector2(width, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)
	return panel


func _column(panel: PanelContainer) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	return box


func _heading(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(0.45, 0.24, 0.16))
	return label


func _menu_button(parent: Node, node_name: String, text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(0, 46)
	button.pressed.connect(handler)
	_paint_button(button)
	parent.add_child(button)
	return button


func _paint_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _button_style(Color(0.99, 0.96, 0.9, 1)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.9, 0.72, 0.4, 1)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.84, 0.62, 0.28, 1)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.78, 0.74, 0.66, 0.85)))
	button.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	button.add_theme_color_override("font_disabled_color", Color(0.4, 0.34, 0.28, 0.8))
	button.add_theme_font_size_override("font_size", 18)


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.953, 0.902, 0.784, 0.94)
	box.corner_radius_top_left = 18
	box.corner_radius_top_right = 18
	box.corner_radius_bottom_left = 18
	box.corner_radius_bottom_right = 18
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 18
	box.content_margin_bottom = 18
	box.shadow_color = Color(0.12, 0.1, 0.08, 0.25)
	box.shadow_size = 12
	box.shadow_offset = Vector2(0, 4)
	return box


func _button_style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_left = 10
	box.corner_radius_bottom_right = 10
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box
