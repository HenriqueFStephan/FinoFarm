extends SceneTree

## Grid snap checks. Must not instance a 3D scene.

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_check("snap_and_center", _snap)
	_check("clamp_bounds", _clamp)
	_check("place_move_remove_one_marker", _place_move_remove)
	_check("barn_cells_are_blocked", _blocked)
	_check("ground_ray_hits_the_plane", _ray)
	_check("marker_save_round_trip", _save)
	print("%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _check(test_name: String, body: Callable) -> void:
	var reason: String = body.call()
	if reason == "":
		_passed += 1
		print("ok %s" % test_name)
	else:
		_failed += 1
		print("not ok %s — %s" % [test_name, reason])


func _snap() -> String:
	var cell := PlotGrid.snap_cell(1.2, 3.6)
	if cell != Vector2i(1, 2):
		return "cell %s" % str(cell)
	var center := PlotGrid.cell_center(cell)
	if center.distance_to(Vector3(2, 0, 4)) > 0.001:
		return "center %s" % str(center)
	var negative := PlotGrid.snap_cell(-2.2, -0.4)
	if negative != Vector2i(-1, 0):
		return "negative %s" % str(negative)
	return ""


func _clamp() -> String:
	var cell := PlotGrid.snap_cell(100.0, -80.0)
	if cell != Vector2i(PlotGrid.MAX_CELL, PlotGrid.MIN_CELL):
		return str(cell)
	return ""


func _place_move_remove() -> String:
	var grid := PlotGrid.new()
	if grid.move_to(4.2, 4.2) != "missing":
		return "move before place"
	if grid.place_at(4.2, 6.1) != "":
		return "place"
	if not grid.has_marker or grid.cell != Vector2i(2, 3):
		return "placed cell %s" % str(grid.cell)
	if grid.place_at(-4.4, 5.0) != "":
		return "second place"
	if grid.cell != Vector2i(-2, 3):
		return "still one marker %s" % str(grid.cell)
	if grid.move_to(3.1, -3.2) != "":
		return "move"
	if grid.cell != Vector2i(2, -2):
		return "moved %s" % str(grid.cell)
	if grid.remove() != "":
		return "remove"
	if grid.has_marker:
		return "marker remained"
	if grid.remove() != "missing":
		return "second remove"
	return ""


func _blocked() -> String:
	var grid := PlotGrid.new()
	if grid.place_at(0.2, -0.4) != "blocked":
		return "center should block"
	if grid.has_marker:
		return "blocked place still set a marker"
	if grid.place_at(4.0, 0.0) != "":
		return "side place"
	if grid.move_to(0.0, 0.0) != "blocked":
		return "move onto barn"
	if grid.cell != Vector2i(2, 0):
		return "blocked move changed the cell"
	return ""


func _ray() -> String:
	var straight: Variant = PlotGrid.ground_hit(Vector3(0, 10, 0), Vector3(0, -1, 0))
	if straight == null or (straight as Vector3).distance_to(Vector3.ZERO) > 0.001:
		return "straight"
	var angled: Variant = PlotGrid.ground_hit(Vector3(0, 5, 0), Vector3(0, -1, 1).normalized())
	if angled == null:
		return "angled miss"
	var point: Vector3 = angled
	if absf(point.y) > 0.001 or point.z <= 0.0:
		return "angled %s" % str(point)
	var behind: Variant = PlotGrid.ground_hit(Vector3(0, 5, 0), Vector3(0, 1, 0))
	if behind != null:
		return "upward ray hit"
	return ""


func _save() -> String:
	var grid := PlotGrid.new()
	grid.place_at(6.0, -6.0)
	var copy := PlotGrid.new()
	if copy.apply_save(grid.to_save()) != "":
		return "apply"
	if copy.cell != grid.cell or not copy.has_marker:
		return "copied"
	if copy.apply_save({}) != "" or copy.has_marker:
		return "clear"
	if copy.apply_save({"x": 0, "z": 0}) != "blocked":
		return "saved barn cell"
	return ""
