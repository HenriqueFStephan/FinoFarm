class_name StaffCatalog
extends RefCounted

## Recruitment rows. Attributes are game ratings from 1 to 10.
## They are not a model of a real job or a real person.

const ATTRIBUTE_KEYS: Array[String] = [
	"efficiency",
	"technical",
	"creativity",
	"organization",
	"social",
	"adaptability",
]

const ATTRIBUTE_LABELS := {
	"efficiency": "Efficiency",
	"technical": "Technical Skill",
	"creativity": "Creativity",
	"organization": "Organization",
	"social": "Social Skill",
	"adaptability": "Adaptability",
}


static func workers() -> Array:
	var found: Array = []
	for entry in _definitions():
		found.append((entry as Dictionary).duplicate(true))
	return found


static func worker(worker_id: String) -> Dictionary:
	for entry in _definitions():
		if str(entry["id"]) == worker_id:
			return (entry as Dictionary).duplicate(true)
	return {}


static func attribute_total(person: Dictionary) -> int:
	var total := 0
	for key in ATTRIBUTE_KEYS:
		total += int(person.get(key, 0))
	return total


static func attribute_lines(person: Dictionary) -> PackedStringArray:
	var first := PackedStringArray()
	var second := PackedStringArray()
	var index := 0
	for key in ATTRIBUTE_KEYS:
		var piece := "%s %d" % [str(ATTRIBUTE_LABELS[key]), int(person.get(key, 0))]
		if index < 3:
			first.append(piece)
		else:
			second.append(piece)
		index += 1
	return PackedStringArray([" · ".join(first), " · ".join(second)])


static func _definitions() -> Array:
	return [
		{
			"id": "alex_morgan",
			"name": "Alex Morgan",
			"role": "Junior Technician",
			"background": "Learns the bench quickly and likes equipment work.",
			"efficiency": 6,
			"technical": 8,
			"creativity": 4,
			"organization": 5,
			"social": 3,
			"adaptability": 7,
			"traits": ["Quick Learner", "Prefers Technical Work"],
			"wage": 18,
			"preferred": "workshop",
		},
		{
			"id": "bram_holt",
			"name": "Bram Holt",
			"role": "Yard Hand",
			"background": "Keeps the yard moving and would rather talk than run a loom.",
			"efficiency": 3,
			"technical": 2,
			"creativity": 4,
			"organization": 3,
			"social": 6,
			"adaptability": 5,
			"traits": ["Steady Pace", "Prefers People"],
			"wage": 12,
			"preferred": "yard",
		},
	]
