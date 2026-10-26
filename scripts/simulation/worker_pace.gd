class_name WorkerPace
extends RefCounted

## Turns an attribute total into bundle_fiber ticks.
## An empty worker keeps the catalog duration, which is the tutorial pace.

const POINTS_PER_TICK := 12


static func bundle_ticks(person: Dictionary) -> int:
	var base := int(ResourceCatalog.recipe("bundle_fiber")["duration_ticks"])
	if person.is_empty():
		return base
	var total := StaffCatalog.attribute_total(person)
	if total <= 0:
		return base
	return maxi(1, base - int(total / float(POINTS_PER_TICK)))
