class_name OrderBoard
extends RefCounted

## One introductory contract. Fulfillment spends inventory and returns a new fund total.
## A failure leaves both alone.

var status := {}


func _init() -> void:
	_fill_missing()


func try_fulfill(order_id: String, inventory: FarmInventory, funds: int) -> Dictionary:
	var spec := ResourceCatalog.order(order_id)
	if spec.is_empty():
		return _same("unknown_order", funds)
	var state := str(status.get(order_id, ""))
	if state == "done":
		return _same("already_done", funds)
	if state != "open":
		return _same("unknown_order", funds)
	var requires: Array = spec["requires"]
	var picks: Array = []
	for input in requires:
		var resource_id := str(input["id"])
		var amount := int(input["amount"])
		var grade := inventory.lowest_grade_with(resource_id, amount)
		if grade == 0:
			return _same("missing_goods", funds)
		picks.append([resource_id, amount, grade])
	var spent_grade := 0
	for pick in picks:
		var resource_id := str(pick[0])
		var amount := int(pick[1])
		var grade := int(pick[2])
		if not inventory.remove(resource_id, grade, amount):
			return _same("missing_goods", funds)
		spent_grade = grade
	status[order_id] = "done"
	return {
		"error": "",
		"funds": funds + int(spec["reward_funds"]),
		"grade": spent_grade,
	}


func export_state() -> Dictionary:
	var copy := {}
	for key in status.keys():
		copy[str(key)] = str(status[key])
	return copy


func import_state(data: Dictionary) -> void:
	status = {}
	for key in data.keys():
		status[str(key)] = str(data[key])
	_fill_missing()


func _fill_missing() -> void:
	for spec in ResourceCatalog.orders():
		var order_id := str(spec["id"])
		if not status.has(order_id):
			status[order_id] = "open"


func _same(reason: String, funds: int) -> Dictionary:
	return {"error": reason, "funds": funds, "grade": 0}
