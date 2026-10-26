class_name WorkshopWorker
extends Node3D

## Second instance of the farmhand mesh, stationed at the loom.
## The path walker is not this employee. work plays only while the job is busy.

var _anim: AnimationPlayer
var _clip := ""


func _ready() -> void:
	_anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_prepare_loops()
	var name_label := get_node_or_null("WorkerName") as Label3D
	if name_label != null:
		name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_label.modulate = Color(0.98, 0.961, 0.902)
		name_label.outline_modulate = Color(0.12, 0.14, 0.1)
		name_label.font_size = 54
		name_label.outline_size = 12
		name_label.position = Vector3(0.0, 3.55, 0.0)
	var loom := WorkshopRig.WORLD_POSITION
	var aim := Vector3(loom.x, global_position.y, loom.z)
	if global_position.distance_squared_to(aim) > 0.04:
		look_at(aim, Vector3.UP)
	visible = false


func show_assignment(present: bool, working: bool, display_name: String) -> void:
	visible = present
	var name_label := get_node_or_null("WorkerName") as Label3D
	if name_label != null:
		name_label.text = display_name
	if not present:
		return
	_set_clip("work" if working else "idle")


func animation_player() -> AnimationPlayer:
	return _anim


func current_clip() -> String:
	return _clip


func _prepare_loops() -> void:
	if _anim == null:
		return
	for clip_name in ["idle", "work"]:
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
