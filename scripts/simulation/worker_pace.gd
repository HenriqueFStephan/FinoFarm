class_name WorkerPace
extends RefCounted

## Turns an attribute total into bundle_fiber ticks.
## An empty worker keeps the catalog duration, which is the tutorial pace.

const POINTS_PER_TICK := 12


static func bundle_ticks(person: Dictionary) -> int:
	return job_ticks("bundle_fiber", person, 0)


## Catalog duration, then the attribute total, then an optional building speed bonus.
## speed_ticks is 0 unless the shuttle rack is owned. A running job does not call this again.
static func job_ticks(recipe_id: String, person: Dictionary, speed_ticks: int = 0) -> int:
	var recipe := ResourceCatalog.recipe(recipe_id)
	if recipe.is_empty():
		return 1
	var base := int(recipe["duration_ticks"])
	var paced := base
	if not person.is_empty():
		var total := StaffCatalog.attribute_total(person)
		if total > 0:
			paced = maxi(1, base - int(total / float(POINTS_PER_TICK)))
	if speed_ticks > 0:
		paced = maxi(1, paced - speed_ticks)
	return paced
