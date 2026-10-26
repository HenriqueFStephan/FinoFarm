class_name FarmInventory
extends RefCounted

var _amounts: Dictionary = {}


func add(resource_id: String, amount: int, grade: int) -> bool:
	if amount <= 0 or not GradeScale.is_valid(grade):
		return false
	if not ResourceCatalog.resources().has(resource_id):
		return false
	var key := _key(resource_id, grade)
	_amounts[key] = int(_amounts.get(key, 0)) + amount
	return true


func remove(resource_id: String, grade: int, amount: int) -> bool:
	if amount <= 0 or not GradeScale.is_valid(grade):
		return false
	var key := _key(resource_id, grade)
	var have := int(_amounts.get(key, 0))
	if have < amount:
		return false
	var left := have - amount
	if left == 0:
		_amounts.erase(key)
	else:
		_amounts[key] = left
	return true


func amount(resource_id: String, grade: int) -> int:
	return int(_amounts.get(_key(resource_id, grade), 0))


## Lowest valid grade that already holds at least `amount`. 0 if none do.
func lowest_grade_with(resource_id: String, amount: int) -> int:
	if amount <= 0:
		return 0
	for grade in [GradeScale.COMMON, GradeScale.FINE, GradeScale.SELECT]:
		if self.amount(resource_id, grade) >= amount:
			return grade
	return 0


func snapshot() -> Dictionary:
	var copy := {}
	for key in _amounts.keys():
		copy[key] = int(_amounts[key])
	return copy


## Replace stacks with a snapshot. Returns false and keeps the previous stacks
## when any entry is not a known resource, grade, and positive amount.
func apply_snapshot(data: Dictionary) -> bool:
	var parsed: Array = []
	for key in data.keys():
		var parts := str(key).split("#")
		if parts.size() != 2 or not parts[1].is_valid_int():
			return false
		var grade := int(parts[1])
		var amount := int(data[key])
		if amount <= 0 or not GradeScale.is_valid(grade):
			return false
		if not ResourceCatalog.resources().has(parts[0]):
			return false
		parsed.append([parts[0], amount, grade])
	_amounts.clear()
	for row in parsed:
		add(str(row[0]), int(row[1]), int(row[2]))
	return true


func _key(resource_id: String, grade: int) -> String:
	return "%s#%d" % [resource_id, grade]
