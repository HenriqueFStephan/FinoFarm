class_name FarmSession
extends Node3D

## Playable farm. Reads the active save, runs the textile loop, and writes it back.

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

var library: FarmLibrary
var game: SaveGame
var persist := true
var grid := PlotGrid.new()
var loop := FarmLoop.new()

var _save_wait := 0.0
var _barn_selected := false

@onready var camera: Camera3D = $Stage/FarmCamera
@onready var farmhand: Node3D = $Stage/Farmhand
@onready var marker: Node3D = $PlaceholderPlotMarker
@onready var hover: Node3D = $PlaceholderPlotHover
@onready var selection_ring: Node3D = $PlaceholderSelectionRing
@onready var crop: CropVisual = $PlaceholderCrop
@onready var workshop_rig: WorkshopRig = $PlaceholderWorkshop
@onready var workshop_worker: WorkshopWorker = $WorkshopWorker
@onready var loft: Node3D = $PlaceholderBarnLoft
@onready var shuttle_rack: Node3D = $PlaceholderShuttleRack
@onready var packing_bench: PackingRig = $PackingBench
@onready var packing_clerk: PackingClerk = $PackingClerk
@onready var hud: FarmHud = $Hud

var _audio: AudioStreamPlayer
var _streams := {}


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
	if loop.read_from(game) != "":
		push_error("farm loop could not read the save")
	_audio = AudioStreamPlayer.new()
	_audio.name = "CuePlayer"
	add_child(_audio)
	_streams = {
		"harvest": load("res://assets/audio/harvest_tone.wav"),
		"loom": load("res://assets/audio/loom_tone.wav"),
		"delivery": load("res://assets/audio/delivery_tone.wav"),
	}
	_connect_hud()
	_apply_game()


func _process(delta: float) -> void:
	if game == null:
		return
	game.playtime_seconds += delta
	var before := loop.clock.tick_index
	loop.advance(delta)
	loop.charge_wages(game, loop.clock.tick_index - before)
	refresh_presentation()
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
		_set_workshop_selected(false)
		return "blocked"
	if _on_workshop_cell(cell):
		_set_barn_selected(false)
		_set_workshop_selected(true)
		hud.open_workshop(true)
		return "workshop"
	_set_barn_selected(false)
	_set_workshop_selected(false)
	var err := grid.move_to(world_x, world_z) if grid.has_marker else grid.place_at(world_x, world_z)
	if err == "":
		loop.plant_if_needed()
		_sync_marker()
		refresh_presentation()
		_write()
	return err


func remove_marker() -> String:
	var err := grid.remove()
	if err == "":
		loop.uproot()
		_sync_marker()
		refresh_presentation()
		_write()
	return err


func harvest_plot() -> String:
	var err := loop.harvest()
	refresh_presentation()
	if err == "":
		_write()
	return err


func start_workshop() -> String:
	var err := loop.start_bundle()
	refresh_presentation()
	if err == "":
		_write()
	return err


func start_cord() -> String:
	var err := loop.start_cord()
	refresh_presentation()
	if err == "":
		_write()
	return err


func fulfill_order() -> String:
	var err := loop.fulfill_intro(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func fulfill_cord() -> String:
	var err := loop.fulfill_cord(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func buy_loft() -> String:
	var err := loop.buy_loft(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func buy_shuttle() -> String:
	var err := loop.buy_shuttle(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func buy_loom_rule() -> String:
	var err := loop.buy_loom_rule(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func buy_pack_line() -> String:
	var err := loop.buy_pack_line(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func start_wrap() -> String:
	var err := loop.start_wrap()
	refresh_presentation()
	if err == "":
		_write()
	return err


func fulfill_packed() -> String:
	var err := loop.fulfill_packed(game)
	refresh_presentation()
	if err == "":
		_write()
	return err


func assign_packing(worker_id: String) -> String:
	var err := loop.assign_packing(worker_id)
	refresh_presentation()
	if err == "":
		_write()
	return err


func set_loom_priority(recipe_id: String) -> String:
	var err := loop.set_loom_priority(recipe_id)
	refresh_presentation()
	if err == "":
		_write()
	return err


func play_intro_cycle(plot_x: float, plot_z: float) -> String:
	var err := place_marker_at(plot_x, plot_z)
	if err != "":
		return err
	loop.advance(5.0)
	if loop.plot.is_ready():
		return "ready early"
	loop.advance(1.0)
	if not loop.plot.is_ready():
		return "not ready"
	err = harvest_plot()
	if err != "":
		return err
	err = start_workshop()
	if err != "":
		return err
	loop.advance(3.0)
	if loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle early"
	loop.advance(1.0)
	err = fulfill_order()
	if err != "":
		return err
	err = buy_loft()
	if err != "":
		return err
	refresh_presentation()
	if loop.tutorial.step != TutorialTrack.DONE:
		return "tutorial"
	return ""


func refresh_presentation() -> void:
	_sync_crop()
	_sync_loft()
	_sync_rack()
	if workshop_rig != null:
		workshop_rig.operating = loop.workshop.is_busy()
	_sync_worker()
	_sync_packing()
	_sync_clerk()
	_play_cue()
	if hud != null and game != null:
		hud.refresh(game, loop, _barn_selected)
		hud.set_marker_available(grid.has_marker)


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
	_set_workshop_selected(false)
	refresh_presentation()


func _capture_state() -> void:
	game.camera = {
		"focus": [camera.focus.x, camera.focus.y, camera.focus.z],
		"yaw": camera.yaw,
		"pitch": camera.pitch,
		"distance": camera.distance,
	}
	game.marker = grid.to_save()
	loop.write_to(game)


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
	if world.distance_to(WorkshopRig.WORLD_POSITION) <= WorkshopRig.SELECT_RADIUS:
		_set_barn_selected(false)
		_set_workshop_selected(true)
		_set_packing_selected(false)
		hud.open_workshop(true)
		refresh_presentation()
		return
	if world.distance_to(PackingRig.WORLD_POSITION) <= PackingRig.SELECT_RADIUS:
		_set_barn_selected(false)
		_set_workshop_selected(false)
		_set_packing_selected(true)
		if loop.research.owns("pack_line"):
			hud.open_packing(true)
		else:
			loop.last_event = "Buy the packing line to open this bench."
		refresh_presentation()
		return
	if grid.has_marker and loop.plot.is_ready():
		var cell := PlotGrid.snap_cell(world.x, world.z)
		if cell == grid.cell and loop.tutorial.allows("harvest"):
			harvest_plot()
			return
	place_marker_at(world.x, world.z)


func _hover(screen_position: Vector2) -> void:
	var point: Variant = _ground_point(screen_position)
	if point == null:
		hover.visible = false
		return
	var world := point as Vector3
	if world.distance_to(WorkshopRig.WORLD_POSITION) <= WorkshopRig.SELECT_RADIUS:
		hover.visible = false
		return
	if world.distance_to(PackingRig.WORLD_POSITION) <= PackingRig.SELECT_RADIUS:
		hover.visible = false
		return
	var cell := PlotGrid.snap_cell(world.x, world.z)
	if PlotGrid.blocked(cell) or _on_workshop_cell(cell) or (grid.has_marker and grid.cell == cell):
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
	if game != null:
		game.marker = grid.to_save()


func _sync_crop() -> void:
	if crop == null:
		return
	crop.show_stage(loop.plot.stage_name())
	if grid.has_marker:
		crop.global_position = PlotGrid.cell_center(grid.cell)


func hire_worker(worker_id: String) -> String:
	var err := loop.hire_worker(worker_id)
	refresh_presentation()
	if err == "":
		_write()
	return err


func assign_worker(worker_id: String) -> String:
	var err := loop.assign_workshop(worker_id)
	refresh_presentation()
	if err == "":
		_write()
	return err


func _sync_worker() -> void:
	if workshop_worker == null:
		return
	var person := loop.roster.assigned_worker()
	var display_name := ""
	if not person.is_empty():
		display_name = str(person["name"])
	workshop_worker.show_assignment(not person.is_empty(), loop.workshop.is_busy(), display_name)


func _sync_packing() -> void:
	if packing_bench == null:
		return
	packing_bench.visible = loop.research.owns("pack_line")
	packing_bench.operating = loop.packer.is_busy() and packing_bench.visible


func _sync_clerk() -> void:
	if packing_clerk == null:
		return
	var person := loop.roster.packing_worker()
	var display_name := ""
	if not person.is_empty():
		display_name = str(person["name"])
	var present := loop.research.owns("pack_line") and not person.is_empty()
	packing_clerk.show_assignment(present, loop.packer.is_busy(), display_name)


func _set_packing_selected(selected: bool) -> void:
	if packing_bench != null:
		packing_bench.set_selected(selected)


func _play_cue() -> void:
	if loop.sound_cue == "":
		return
	var cue := loop.sound_cue
	loop.sound_cue = ""
	if _audio == null:
		return
	var stream: AudioStream = _streams.get(cue)
	if stream == null:
		return
	_audio.stream = stream
	_audio.play()


func _sync_loft() -> void:
	if loft != null:
		loft.visible = loop.upgrades.owns("barn_loft")


func _sync_rack() -> void:
	if shuttle_rack != null:
		shuttle_rack.visible = loop.upgrades.owns("shuttle_rack")


func _set_barn_selected(selected: bool) -> void:
	_barn_selected = selected
	selection_ring.visible = selected


func _set_workshop_selected(selected: bool) -> void:
	if workshop_rig != null:
		workshop_rig.set_selected(selected)


func _on_workshop_cell(cell: Vector2i) -> bool:
	var center := PlotGrid.cell_center(cell)
	return Vector2(center.x, center.z).distance_to(Vector2(WorkshopRig.WORLD_POSITION.x, WorkshopRig.WORLD_POSITION.z)) < 1.15


func _connect_hud() -> void:
	if not hud.remove_pressed.is_connected(_on_remove_marker):
		hud.remove_pressed.connect(_on_remove_marker)
	if not hud.harvest_pressed.is_connected(harvest_plot):
		hud.harvest_pressed.connect(harvest_plot)
	if not hud.workshop_pressed.is_connected(_on_workshop_button):
		hud.workshop_pressed.connect(_on_workshop_button)
	if not hud.workshop_start_pressed.is_connected(start_workshop):
		hud.workshop_start_pressed.connect(start_workshop)
	if not hud.workshop_cord_pressed.is_connected(start_cord):
		hud.workshop_cord_pressed.connect(start_cord)
	if not hud.orders_pressed.is_connected(_on_orders_button):
		hud.orders_pressed.connect(_on_orders_button)
	if not hud.order_deliver_pressed.is_connected(fulfill_order):
		hud.order_deliver_pressed.connect(fulfill_order)
	if not hud.order_deliver_cord_pressed.is_connected(fulfill_cord):
		hud.order_deliver_cord_pressed.connect(fulfill_cord)
	if not hud.upgrade_pressed.is_connected(_on_upgrade_button):
		hud.upgrade_pressed.connect(_on_upgrade_button)
	if not hud.crew_pressed.is_connected(_on_crew_button):
		hud.crew_pressed.connect(_on_crew_button)
	if not hud.hire_requested.is_connected(hire_worker):
		hud.hire_requested.connect(hire_worker)
	if not hud.assign_requested.is_connected(assign_worker):
		hud.assign_requested.connect(assign_worker)
	if not hud.research_pressed.is_connected(buy_loom_rule):
		hud.research_pressed.connect(buy_loom_rule)
	if not hud.pack_research_pressed.is_connected(buy_pack_line):
		hud.pack_research_pressed.connect(buy_pack_line)
	if not hud.packing_pressed.is_connected(_on_packing_button):
		hud.packing_pressed.connect(_on_packing_button)
	if not hud.packing_start_pressed.is_connected(start_wrap):
		hud.packing_start_pressed.connect(start_wrap)
	if not hud.order_deliver_packed_pressed.is_connected(fulfill_packed):
		hud.order_deliver_packed_pressed.connect(fulfill_packed)
	if not hud.assign_packing_requested.is_connected(assign_packing):
		hud.assign_packing_requested.connect(assign_packing)
	if not hud.priority_requested.is_connected(set_loom_priority):
		hud.priority_requested.connect(set_loom_priority)


func _on_remove_marker() -> void:
	remove_marker()


func _on_workshop_button() -> void:
	_set_workshop_selected(true)
	_set_barn_selected(false)
	hud.open_workshop(not hud.workshop_open)


func _on_orders_button() -> void:
	hud.open_orders(not hud.orders_open)


func _on_upgrade_button() -> void:
	if loop.upgrades.owns("barn_loft"):
		buy_shuttle()
	else:
		buy_loft()


func _on_crew_button() -> void:
	hud.open_crew(not hud.crew_open)
	refresh_presentation()


func _on_packing_button() -> void:
	_set_packing_selected(true)
	_set_workshop_selected(false)
	_set_barn_selected(false)
	hud.open_packing(not hud.packing_open)
