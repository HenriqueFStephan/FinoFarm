class_name PlotGrid
extends RefCounted

## One plot marker on a square grid. The marker is a stake, not a crop.

const CELL := 2.0
const MIN_CELL := -4
const MAX_CELL := 4

var has_marker := false
var cell := Vector2i.ZERO


static func snap_cell(world_x: float, world_z: float) -> Vector2i:
	var x := int(round(world_x / CELL))
	var z := int(round(world_z / CELL))
	return Vector2i(clampi(x, MIN_CELL, MAX_CELL), clampi(z, MIN_CELL, MAX_CELL))


static func cell_center(grid_cell: Vector2i) -> Vector3:
	return Vector3(grid_cell.x * CELL, 0.0, grid_cell.y * CELL)


static func blocked(grid_cell: Vector2i) -> bool:
	# The barn footprint sits on the center cells.
	return absi(grid_cell.x) <= 1 and absi(grid_cell.y) <= 1


static func ground_hit(origin: Vector3, direction: Vector3) -> Variant:
	if absf(direction.y) < 0.00001:
		return null
	var t := -origin.y / direction.y
	if t < 0.0:
		return null
	var point := origin + direction * t
	point.y = 0.0
	return point


func place_at(world_x: float, world_z: float) -> String:
	var next := snap_cell(world_x, world_z)
	if blocked(next):
		return "blocked"
	cell = next
	has_marker = true
	return ""


func move_to(world_x: float, world_z: float) -> String:
	if not has_marker:
		return "missing"
	return place_at(world_x, world_z)


func remove() -> String:
	if not has_marker:
		return "missing"
	has_marker = false
	cell = Vector2i.ZERO
	return ""


func to_save() -> Dictionary:
	if not has_marker:
		return {}
	return {"x": cell.x, "z": cell.y}


func apply_save(data: Dictionary) -> String:
	if data.is_empty():
		has_marker = false
		cell = Vector2i.ZERO
		return ""
	if not data.has("x") or not data.has("z"):
		return "bad_marker"
	var next := Vector2i(int(data["x"]), int(data["z"]))
	if next.x < MIN_CELL or next.x > MAX_CELL or next.y < MIN_CELL or next.y > MAX_CELL:
		return "bad_marker"
	if blocked(next):
		return "blocked"
	cell = next
	has_marker = true
	return ""
