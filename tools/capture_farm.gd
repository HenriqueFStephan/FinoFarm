extends SceneTree

## Saves one frame of the farm scene. User arg: --output=/absolute/path.png


func _initialize() -> void:
	var output := "/tmp/finofarm-first-farm.png"
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--output="):
			output = str(arg).trim_prefix("--output=")
	var packed: PackedScene = load("res://scenes/farm/first_farm.tscn")
	if packed == null:
		push_error("scene failed to load")
		quit(1)
		return
	var farm := packed.instantiate()
	root.add_child(farm)
	call_deferred("_capture", farm, output)


func _capture(farm: Node, output: String) -> void:
	for _frame in 6:
		await process_frame
	var walker := farm.get_node("PlaceholderWalker")
	walker.advance(0.45)
	for _frame in 2:
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
