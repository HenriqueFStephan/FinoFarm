class_name UpgradeShop
extends RefCounted

## One building purchase. Short funds and a second buy do not change the purse.

var owned := {}


func owns(upgrade_id: String) -> bool:
	return bool(owned.get(upgrade_id, false))


func try_purchase(upgrade_id: String, funds: int) -> Dictionary:
	var spec := ResourceCatalog.upgrade(upgrade_id)
	if spec.is_empty():
		return {"error": "unknown_upgrade", "funds": funds}
	if owns(upgrade_id):
		return {"error": "already_owned", "funds": funds}
	var cost := int(spec["cost"])
	if funds < cost:
		return {"error": "short_funds", "funds": funds}
	owned[upgrade_id] = true
	return {"error": "", "funds": funds - cost}


func export_state() -> Dictionary:
	var copy := {}
	for key in owned.keys():
		if bool(owned[key]):
			copy[str(key)] = true
	return copy


func import_state(data: Dictionary) -> void:
	owned = {}
	for key in data.keys():
		if bool(data[key]):
			owned[str(key)] = true
