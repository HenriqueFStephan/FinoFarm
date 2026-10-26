extends SceneTree

## Loads the menu and the farm. Checks camera, walk clip, HUD, and placement.


func _initialize() -> void:
	call_deferred("_begin")


func _begin() -> void:
	var reason := _run()
	if reason == "":
		print("scene checks passed")
		quit(0)
	else:
		push_error(reason)
		print("scene checks failed — %s" % reason)
		quit(1)


func _run() -> String:
	var main := str(ProjectSettings.get_setting("application/run/main_scene"))
	if main != "res://scenes/menu/main_menu.tscn":
		return "main scene is %s" % main
	var farm_reason := _farm()
	if farm_reason != "":
		return farm_reason
	return _menu()


func _farm() -> String:
	var packed: PackedScene = load("res://scenes/farm/first_farm.tscn")
	if packed == null:
		return "farm scene failed to load"
	var library := FarmLibrary.new()
	library.root_path = "user://finofarm-tests/scene-%d" % Time.get_ticks_usec()
	library.wipe()
	var created: Dictionary = SaveGame.create_new("Zebra Holding", "innovation_plains")
	if not created["ok"]:
		return str(created["error"])
	var game: SaveGame = created["game"]
	game.funds = 4242
	game.marker = {"x": 3, "z": -3}
	if library.write(game) != "":
		return "save for scene check"
	var farm = packed.instantiate()
	farm.library = library
	farm.persist = false
	root.add_child(farm)
	if farm.find_child("PlaceholderBarn", true, false) != null:
		return "placeholder barn is still in the scene"
	if farm.find_child("PlaceholderWalker", true, false) != null:
		return "placeholder walker is still in the scene"
	for node_name in [
		"Stage/PlaceholderTerrain",
		"Stage/Barn",
		"Stage/PlaceholderTreeA",
		"Stage/Farmhand",
		"Stage/FarmCamera",
		"PlaceholderPlotMarker",
		"PlaceholderCrop",
		"PlaceholderWorkshop",
		"PlaceholderBarnLoft",
		"Hud",
	]:
		if farm.get_node_or_null(node_name) == null:
			return "missing %s" % node_name
	var terrain := farm.get_node("Stage/PlaceholderTerrain") as MeshInstance3D
	if not (terrain.get_active_material(0) is ShaderMaterial):
		return "terrain is not using the placeholder shader"
	if farm.get_node("Stage/Barn").find_children("*", "MeshInstance3D", true, false).is_empty():
		return "barn has no imported mesh"
	var walker = farm.get_node("Stage/Farmhand")
	if walker.find_child("Skeleton3D", true, false) == null:
		return "farmhand has no skeleton"
	var player: AnimationPlayer = walker.animation_player()
	if player == null:
		return "farmhand has no AnimationPlayer"
	if not player.has_animation("walk") or not player.has_animation("idle"):
		return "clips %s" % str(player.get_animation_list())
	var walk: Animation = player.get_animation("walk")
	if walk.length < 0.4:
		return "walk length %.3f" % walk.length
	if walk.get_track_count() < 4:
		return "walk tracks %d" % walk.get_track_count()
	var start: Vector3 = walker.global_position
	walker.advance(1.0)
	var moved: float = walker.global_position.distance_to(start)
	if moved < 1.5 or moved > 1.9:
		return "walker moved %.3f, expected about 1.7" % moved
	if player.current_animation != "walk":
		return "walk clip did not play, current is %s" % player.current_animation
	var name_label := farm.get_node("Hud/HudRoot/Top/Row/NameLabel") as Label
	var region_label := farm.get_node("Hud/HudRoot/Top/Row/RegionLabel") as Label
	var funds_label := farm.get_node("Hud/HudRoot/Top/Row/FundsLabel") as Label
	if name_label.text != "Zebra Holding":
		return "hud name %s" % name_label.text
	if region_label.text != "Innovation Plains":
		return "hud region %s" % region_label.text
	if funds_label.text != "Funds 4242":
		return "hud funds %s" % funds_label.text
	var marker: Node3D = farm.get_node("PlaceholderPlotMarker")
	if not marker.visible:
		return "saved marker hidden"
	if marker.global_position.distance_to(Vector3(6, 0, -6)) > 0.05:
		return "saved marker at %s" % str(marker.global_position)
	if farm.place_marker_at(-4.2, 6.2) != "":
		return "move marker"
	if marker.global_position.distance_to(Vector3(-4, 0, 6)) > 0.05:
		return "moved marker at %s" % str(marker.global_position)
	if farm.remove_marker() != "":
		return "remove marker"
	if marker.visible:
		return "marker stayed after remove"
	if farm.place_marker_at(0.2, 0.1) != "blocked":
		return "barn cell accepted a marker"
	if not farm.get_node("PlaceholderSelectionRing").visible:
		return "barn was not selected"
	var camera = farm.get_node("Stage/FarmCamera")
	camera.yaw = 0.0
	camera.pitch = 0.6
	camera.focus = Vector3.ZERO
	camera.distance = 16.0
	camera.orbit(0.0, 0.0)
	if absf(camera.global_position.distance_to(camera.focus) - 16.0) > 0.05:
		return "camera is not orbiting at its distance"
	camera.zoom_by(2.0)
	if absf(camera.distance - 18.0) > 0.001:
		return "zoom"
	camera.zoom_by(100.0)
	if absf(camera.distance - camera.ZOOM_MAX) > 0.001:
		return "zoom max"
	camera.zoom_by(-100.0)
	if absf(camera.distance - camera.ZOOM_MIN) > 0.001:
		return "zoom min"
	camera.distance = 16.0
	camera.yaw = 0.0
	camera.focus = Vector3(0, 1.2, 0)
	camera.pan_keys(Vector3(0, 0, 1), 1.0)
	if absf(camera.focus.x) > 0.01 or absf(camera.focus.z + 12.0) > 0.01:
		return "forward pan landed at %s" % str(camera.focus)
	camera.pan_keys(Vector3(1, 0, 0), 1.0)
	if absf(camera.focus.x - 12.0) > 0.01:
		return "right pan landed at %s" % str(camera.focus)
	if absf(camera.global_position.distance_to(camera.focus) - camera.distance) > 0.05:
		return "pan left the camera radius"
	var cycle_reason := _economy(farm)
	if cycle_reason != "":
		return cycle_reason
	var screen: Vector2 = camera.unproject_position(Vector3(4, 0, 4))
	var hit: Variant = PlotGrid.ground_hit(
		camera.project_ray_origin(screen),
		camera.project_ray_normal(screen)
	)
	if hit == null or (hit as Vector3).distance_to(Vector3(4, 0, 4)) > 0.2:
		return "camera ray missed the ground point"
	root.remove_child(farm)
	farm.free()
	library.wipe()
	return ""


func _economy(farm) -> String:
	var session := farm as FarmSession
	var workshop := session.get_node("PlaceholderWorkshop") as Node3D
	if workshop.global_position.distance_to(WorkshopRig.WORLD_POSITION) > 0.05:
		return "workshop at %s" % str(workshop.global_position)
	var loft := session.get_node("PlaceholderBarnLoft") as Node3D
	if loft.visible:
		return "loft starts visible"
	var crop := session.get_node("PlaceholderCrop") as CropVisual
	session.loop.plot.plant()
	session.refresh_presentation()
	if not crop.visible:
		return "seeded crop hidden"
	session.loop.plot.stage = 3
	session.loop.plot.ticks_remaining = 0
	session.refresh_presentation()
	if not crop.ready_visible():
		return "ready tuft hidden"
	session.loop.plot.clear()
	session.refresh_presentation()
	if crop.visible:
		return "crop stayed after clear"
	var rig := workshop as WorkshopRig
	var idle_angle := rig.spin_angle()
	rig.advance(0.5, false)
	if absf(rig.spin_angle() - idle_angle) > 0.001:
		return "loom moved while idle"
	rig.advance(0.5, true)
	if absf(rig.spin_angle() - idle_angle) < 0.2:
		return "loom did not move while operating"
	var before := session.game.funds
	var cycle := session.play_intro_cycle(6.0, -4.0)
	if cycle != "":
		return cycle
	var expected := before + 180 - 400
	if session.game.funds != expected:
		return "cycle funds %d" % session.game.funds
	if not loft.visible:
		return "loft hidden after purchase"
	if session.loop.tutorial.step != TutorialTrack.DONE:
		return "tutorial step %d" % session.loop.tutorial.step
	if session.loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 0:
		return "bundle remained"
	var funds_label := session.get_node("Hud/HudRoot/Top/Row/FundsLabel") as Label
	if funds_label.text != "Funds %d" % expected:
		return "hud funds %s" % funds_label.text
	var tutorial := session.get_node("Hud/HudRoot/TutorialPanel/TutorialText") as Label
	if not tutorial.text.contains("loft"):
		return "tutorial %s" % tutorial.text
	var order_body := session.get_node("Hud/HudRoot/OrderPanel/Box/OrderBody") as Label
	if not order_body.text.contains("Delivered"):
		return "order %s" % order_body.text
	return ""


func _menu() -> String:
	var packed: PackedScene = load("res://scenes/menu/main_menu.tscn")
	if packed == null:
		return "menu scene failed to load"
	var library := FarmLibrary.new()
	library.root_path = "user://finofarm-tests/menu-%d" % Time.get_ticks_usec()
	library.wipe()
	var menu = packed.instantiate()
	menu.library = library
	root.add_child(menu)
	for node_name in [
		"ContinueButton",
		"MyFarmsButton",
		"NewGameButton",
		"SettingsButton",
		"CreditsButton",
		"ExitButton",
		"FarmNameEdit",
		"RegionDetail",
	]:
		if menu.find_child(node_name, true, false) == null:
			return "menu missing %s" % node_name
	if menu.get_node("Stage/FarmCamera") == null:
		return "menu has no farm camera"
	if menu.continue_button.disabled != true:
		return "continue should start disabled"
	if menu.try_create("   ", "tropical_valley") != "name_required":
		return "blank name"
	if menu.try_create("North Plot", "northern_homestead") != "":
		return "create north"
	if menu.try_create("Gold Acre", "golden_fields") != "":
		return "create gold"
	if menu.continue_button.disabled:
		return "continue stayed disabled"
	menu.show_farms()
	var cards := menu.get_tree().get_nodes_in_group("farm_card")
	if cards.size() != 2:
		return "card count %d" % cards.size()
	var joined := ""
	for card in cards:
		joined += (card as Button).text
	for piece in ["North Plot", "Gold Acre", "Northern Homestead", "Golden Fields", "Level", "Funds", "UTC"]:
		if not joined.contains(piece):
			return "cards missing %s" % piece
	for region_id in RegionCatalog.ids():
		if menu.find_child("Region_%s" % region_id, true, false) == null:
			return "missing marker %s" % region_id
		menu.select_region(region_id)
		var region := RegionCatalog.get_region(region_id)
		var detail: String = menu.region_detail.text
		for piece in [
			str(region["display_name"]),
			str(region["climate_label"]),
			str(region["opportunity"]),
			str(region["challenge"]),
			str(region["property_cost"]),
		]:
			if not detail.contains(piece):
				return "detail %s missing %s" % [region_id, piece]
	menu.show_settings()
	var settings := menu.find_child("SettingsBody", true, false) as Label
	if settings == null or not settings.text.contains("orbit"):
		return "settings screen"
	menu.show_credits()
	var credits := menu.find_child("CreditsBody", true, false) as Label
	if credits == null or not credits.text.to_lower().contains("placeholder"):
		return "credits screen"
	if menu.find_child("ExitButton", true, false) == null:
		return "exit"
	root.remove_child(menu)
	menu.free()
	library.wipe()
	return ""
