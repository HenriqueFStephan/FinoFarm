class_name FarmLibrary
extends RefCounted

## One JSON file per farm plus an index, under root_path.
## The game uses user://saves. Tests pass a different root_path.

var root_path := "user://saves"


func list_ids() -> PackedStringArray:
	var found := PackedStringArray()
	for farm_id in _read_index().get("order", []):
		var id := str(farm_id)
		if _safe_id(id) and FileAccess.file_exists(_file_for(id)):
			found.append(id)
	return found


func summaries() -> Array:
	var rows: Array = []
	for farm_id in list_ids():
		var loaded := load_farm(farm_id)
		if loaded["ok"]:
			rows.append((loaded["game"] as SaveGame).summary())
	return rows


func active_id() -> String:
	var id := str(_read_index().get("active_id", ""))
	if not _safe_id(id) or not FileAccess.file_exists(_file_for(id)):
		return ""
	return id


func set_active(farm_id: String) -> String:
	if not _safe_id(farm_id) or not FileAccess.file_exists(_file_for(farm_id)):
		return "missing"
	var index := _read_index()
	index["active_id"] = farm_id
	return _write_index(index)


func load_farm(farm_id: String) -> Dictionary:
	if not _safe_id(farm_id):
		return {"ok": false, "error": "missing", "game": null}
	var path := _file_for(farm_id)
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "missing", "game": null}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "corrupt", "game": null}
	return SaveGame.from_dict(parsed)


func write(game: SaveGame) -> String:
	if game == null or not _safe_id(game.farm_id):
		return "bad_id"
	game.last_saved_unix = int(Time.get_unix_time_from_system())
	var dir_err := DirAccess.make_dir_recursive_absolute(root_path)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return "write_failed"
	var file := FileAccess.open(_file_for(game.farm_id), FileAccess.WRITE)
	if file == null:
		return "write_failed"
	file.store_string(JSON.stringify(game.to_dict(), "\t"))
	file.close()
	var index := _read_index()
	var order: Array = index.get("order", [])
	if not order.has(game.farm_id):
		order.append(game.farm_id)
	index["order"] = order
	index["active_id"] = game.farm_id
	return _write_index(index)


func wipe() -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return
	var names: PackedStringArray = dir.get_files()
	for file_name in names:
		dir.remove(file_name)


func _file_for(farm_id: String) -> String:
	return "%s/%s.json" % [root_path, farm_id]


func _index_path() -> String:
	return "%s/index.json" % root_path


func _safe_id(farm_id: String) -> bool:
	if farm_id == "" or farm_id.begins_with("."):
		return false
	if farm_id.contains("/") or farm_id.contains("\\") or farm_id.contains(".."):
		return false
	return true


func _read_index() -> Dictionary:
	if not FileAccess.file_exists(_index_path()):
		return {"active_id": "", "order": []}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(_index_path()))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"active_id": "", "order": []}
	var index: Dictionary = parsed
	if not index.has("order") or typeof(index["order"]) != TYPE_ARRAY:
		index["order"] = []
	if not index.has("active_id"):
		index["active_id"] = ""
	return index


func _write_index(index: Dictionary) -> String:
	var dir_err := DirAccess.make_dir_recursive_absolute(root_path)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return "write_failed"
	var file := FileAccess.open(_index_path(), FileAccess.WRITE)
	if file == null:
		return "write_failed"
	file.store_string(JSON.stringify(index, "\t"))
	file.close()
	return ""
