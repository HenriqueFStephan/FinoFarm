extends SceneTree

## Saves one frame of the playable farm. User arg: --output=/absolute/path.png


func _initialize() -> void:
	var output := "/tmp/finofarm-first-farm.png"
	var menu := false
	var cycle := false
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--output="):
			output = str(arg).trim_prefix("--output=")
		elif str(arg) == "--menu":
			menu = true
		elif str(arg) == "--cycle":
			cycle = true
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
	if cycle:
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
