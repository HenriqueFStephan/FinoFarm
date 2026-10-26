extends Node3D

## Stylized farmhand. The body is a glTF skin. idle and walk are exported clips.
## This script moves the root. The clip moves the limbs. There is no sine-wave pose.

const SPEED := 1.7

var distance_walked := 0.0

var _points: Array[Vector3] = []
var _index := 0
var _along := 0.0
var _anim: AnimationPlayer
var _clip := ""


func _ready() -> void:
	_points = [
		Vector3(-6.2, 0.0, 6.2),
		Vector3(6.2, 0.0, 6.2),
		Vector3(6.2, 0.0, -6.2),
		Vector3(-6.2, 0.0, -6.2),
	]
	_along = 6.2
	_anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_prepare_loops()
	_place()
	_set_clip("idle")


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if _points.is_empty():
		return
	if delta <= 0.0:
		_set_clip("idle")
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
	_set_clip("walk")


func animation_player() -> AnimationPlayer:
	return _anim


func _prepare_loops() -> void:
	if _anim == null:
		return
	for clip_name in ["idle", "walk"]:
		if not _anim.has_animation(clip_name):
			continue
		_anim.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR


func _set_clip(clip_name: String) -> void:
	if _anim == null or not _anim.has_animation(clip_name):
		return
	if _clip == clip_name and _anim.is_playing():
		return
	_clip = clip_name
	_anim.play(clip_name)


func _span() -> float:
	var start := _points[_index]
	var finish := _points[(_index + 1) % _points.size()]
	return start.distance_to(finish)


func _place() -> void:
	var start := _points[_index]
	var finish := _points[(_index + 1) % _points.size()]
	var span := start.distance_to(finish)
	var weight := 0.0 if span == 0.0 else _along / span
	global_position = start.lerp(finish, weight)
	var flat := finish - start
	flat.y = 0.0
	if flat.length_squared() > 0.0001:
		look_at(global_position + flat.normalized(), Vector3.UP)
