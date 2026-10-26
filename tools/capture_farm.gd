extends SceneTree

## Saves one frame of the playable farm. User arg: --output=/absolute/path.png


func _initialize() -> void:
	var output := "/tmp/finofarm-first-farm.png"
	var menu := false
	var cycle := false
	var crew := false
	var priority := false
	var automation := false
	var props := false
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--output="):
			output = str(arg).trim_prefix("--output=")
		elif str(arg) == "--menu":
			menu = true
		elif str(arg) == "--cycle":
			cycle = true
		elif str(arg) == "--crew":
			crew = true
		elif str(arg) == "--priority":
			priority = true
		elif str(arg) == "--automation":
			automation = true
		elif str(arg) == "--props":
			props = true
	if menu:
		var menu_scene: PackedScene = load("res://scenes/menu/main_menu.tscn")
		if menu_scene == null:
			push_error("menu failed to load")
			quit(1)
			return
		root.add_child(menu_scene.instantiate())
		call_deferred("_capture_view", output)
		return
	var packed: PackedScene = load("res://scenes/farm/first_farm.tscn")
	if packed == null:
		push_error("scene failed to load")
		quit(1)
		return
	var farm = packed.instantiate()
	var created: Dictionary = SaveGame.create_new("Sunny Rows", "tropical_valley")
	if not created["ok"]:
		push_error(str(created["error"]))
		quit(1)
		return
	farm.game = created["game"]
	farm.persist = false
	root.add_child(farm)
	if crew:
		call_deferred("_capture_crew", farm, output)
	elif props:
		call_deferred("_capture_props", farm, output)
	elif automation:
		call_deferred("_capture_automation", farm, output)
	elif priority:
		call_deferred("_capture_priority", farm, output)
	elif cycle:
		call_deferred("_capture_cycle", farm, output)
	else:
		call_deferred("_capture", farm, output)


func _capture_cycle(farm: Node, output: String) -> void:
	for _frame in 4:
		await process_frame
	var session := farm as FarmSession
	var err := session.play_intro_cycle(4.0, 6.0)
	if err != "":
		push_error(err)
		quit(4)
		return
	session.set_process(false)
	session.hud.open_orders(true)
	session.hud.order_panel.position = Vector2(24, 392)
	session.refresh_presentation()
	var view := session.get_node("Stage/FarmCamera") as Camera3D
	view.focus = Vector3(3.4, 1.5, 1.4)
	view.yaw = 0.95
	view.pitch = 0.52
	view.distance = 13.2
	view.orbit(0.0, 0.0)
	var walker = session.get_node("Stage/Farmhand")
	walker.set_process(false)
	var anim: AnimationPlayer = walker.animation_player()
	if anim != null and anim.has_animation("walk"):
		anim.play("walk")
		anim.seek(0.25, true)
		anim.pause()
	await _capture_view(output)


func _capture_crew(farm: Node, output: String) -> void:
	for _frame in 4:
		await process_frame
	var session := farm as FarmSession
	var err := session.play_intro_cycle(-6.0, 6.0)
	if err != "":
		push_error(err)
		quit(4)
		return
	if session.hire_worker("alex_morgan") != "":
		push_error("hire")
		quit(4)
		return
	if session.assign_worker("alex_morgan") != "":
		push_error("assign")
		quit(4)
		return
	if session.start_workshop() != "":
		push_error("bundle")
		quit(4)
		return
	session.hud.open_crew(false)
	session.hud.open_orders(false)
	session.hud.open_workshop(false)
	session.refresh_presentation()
	session.set_process(false)
	var walker = session.get_node("Stage/Farmhand")
	walker.set_process(false)
	walker.global_position = Vector3(-6.2, 0.0, -6.2)
	var walk_anim: AnimationPlayer = walker.animation_player()
	if walk_anim != null and walk_anim.has_animation("idle"):
		walk_anim.play("idle")
		walk_anim.pause()
	session.workshop_rig.set_process(false)
	session.workshop_rig.advance(0.85, true)
	var stationed := session.workshop_worker
	stationed.set_process(false)
	var anim: AnimationPlayer = stationed.animation_player()
	if anim != null and anim.has_animation("work"):
		anim.play("work")
		anim.seek(0.08, true)
		anim.pause()
	var view := session.get_node("Stage/FarmCamera") as Camera3D
	view.focus = Vector3(5.45, 1.15, 3.85)
	view.yaw = 0.62
	view.pitch = 0.46
	view.distance = 8.0
	view.orbit(0.0, 0.0)
	await _capture_view(output)


func _capture_priority(farm: Node, output: String) -> void:
	for _frame in 4:
		await process_frame
	var session := farm as FarmSession
	var starter := session.loop.inventory.amount("verdant_fiber", GradeScale.COMMON)
	if starter > 0 and not session.loop.inventory.remove("verdant_fiber", GradeScale.COMMON, starter):
		push_error("starter fiber")
		quit(4)
		return
	var err := session.place_marker_at(4.0, 6.0)
	if err != "":
		push_error(err)
		quit(4)
		return
	session.loop.advance(6.0)
	if not session.loop.plot.is_ready():
		push_error("not ready")
		quit(4)
		return
	if session.harvest_plot() != "" or session.start_workshop() != "":
		push_error("harvest or bundle")
		quit(4)
		return
	session.loop.advance(4.0)
	if session.loop.inventory.amount("fiber_bundle", GradeScale.COMMON) != 1:
		push_error("bundle missing")
		quit(4)
		return
	if session.loop.inventory.amount("fiber_cord", GradeScale.COMMON) != 0:
		push_error("cord appeared")
		quit(4)
		return
	if session.loop.tutorial.step != TutorialTrack.ORDER:
		push_error("step %d" % session.loop.tutorial.step)
		quit(4)
		return
	session.set_process(false)
	session.hud.open_orders(true)
	session.hud.order_panel.position = Vector2(16, 188)
	var hint := session.hud.get_node_or_null("HudRoot/Hint") as CanvasItem
	if hint != null:
		hint.visible = false
	session.refresh_presentation()
	if session.hud.order_deliver.disabled or not session.hud.order_deliver_cord.disabled:
		push_error("deliver buttons")
		quit(4)
		return
	var view := session.get_node("Stage/FarmCamera") as Camera3D
	view.focus = Vector3(4.6, 1.3, 3.4)
	view.yaw = 0.42
	view.pitch = 0.5
	view.distance = 15.5
	view.orbit(0.0, 0.0)
	var walker = session.get_node("Stage/Farmhand")
	walker.set_process(false)
	walker.global_position = Vector3(-1.2, 0.0, -4.4)
	var anim: AnimationPlayer = walker.animation_player()
	if anim != null and anim.has_animation("walk"):
		anim.play("walk")
		anim.seek(0.25, true)
		anim.pause()
	await _capture_view(output)


func _capture_automation(farm: Node, output: String) -> void:
	for _frame in 4:
		await process_frame
	var session := farm as FarmSession
	session.set_process(false)
	var starter := session.loop.inventory.amount("verdant_fiber", GradeScale.COMMON)
	if starter > 0 and not session.loop.inventory.remove("verdant_fiber", GradeScale.COMMON, starter):
		push_error("starter fiber")
		quit(4)
		return
	var err := session.play_intro_cycle(4.0, 6.0)
	if err != "":
		push_error(err)
		quit(4)
		return
	var leftover := session.loop.inventory.amount("verdant_fiber", GradeScale.COMMON)
	if leftover > 0 and not session.loop.inventory.remove("verdant_fiber", GradeScale.COMMON, leftover):
		push_error("leftover fiber")
		quit(4)
		return
	if session.hire_worker("alex_morgan") != "" or session.assign_worker("alex_morgan") != "":
		push_error("crew")
		quit(4)
		return
	if session.buy_loom_rule() != "":
		push_error("loom rule")
		quit(4)
		return
	if session.loop.plot.plant() != "":
		push_error("replant")
		quit(4)
		return
	session.loop.advance(6.0)
	if not session.loop.plot.is_ready() or session.loop.workshop.is_busy():
		push_error("plot")
		quit(4)
		return
	if session.set_loom_priority("bundle_fiber") != "":
		push_error("priority")
		quit(4)
		return
	if session.loop.workshop.active_recipe_id != "bundle_fiber":
		push_error("recipe %s" % session.loop.workshop.active_recipe_id)
		quit(4)
		return
	session.hud.open_orders(false)
	session.hud.open_crew(false)
	session.hud.open_workshop(true)
	session.hud.workshop_panel.position = Vector2(16, 188)
	var hint := session.hud.get_node_or_null("HudRoot/Hint") as CanvasItem
	if hint != null:
		hint.visible = false
	var ledger := session.hud.get_node_or_null("HudRoot/LedgerLabel") as CanvasItem
	if ledger != null:
		ledger.visible = false
	session.refresh_presentation()
	if ledger != null:
		ledger.visible = false
	var body := session.hud.workshop_body
	if body == null or not body.text.contains("Loom rule is on. Priority: Fiber Bundle."):
		push_error("priority copy")
		quit(4)
		return
	if not session.hud.priority_bundle.visible or not session.hud.priority_cord.visible:
		push_error("priority buttons")
		quit(4)
		return
	session.set_process(false)
	var view := session.get_node("Stage/FarmCamera") as Camera3D
	view.focus = Vector3(4.2, 1.2, 2.6)
	view.yaw = 0.55
	view.pitch = 0.48
	view.distance = 14.5
	view.orbit(0.0, 0.0)
	var walker = session.get_node("Stage/Farmhand")
	walker.set_process(false)
	walker.global_position = Vector3(-2.4, 0.0, -5.2)
	var walk_anim: AnimationPlayer = walker.animation_player()
	if walk_anim != null and walk_anim.has_animation("walk"):
		walk_anim.play("walk")
		walk_anim.seek(0.25, true)
		walk_anim.pause()
	session.workshop_rig.set_process(false)
	session.workshop_rig.advance(0.85, true)
	var stationed := session.workshop_worker
	stationed.set_process(false)
	var anim: AnimationPlayer = stationed.animation_player()
	if anim != null and anim.has_animation("work"):
		anim.play("work")
		anim.seek(0.08, true)
		anim.pause()
	await _capture_view(output)


func _capture_props(farm: Node, output: String) -> void:
	for _frame in 4:
		await process_frame
	var session := farm as FarmSession
	session.set_process(false)
	var err := session.place_marker_at(4.0, 4.0)
	if err != "":
		push_error(err)
		quit(4)
		return
	session.loop.plot.stage = 3
	session.loop.plot.ticks_remaining = 0
	session.refresh_presentation()
	var crop := session.get_node("PlaceholderCrop") as CropVisual
	if not crop.visible or not crop.ready_visible():
		push_error("ready crop hidden")
		quit(4)
		return
	for panel_name in ["HudRoot/Hint", "HudRoot/TutorialPanel", "HudRoot/LedgerLabel"]:
		var panel := session.hud.get_node_or_null(panel_name) as CanvasItem
		if panel != null:
			panel.visible = false
	var view := session.get_node("Stage/FarmCamera") as Camera3D
	view.focus = Vector3(4.4, 1.05, 1.6)
	view.yaw = 0.82
	view.pitch = 0.5
	view.distance = 12.8
	view.orbit(0.0, 0.0)
	var walker = session.get_node("Stage/Farmhand")
	walker.set_process(false)
	walker.global_position = Vector3(1.6, 0.0, 5.6)
	var anim: AnimationPlayer = walker.animation_player()
	if anim != null and anim.has_animation("walk"):
		anim.play("walk")
		anim.seek(0.25, true)
		anim.pause()
	session.workshop_rig.set_process(false)
	session.workshop_rig.advance(0.55, true)
	await _capture_view(output)


func _capture(farm: Node, output: String) -> void:
	for _frame in 8:
		await process_frame
	var walker = farm.get_node("Stage/Farmhand")
	walker.set_process(false)
	var anim: AnimationPlayer = walker.animation_player()
	if anim != null and anim.has_animation("walk"):
		anim.play("walk")
		anim.seek(0.25, true)
		anim.pause()
	await _capture_view(output)


func _capture_view(output: String) -> void:
	for _frame in 8:
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	if image == null or image.is_empty() or image.get_width() < 16:
		push_error("viewport image was empty")
		quit(2)
		return
	var err := image.save_png(output)
	if err != OK:
		push_error("save_png failed: %s" % err)
		quit(3)
		return
	print("wrote %s %dx%d" % [output, image.get_width(), image.get_height()])
	quit(0)
