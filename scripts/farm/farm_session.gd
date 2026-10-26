class_name FarmSession
extends Node3D

## Playable farm. Reads the active save, shows it, and writes it back.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var library: FarmLibrary
var game: SaveGame
var persist := true
var grid := PlotGrid.new()

var _save_wait := 0.0

@onready var camera: Camera3D = $Stage/FarmCamera
@onready var farmhand: Node3D = $Stage/Farmhand
@onready var marker: Node3D = $PlaceholderPlotMarker
@onready var hover: Node3D = $PlaceholderPlotHover
@onready var selection_ring: Node3D = $PlaceholderSelectionRing
@onready var hud: FarmHud = $Hud


func _ready() -> void:
	if library == null:
		library = FarmLibrary.new()
	var keep_persist := persist
	if game == null:
		var active := library.active_id()
		if active != "":
			var loaded := library.load_farm(active)
			if loaded["ok"]:
				game = loaded["game"]
				persist = keep_persist
		if game == null:
			game = SaveGame.create_new("Sunny Rows", "tropical_valley")["game"]
			persist = false
	_apply_game()
	if not hud.remove_pressed.is_connected(_on_remove_marker):
		hud.remove_pressed.connect(_on_remove_marker)


func _process(delta: float) -> void:
	if game == null:
		return
	game.playtime_seconds += delta
	if not persist:
		return
	_save_wait += delta
	if _save_wait < 5.0:
		return
	_save_wait = 0.0
	_write()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			_leave()
		elif key.keycode == KEY_X:
			remove_marker()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			_click(button.position)
	elif event is InputEventMouseMotion:
		_hover((event as InputEventMouseMotion).position)


func place_marker_at(world_x: float, world_z: float) -> String:
	var cell := PlotGrid.snap_cell(world_x, world_z)
	if PlotGrid.blocked(cell):
		_set_barn_selected(true)
		return "blocked"
	_set_barn_selected(false)
	var err := grid.move_to(world_x, world_z) if grid.has_marker else grid.place_at(world_x, world_z)
	if err == "":
		_sync_marker()
		_write()
	return err


func remove_marker() -> String:
	var err := grid.remove()
	_sync_marker()
	if err == "":
		_write()
	return err


func _apply_game() -> void:
	grid.apply_save(game.marker)
	var saved: Dictionary = game.camera
	var focus: Array = saved.get("focus", [0.0, 1.2, 0.0])
	camera.focus = Vector3(float(focus[0]), float(focus[1]), float(focus[2]))
	camera.yaw = float(saved.get("yaw", camera.yaw))
	camera.pitch = float(saved.get("pitch", camera.pitch))
	camera.distance = float(saved.get("distance", camera.distance))
	camera.orbit(0.0, 0.0)
	_sync_marker()
	_set_barn_selected(false)
	hud.bind(game)


func _capture_state() -> void:
	game.camera = {
		"focus": [camera.focus.x, camera.focus.y, camera.focus.z],
		"yaw": camera.yaw,
		"pitch": camera.pitch,
		"distance": camera.distance,
	}
	game.marker = grid.to_save()


func _write() -> void:
	if not persist or game == null:
		return
	_capture_state()
	library.write(game)


func _leave() -> void:
	_write()
	get_tree().change_scene_to_file(MENU_SCENE)


func _click(screen_position: Vector2) -> void:
	var point: Variant = _ground_point(screen_position)
	if point == null:
		return
	var world := point as Vector3
	place_marker_at(world.x, world.z)


func _hover(screen_position: Vector2) -> void:
	var point: Variant = _ground_point(screen_position)
	if point == null:
		hover.visible = false
		return
	var world := point as Vector3
	var cell := PlotGrid.snap_cell(world.x, world.z)
	if PlotGrid.blocked(cell) or (grid.has_marker and grid.cell == cell):
		hover.visible = false
		return
	hover.visible = true
	hover.global_position = PlotGrid.cell_center(cell)


func _ground_point(screen_position: Vector2) -> Variant:
	var origin := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	return PlotGrid.ground_hit(origin, direction)


func _sync_marker() -> void:
	marker.visible = grid.has_marker
	if grid.has_marker:
		marker.global_position = PlotGrid.cell_center(grid.cell)
	if hud != null:
		hud.set_marker_available(grid.has_marker)
	if game != null:
		game.marker = grid.to_save()


func _set_barn_selected(selected: bool) -> void:
	selection_ring.visible = selected
	if hud != null:
		hud.set_barn_selected(selected)


func _on_remove_marker() -> void:
	remove_marker()
