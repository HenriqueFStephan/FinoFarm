class_name FarmHud
extends CanvasLayer

signal remove_pressed

var name_label: Label
var region_label: Label
var funds_label: Label
var remove_button: Button
var barn_label: Label


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

	barn_label = Label.new()
	barn_label.name = "BarnLabel"
	barn_label.position = Vector2(24, 78)
	barn_label.visible = false
	barn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barn_label.add_theme_font_size_override("font_size", 18)
	barn_label.add_theme_color_override("font_color", Color(0.98, 0.961, 0.902))
	barn_label.add_theme_color_override("font_shadow_color", Color(0.12, 0.14, 0.1, 0.85))
	barn_label.add_theme_constant_override("shadow_offset_x", 1)
	barn_label.add_theme_constant_override("shadow_offset_y", 1)
	barn_label.text = "Barn selected. Stylized storage building. Production is not in this milestone."
	root.add_child(barn_label)

	remove_button = Button.new()
	remove_button.name = "RemoveButton"
	remove_button.text = "Remove marker"
	remove_button.position = Vector2(24, 112)
	remove_button.visible = false
	remove_button.pressed.connect(func() -> void: remove_pressed.emit())
	_style_button(remove_button)
	root.add_child(remove_button)

	var hint := Label.new()
	hint.name = "Hint"
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -64
	hint.offset_bottom = -12
	hint.offset_left = 16
	hint.offset_right = -16
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.98, 0.961, 0.902))
	hint.add_theme_color_override("font_shadow_color", Color(0.12, 0.14, 0.1, 0.85))
	hint.add_theme_constant_override("shadow_offset_x", 1)
	hint.add_theme_constant_override("shadow_offset_y", 1)
	hint.text = "Left-click the ground to place or move one plot marker. X removes it. Click the barn to select it. Esc saves and returns to the menu.\nRight-drag or Q/E orbit    Middle-drag or WASD pan    Wheel or +/- zoom"
	root.add_child(hint)


func bind(game: SaveGame) -> void:
	name_label.text = game.farm_name
	var region := RegionCatalog.get_region(game.region_id)
	region_label.text = str(region.get("display_name", game.region_id))
	funds_label.text = "Funds %d" % game.funds


func set_marker_available(has_marker: bool) -> void:
	remove_button.visible = has_marker


func set_barn_selected(selected: bool) -> void:
	barn_label.visible = selected


func _fact(row: HBoxContainer, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.23, 0.16, 0.1))
	row.add_child(label)
	return label


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.953, 0.902, 0.784, 0.94)
	box.corner_radius_top_left = 12
	box.corner_radius_top_right = 12
	box.corner_radius_bottom_left = 12
	box.corner_radius_bottom_right = 12
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box


func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
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
	button.add_theme_color_override("font_color", Color(0.23, 0.14, 0.08))
	button.add_theme_font_size_override("font_size", 16)
