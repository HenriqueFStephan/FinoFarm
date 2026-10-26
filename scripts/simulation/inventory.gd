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


func snapshot() -> Dictionary:
	var copy := {}
	for key in _amounts.keys():
		copy[key] = int(_amounts[key])
	return copy


func _key(resource_id: String, grade: int) -> String:
	return "%s#%d" % [resource_id, grade]
