extends Node

var _set_bonuses: Array[SetBonusData] = []

func _ready() -> void:
	_load_set_bonuses()

func _load_set_bonuses() -> void:
	var dir: DirAccess = DirAccess.open("res://resources/sets")
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var path: String = "res://resources/sets/" + file_name
			var res: Resource = load(path)
			if res is SetBonusData:
				_set_bonuses.append(res as SetBonusData)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_active_set_bonuses(equipment: Dictionary) -> Array[SetBonusData]:
	var active: Array[SetBonusData] = []
	for bonus: SetBonusData in _set_bonuses:
		var count: int = _count_set_pieces(bonus.set_id, equipment)
		if count >= bonus.required_pieces:
			active.append(bonus)
	return active

func get_set_pieces_equipped(set_id: StringName, equipment: Dictionary) -> int:
	return _count_set_pieces(set_id, equipment)

func get_all_set_bonuses() -> Array[SetBonusData]:
	return _set_bonuses

func get_set_total_pieces(set_id: StringName) -> int:
	var max_req: int = 0
	for bonus: SetBonusData in _set_bonuses:
		if bonus.set_id == set_id and bonus.required_pieces > max_req:
			max_req = bonus.required_pieces
	return max_req

func _count_set_pieces(set_id: StringName, equipment: Dictionary) -> int:
	var count: int = 0
	for item: Variant in equipment.values():
		var item_data: ItemData = item as ItemData
		if item_data and item_data.set_id == set_id:
			count += 1
	return count
