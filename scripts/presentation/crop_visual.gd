class_name CropVisual
extends Node3D

## Swaps placeholder meshes to match CropPlot.stage_name. No growth timer lives here.

@onready var sprout: MeshInstance3D = $Sprout
@onready var leaf: MeshInstance3D = $Leaf
@onready var ready_tuft: MeshInstance3D = $ReadyTuft


func show_stage(stage_name: String) -> void:
	visible = stage_name != "empty"
	var past_row := stage_name == "sprout" or stage_name == "leaf" or stage_name == "ready"
	sprout.visible = past_row
	leaf.visible = stage_name == "leaf" or stage_name == "ready"
	ready_tuft.visible = stage_name == "ready"


func ready_visible() -> bool:
	return ready_tuft.visible
