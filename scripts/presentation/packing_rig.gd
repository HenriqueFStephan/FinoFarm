class_name PackingRig
extends Node3D

## Bobs the crate while the packing bench job is busy.
## The bob is not the production timer.

const WORLD_POSITION := Vector3(-6.4, 0.0, -2.2)
const SELECT_RADIUS := 1.6

@onready var crate: Node3D = $Crate
@onready var ring: MeshInstance3D = $SelectRing

var operating := false
var _bob := 0.0


func _process(delta: float) -> void:
	if operating:
		advance(delta, true)
	elif crate != null:
		crate.position.y = 0.86


func advance(delta: float, running: bool) -> void:
	if crate == null or not running or delta <= 0.0:
		return
	_bob += delta
	crate.position.y = 0.86 + sin(_bob * 4.0) * 0.05


func set_selected(selected: bool) -> void:
	if ring != null:
		ring.visible = selected
