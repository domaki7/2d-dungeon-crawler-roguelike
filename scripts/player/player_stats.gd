class_name PlayerStats
extends Node

signal stats_changed()
signal equipment_changed(slot_type: int, item_data: ItemData)

var base_damage: int:
	get: return GameConfig.config.player_base_damage
var base_defense: int:
	get: return GameConfig.config.player_base_defense
var base_max_hp: int:
	get: return GameConfig.config.player_base_max_hp
var base_speed: float:
	get: return GameConfig.config.player_base_speed
var base_knockback_force: float:
	get: return GameConfig.config.player_base_knockback_force
var base_crit_chance: float:
	get: return GameConfig.config.player_base_crit_chance

## Set once at run start from SaveManager meta-progression passives.
var meta_max_hp_bonus: int = 0
var meta_crit_chance_bonus: float = 0.0
var meta_gold_multiplier: float = 1.0

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
	for bonus: SetBonusData in _get_active_set_bonuses():
		total += bonus.bonus_damage
	return total

func get_effective_defense() -> int:
	var total: int = base_defense
	for item: ItemData in _equipment.values():
		total += item.bonus_defense
	for bonus: SetBonusData in _get_active_set_bonuses():
		total += bonus.bonus_defense
	return total

func get_effective_max_hp() -> int:
	var total: int = base_max_hp + meta_max_hp_bonus
	for item: ItemData in _equipment.values():
		total += item.bonus_max_hp
	for bonus: SetBonusData in _get_active_set_bonuses():
		total += bonus.bonus_max_hp
	return total

func get_effective_speed() -> float:
	var total: float = base_speed
	for item: ItemData in _equipment.values():
		total += item.bonus_speed
	for bonus: SetBonusData in _get_active_set_bonuses():
		total += bonus.bonus_speed
	return total

func get_effective_knockback_force() -> float:
	var total: float = base_knockback_force
	for item: ItemData in _equipment.values():
		total += item.bonus_knockback_force
	return total

func get_effective_crit_chance() -> float:
	var total: float = base_crit_chance + meta_crit_chance_bonus
	for item: ItemData in _equipment.values():
		total += item.bonus_crit_chance
	for bonus: SetBonusData in _get_active_set_bonuses():
		total += bonus.bonus_crit_chance
	if has_effect(&"speed_to_crit"):
		var speed_bonus: float = get_effective_speed() - base_speed
		if speed_bonus > 0.0:
			total += speed_bonus * GameConfig.config.legendary_speed_to_crit_ratio
	return total

func has_effect(effect_id: StringName) -> bool:
	for item: ItemData in _equipment.values():
		if item.effect_id == effect_id:
			return true
	for bonus: SetBonusData in _get_active_set_bonuses():
		if bonus.effect_id == effect_id:
			return true
	return false

func get_effect_value(effect_id: StringName) -> float:
	var total: float = 0.0
	for item: ItemData in _equipment.values():
		if item.effect_id == effect_id:
			total += item.effect_value
	for bonus: SetBonusData in _get_active_set_bonuses():
		if bonus.effect_id == effect_id:
			total += bonus.effect_value
	return total

func get_active_sets() -> Array[SetBonusData]:
	return _get_active_set_bonuses()

func _get_active_set_bonuses() -> Array[SetBonusData]:
	return SetBonusManager.get_active_set_bonuses(_equipment)

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
