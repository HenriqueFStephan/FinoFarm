class_name PackingClerk
extends Node3D

## Distinct mesh that walks from the path to the packing bench.
## This is not the farmhand and not the loom worker.

const SPEED := 1.7
const HOME := Vector3(-6.2, 0.0, 6.2)
const JOB := Vector3(-5.15, 0.0, -0.55)

var _anim: AnimationPlayer
var _clip := ""
var _walking := false
var _working := false


func _ready() -> void:
	_anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_prepare_loops()
	var name_label := get_node_or_null("WorkerName") as Label3D
	if name_label != null:
		name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_label.modulate = Color(0.98, 0.961, 0.902)
		name_label.outline_modulate = Color(0.12, 0.14, 0.1)
		name_label.font_size = 48
		name_label.outline_size = 12
		name_label.position = Vector3(0.0, 2.7, 0.0)
	visible = false


func _process(delta: float) -> void:
	advance(delta)


func show_assignment(present: bool, working: bool, display_name: String) -> void:
	var name_label := get_node_or_null("WorkerName") as Label3D
	if name_label != null:
		name_label.text = display_name
	_working = working
	if not present:
		visible = false
		_walking = false
		return
	var arriving := not visible
	visible = true
	if arriving:
		global_position = HOME
		_walking = true
		_aim(JOB)
		_set_clip("walk")
		return
	if _walking:
		_set_clip("walk")
		return
	_face_job()
	_set_clip("work" if working else "idle")


func advance(delta: float) -> void:
	if not visible or not _walking:
		return
	if delta <= 0.0:
		_set_clip("idle")
		return
	var offset := JOB - global_position
	offset.y = 0.0
	var step := SPEED * delta
	if offset.length() <= step:
		global_position = JOB
		_walking = false
		_face_job()
		_set_clip("work" if _working else "idle")
		return
	global_position += offset.normalized() * step
	_aim(JOB)
	_set_clip("walk")


func animation_player() -> AnimationPlayer:
	return _anim


func current_clip() -> String:
	return _clip


func is_walking() -> bool:
	return _walking


func _prepare_loops() -> void:
	if _anim == null:
		return
	for clip_name in ["idle", "walk", "work"]:
		if not _anim.has_animation(clip_name):
			continue
		_anim.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR


func _aim(point: Vector3) -> void:
	var aim := Vector3(point.x, global_position.y, point.z)
	if global_position.distance_squared_to(aim) > 0.04:
		look_at(aim, Vector3.UP)


func _face_job() -> void:
	var bench := PackingRig.WORLD_POSITION
	_aim(bench)


func _set_clip(clip_name: String) -> void:
	if _anim == null or not _anim.has_animation(clip_name):
		return
	if _clip == clip_name and _anim.is_playing():
		return
	_clip = clip_name
	_anim.play(clip_name)
