class_name SimStepper
extends RefCounted

var clock: SimClock
var workshop: Workshop


func _init(starting_clock: SimClock, starting_workshop: Workshop) -> void:
	clock = starting_clock
	workshop = starting_workshop


func step(delta_seconds: float) -> Dictionary:
	var ticks := clock.advance(delta_seconds)
	if ticks <= 0:
		return {}
	return workshop.tick(ticks)
