extends Node3D

## Placeholder walker. Block meshes and a sine-wave limb swing.
## Not a rig, not a finished animation clip. See docs/art-bible.md.

const SPEED := 1.7

var _points: Array = []
var _index := 0
var _along := 0.0
var distance_walked := 0.0


func _ready() -> void:
	_points = [
		Vector3(-6.2, 0.0, 6.2),
		Vector3(6.2, 0.0, 6.2),
		Vector3(6.2, 0.0, -6.2),
		Vector3(-6.2, 0.0, -6.2),
	]
	_along = 6.2
	_place()
	_pose()


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if delta <= 0.0 or _points.is_empty():
		return
	var step := SPEED * delta
	_along += step
	distance_walked += step
	var span := _span()
	while span > 0.0 and _along >= span:
		_along -= span
		_index = (_index + 1) % _points.size()
		span = _span()
	_place()
	_pose()


func _span() -> float:
	var start: Vector3 = _points[_index]
	var finish: Vector3 = _points[(_index + 1) % _points.size()]
	return start.distance_to(finish)


func _place() -> void:
	var start: Vector3 = _points[_index]
	var finish: Vector3 = _points[(_index + 1) % _points.size()]
	var span := start.distance_to(finish)
	var weight := 0.0 if span == 0.0 else _along / span
	global_position = start.lerp(finish, weight)
	var flat := finish - start
	flat.y = 0.0
	if flat.length_squared() > 0.0001:
		look_at(global_position + flat.normalized(), Vector3.UP)


func _pose() -> void:
	var swing := sin(distance_walked * 5.0) * 0.55
	$LegL.rotation.x = swing
	$LegR.rotation.x = -swing
	$ArmL.rotation.x = -swing * 0.7
	$ArmR.rotation.x = swing * 0.7
	$Torso.position.y = 1.2 + absf(sin(distance_walked * 5.0)) * 0.04
