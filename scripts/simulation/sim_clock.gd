class_name SimClock
extends RefCounted

## Fixed 1-second ticks. Callers pass elapsed time; the result does not
## depend on how that time was split across frames.

const TICK_MS := 1000

var tick_index := 0
var remainder_ms := 0


func advance(delta_seconds: float) -> int:
	if delta_seconds <= 0.0:
		return 0
	return advance_ms(int(round(delta_seconds * 1000.0)))


func advance_ms(delta_ms: int) -> int:
	if delta_ms <= 0:
		return 0
	remainder_ms += delta_ms
	var ticks := int(remainder_ms / TICK_MS)
	remainder_ms -= ticks * TICK_MS
	tick_index += ticks
	return ticks
