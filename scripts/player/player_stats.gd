class_name PlayerStats
extends Node

signal stats_changed()
signal equipment_changed(slot_type: int, item_data: ItemData)

@export_group("Base Stats")
@export var base_damage: int = 3
@export var base_defense: int = 0
@export var base_max_hp: int = 10
@export var base_speed: float = 120.0
@export var base_knockback_force: float = 150.0
@export var base_crit_chance: float = 0.0

var _equipment: Dictionary = {}

func equip(item: ItemData) -> ItemData:
	var slot_key: int = item.slot_type as int
	var old_item: ItemData = _equipment.get(slot_key, null) as ItemData
	_equipment[slot_key] = item
	equipment_changed.emit(item.slot_type, item)
	EventBus.item_equipped.emit(_slot_type_name(item.slot_type), item)
	stats_changed.emit()
	return old_item

func unequip(slot_type: ItemData.SlotType) -> ItemData:
	var slot_key: int = slot_type as int
	var old_item: ItemData = _equipment.get(slot_key, null) as ItemData
	if old_item:
		_equipment.erase(slot_key)
		equipment_changed.emit(slot_type, null)
		EventBus.item_unequipped.emit(_slot_type_name(slot_type), old_item)
		stats_changed.emit()
	return old_item

func get_equipped(slot_type: ItemData.SlotType) -> ItemData:
	var slot_key: int = slot_type as int
	return _equipment.get(slot_key, null) as ItemData

func get_effective_damage() -> int:
	var total: int = base_damage
	for item: ItemData in _equipment.values():
		total += item.bonus_damage
	return total

func get_effective_defense() -> int:
	var total: int = base_defense
	for item: ItemData in _equipment.values():
		total += item.bonus_defense
	return total

func get_effective_max_hp() -> int:
	var total: int = base_max_hp
	for item: ItemData in _equipment.values():
		total += item.bonus_max_hp
	return total

func get_effective_speed() -> float:
	var total: float = base_speed
	for item: ItemData in _equipment.values():
		total += item.bonus_speed
	return total

func get_effective_knockback_force() -> float:
	var total: float = base_knockback_force
	for item: ItemData in _equipment.values():
		total += item.bonus_knockback_force
	return total

func get_effective_crit_chance() -> float:
	var total: float = base_crit_chance
	for item: ItemData in _equipment.values():
		total += item.bonus_crit_chance
	return total

func has_effect(effect_id: StringName) -> bool:
	for item: ItemData in _equipment.values():
		if item.effect_id == effect_id:
			return true
	return false

func get_effect_value(effect_id: StringName) -> float:
	for item: ItemData in _equipment.values():
		if item.effect_id == effect_id:
			return item.effect_value
	return 0.0

func _slot_type_name(slot_type: ItemData.SlotType) -> String:
	match slot_type:
		ItemData.SlotType.WEAPON:
			return "weapon"
		ItemData.SlotType.ARMOR:
			return "armor"
		ItemData.SlotType.RING:
			return "ring"
		ItemData.SlotType.ACCESSORY:
			return "accessory"
	return "unknown"
