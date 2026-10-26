class_name TutorialTrack
extends RefCounted

## Guided steps for one production, sale, and upgrade. Hiring is not part of this track.

const PLACE := 0
const GROW := 1
const HARVEST := 2
const WORKSHOP := 3
const BUNDLE := 4
const ORDER := 5
const UPGRADE := 6
const DONE := 7

var step := 0


func prompt() -> String:
	match step:
		PLACE:
			return "Mara: The row is empty. Place a plot on open ground, away from the barn."
		GROW:
			return "Mara: Verdant Fiber is on a timer. Wait until the plot reads ready."
		HARVEST:
			return "Mara: It's ready. Harvest the fiber into your inventory."
		WORKSHOP:
			return "Mara: Click the workshop and bundle two fibers."
		BUNDLE:
			return "Mara: The workshop is running. Wait for the Fiber Bundle."
		ORDER:
			return "Mara: The stall wants that bundle. Open the order board and deliver it."
		UPGRADE:
			return "Mara: The payment landed. Buy the barn loft."
		_:
			return "Mara: You grew fiber, sold a bundle, and raised the loft. That is the loop."


func allows(action: String) -> bool:
	if step >= DONE:
		return true
	match action:
		"harvest":
			return step == HARVEST
		"workshop":
			return step == WORKSHOP
		"order":
			return step == ORDER
		"upgrade":
			return step == UPGRADE
		_:
			return false


func notify(event: String) -> void:
	var expected := ""
	match step:
		PLACE:
			expected = "placed"
		GROW:
			expected = "ready"
		HARVEST:
			expected = "harvested"
		WORKSHOP:
			expected = "started"
		BUNDLE:
			expected = "bundled"
		ORDER:
			expected = "sold"
		UPGRADE:
			expected = "upgraded"
		_:
			return
	if event == expected and step < DONE:
		step += 1


func rewind_to_place() -> void:
	if step == GROW or step == HARVEST:
		step = PLACE
