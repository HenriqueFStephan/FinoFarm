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
		"PlaceholderShuttleRack",
		"WorkshopWorker",
		"Hud",
	]:
		if farm.get_node_or_null(node_name) == null:
			return "missing %s" % node_name
	var valley := _valley(farm.get_node("Stage/PlaceholderTerrain"))
	if valley != "":
		return valley
	if farm.get_node("Stage/Barn").find_children("*", "MeshInstance3D", true, false).is_empty():
		return "barn has no imported mesh"
	for tree_name in ["PlaceholderTreeA", "PlaceholderTreeB", "PlaceholderTreeC"]:
		var tree_reason := _gltf_child(farm.get_node("Stage/%s" % tree_name), "Model", tree_name)
		if tree_reason != "":
			return tree_reason
		if farm.get_node("Stage/%s" % tree_name).get_node_or_null("Trunk") != null:
			return "%s still has a primitive trunk" % tree_name
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
	var opening := farm.get_node("Hud/HudRoot/TutorialPanel/TutorialText") as Label
	if not opening.text.contains("Place a plot"):
		return "opening tutorial %s" % opening.text
	var crew_button := farm.get_node_or_null("Hud/HudRoot/ActionColumn/CrewButton") as Button
	if crew_button == null:
		return "no crew button"
	if crew_button.visible:
		return "crew visible during the lesson"
	var research_button := farm.get_node_or_null("Hud/HudRoot/ActionColumn/ResearchButton") as Button
	if research_button == null:
		return "no research button"
	if research_button.visible:
		return "research visible during the lesson"
	var marker: Node3D = farm.get_node("PlaceholderPlotMarker")
	var marker_mesh := _gltf_child(marker, "Model", "plot marker")
	if marker_mesh != "":
		return marker_mesh
	if marker.get_node_or_null("Post") != null:
		return "plot marker still has a primitive post"
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
	var shed_mesh := _gltf_child(workshop, "Model", "workshop")
	if shed_mesh != "":
		return shed_mesh
	for part_name in ["LoomArm", "Shuttle"]:
		var part := workshop.get_node_or_null(part_name)
		if part == null or not str(part.scene_file_path).ends_with(".glb"):
			return "%s is not a gltf" % part_name
	if workshop.get_node_or_null("BackWall") != null or workshop.get_node_or_null("Pad") != null:
		return "workshop still has a primitive shed"
	var loft := session.get_node("PlaceholderBarnLoft") as Node3D
	if loft.visible:
		return "loft starts visible"
	var rack := session.get_node("PlaceholderShuttleRack") as Node3D
	if rack.visible:
		return "rack starts visible"
	var crop := session.get_node("PlaceholderCrop") as CropVisual
	session.loop.plot.plant()
	session.refresh_presentation()
	if not crop.visible:
		return "seeded crop hidden"
	if crop.get_node("Sprout").visible or crop.get_node("Leaf").visible or crop.get_node("ReadyTuft").visible:
		return "row stage shows a later mesh"
	session.loop.plot.stage = 1
	session.refresh_presentation()
	if not crop.get_node("Sprout").visible or crop.get_node("Leaf").visible or crop.get_node("ReadyTuft").visible:
		return "sprout stage"
	session.loop.plot.stage = 2
	session.refresh_presentation()
	if not crop.get_node("Sprout").visible or not crop.get_node("Leaf").visible or crop.get_node("ReadyTuft").visible:
		return "leaf stage"
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
	if not order_body.text.contains("Lane counter cord"):
		return "cord order %s" % order_body.text
	var inventory_label := session.get_node("Hud/HudRoot/InventoryLabel") as Label
	if not inventory_label.text.contains("Fiber Bundle") or not inventory_label.text.contains("Fiber Cord"):
		return "inventory %s" % inventory_label.text
	var crew_reason := _crew(session)
	if crew_reason != "":
		return crew_reason
	if session.buy_shuttle() != "":
		return "shuttle buy"
	if not rack.visible:
		return "rack hidden after purchase"
	var paced := session.loop.job_ticks("bundle_fiber")
	if paced != WorkerPace.job_ticks("bundle_fiber", StaffCatalog.worker("alex_morgan"), 1):
		return "rack pace %d" % paced
	var research_button := session.get_node("Hud/HudRoot/ActionColumn/ResearchButton") as Button
	if not research_button.visible:
		return "research hidden after the lesson"
	var priority_bundle := session.get_node_or_null("Hud/HudRoot/WorkshopPanel/Box/PriorityRow/PriorityBundle") as Button
	var priority_cord := session.get_node_or_null("Hud/HudRoot/WorkshopPanel/Box/PriorityRow/PriorityCord") as Button
	if priority_bundle == null or priority_cord == null:
		return "priority controls"
	if priority_bundle.visible or priority_cord.visible:
		return "priority visible before the unlock"
	var before_funds := session.game.funds
	if session.buy_loom_rule() != "":
		return "loom rule"
	if session.game.funds != before_funds - int(ResourceCatalog.research("loom_rule")["cost"]):
		return "rule funds %d" % session.game.funds
	if research_button.visible:
		return "research button stayed"
	session.hud.open_workshop(true)
	session.refresh_presentation()
	if not priority_bundle.visible or not priority_cord.visible:
		return "priority hidden"
	var body := session.get_node("Hud/HudRoot/WorkshopPanel/Box/WorkshopBody") as Label
	if not body.text.contains("Loom rule is on"):
		return "rule copy %s" % body.text
	var recipe := session.loop.workshop.active_recipe_id
	var ticks := session.loop.workshop.ticks_remaining
	if session.set_loom_priority("twist_cord") != "":
		return "set priority"
	if session.loop.workshop.active_recipe_id != recipe or session.loop.workshop.ticks_remaining != ticks:
		return "priority replaced the job"
	if session.loop.research.priority != "twist_cord":
		return "priority not stored"
	if not body.text.contains("Priority: Fiber Cord."):
		return "priority label %s" % body.text
	return ""


func _crew(session: FarmSession) -> String:
	var worker := session.get_node("WorkshopWorker") as WorkshopWorker
	if worker == null:
		return "no workshop worker"
	if worker.visible:
		return "worker visible before hire"
	var spot := worker.global_position.distance_to(WorkshopRig.WORLD_POSITION)
	if spot < 0.8 or spot > 2.6:
		return "worker distance %.2f" % spot
	var anim: AnimationPlayer = worker.animation_player()
	if anim == null or not anim.has_animation("work") or not anim.has_animation("idle"):
		return "worker clips"
	var work: Animation = anim.get_animation("work")
	if work.length < 0.4 or work.get_track_count() < 4:
		return "work clip length %.3f tracks %d" % [work.length, work.get_track_count()]
	if session.hire_worker("nope") == "":
		return "hired unknown"
	if session.hire_worker("alex_morgan") != "":
		return "hire"
	if worker.visible:
		return "visible before assign"
	if session.assign_worker("alex_morgan") != "":
		return "assign"
	if not worker.visible:
		return "hidden while assigned"
	if worker.current_clip() != "idle":
		return "idle clip %s" % worker.current_clip()
	var name_label := worker.get_node("WorkerName") as Label3D
	if name_label.text != "Alex Morgan":
		return "name %s" % name_label.text
	var pace := WorkerPace.bundle_ticks(StaffCatalog.worker("alex_morgan"))
	if session.start_workshop() != "":
		return "restart bundle"
	if session.loop.workshop.ticks_remaining != pace:
		return "assigned ticks %d" % session.loop.workshop.ticks_remaining
	if not session.workshop_rig.operating:
		return "loom idle while assigned"
	if worker.current_clip() != "work":
		return "work clip %s" % worker.current_clip()
	if session.loop.tutorial.step != TutorialTrack.DONE:
		return "tutorial moved"
	var prompt := session.get_node("Hud/HudRoot/TutorialPanel/TutorialText") as Label
	if not prompt.text.begins_with("Mara:"):
		return "mara missing"
	if not prompt.text.contains("loft"):
		return "done line changed"
	var crew_button := session.get_node("Hud/HudRoot/ActionColumn/CrewButton") as Button
	if not crew_button.visible:
		return "crew hidden after the lesson"
	return ""


func _valley(terrain: Node) -> String:
	var model_reason := _gltf_child(terrain, "Model", "terrain")
	if model_reason != "":
		return model_reason
	var meshes := terrain.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		return "terrain has no mesh instance"
	var saw_hill := false
	var saw_path := false
	var saw_grass := false
	var vert_count := 0
	for mesh_node in meshes:
		var instance := mesh_node as MeshInstance3D
		if instance.get_active_material(0) is ShaderMaterial:
			return "terrain is still using the edge shader"
		var mesh := instance.mesh
		if mesh == null:
			return "terrain mesh missing"
		var xf := instance.global_transform
		for surface in mesh.get_surface_count():
			var mat := mesh.surface_get_material(surface) as StandardMaterial3D
			if mat == null:
				return "terrain surface has no material"
			var albedo := mat.albedo_color
			var is_path := albedo.r > albedo.g + 0.02
			var is_grass := albedo.g > albedo.r + 0.02
			var arrays: Array = mesh.surface_get_arrays(surface)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			vert_count += verts.size()
			for i in verts.size():
				var world: Vector3 = xf * verts[i]
				var yard := maxf(absf(world.x), absf(world.z))
				if yard <= 8.7 and world.y > 0.06:
					return "valley floor rose to %.3f at %s" % [world.y, str(world)]
				if yard <= 3.6 and absf(world.y) > 0.04:
					return "barn pad height %.3f" % world.y
				if world.y < -0.04:
					return "terrain dipped below the pad"
				if world.y > 1.4:
					saw_hill = true
				if is_grass and yard >= 4.0 and yard <= 5.1:
					saw_grass = true
				if is_path and yard >= 5.7 and yard <= 6.7 and absf(world.y) <= 0.04:
					saw_path = true
	if vert_count < 1000:
		return "terrain mesh is too coarse"
	if not saw_hill:
		return "terrain has no hills"
	if not saw_path:
		return "dirt path is missing"
	if not saw_grass:
		return "valley grass is missing"
	return ""


func _gltf_child(node: Node, child_name: String, label: String) -> String:
	var model := node.get_node_or_null(child_name)
	if model == null:
		return "%s has no %s" % [label, child_name]
	if not str(model.scene_file_path).ends_with(".glb"):
		return "%s model %s" % [label, model.scene_file_path]
	if model.find_children("*", "MeshInstance3D", true, false).is_empty():
		return "%s gltf has no mesh" % label
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
