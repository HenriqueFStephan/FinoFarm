extends SceneTree

## Loads the farm scene and checks camera and walker behavior without saving a frame.


func _initialize() -> void:
	# SceneTree scripts run _initialize before root is inside the tree.
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
	if main != "res://scenes/farm/first_farm.tscn":
		return "main scene is %s" % main
	var packed: PackedScene = load("res://scenes/farm/first_farm.tscn")
	if packed == null:
		return "scene failed to load"
	var farm := packed.instantiate()
	root.add_child(farm)
	for node_name in [
		"PlaceholderTerrain",
		"PlaceholderBarn",
		"PlaceholderBarn/Walls",
		"PlaceholderBarn/Roof",
		"PlaceholderBarn/Door",
		"PlaceholderTreeA",
		"PlaceholderWalker",
		"PlaceholderWalker/LegL",
		"PlaceholderWalker/LegR",
		"FarmCamera",
	]:
		if farm.get_node_or_null(node_name) == null:
			return "missing %s" % node_name
	var terrain := farm.get_node("PlaceholderTerrain") as MeshInstance3D
	if not (terrain.get_active_material(0) is ShaderMaterial):
		return "terrain is not using the placeholder shader"
	var walker := farm.get_node("PlaceholderWalker")
	var start: Vector3 = walker.global_position
	walker.advance(1.0)
	var moved: float = walker.global_position.distance_to(start)
	if moved < 1.5 or moved > 1.9:
		return "walker moved %.3f, expected about 1.7" % moved
	var swing: float = walker.get_node("LegL").rotation.x
	if absf(swing) < 0.05:
		return "walk pose did not swing the legs"
	var camera := farm.get_node("FarmCamera")
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
	return ""
