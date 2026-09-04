class_name ConsumablePool
extends RefCounted

## Shared weighted pool of consumables, used by breakable drops and shop stock
## so both pull from one list instead of each hardcoding their own.

const HEALTH_POTION: ItemData = preload("res://resources/items/consumables/health_potion.tres")
const GREATER_HEALTH_POTION: ItemData = preload("res://resources/items/consumables/greater_health_potion.tres")
const RAGE_POTION: ItemData = preload("res://resources/items/consumables/rage_potion.tres")
const SWIFTNESS_POTION: ItemData = preload("res://resources/items/consumables/swiftness_potion.tres")
const ANTIDOTE: ItemData = preload("res://resources/items/consumables/antidote.tres")

## Healing is deliberately the common case — the belt's main job is keeping a
## run alive, and the buff potions are the treat.
const _WEIGHTED_DROPS: Array[Dictionary] = [
	{"item": HEALTH_POTION, "weight": 50.0},
	{"item": SWIFTNESS_POTION, "weight": 18.0},
	{"item": RAGE_POTION, "weight": 15.0},
	{"item": ANTIDOTE, "weight": 10.0},
	{"item": GREATER_HEALTH_POTION, "weight": 7.0},
]

static func all() -> Array[ItemData]:
	return [HEALTH_POTION, GREATER_HEALTH_POTION, RAGE_POTION, SWIFTNESS_POTION, ANTIDOTE]

static func roll_drop() -> ItemData:
	var total_weight: float = 0.0
	for entry: Dictionary in _WEIGHTED_DROPS:
		total_weight += entry["weight"] as float
	var roll_value: float = randf() * total_weight
	var cumulative: float = 0.0
	for entry: Dictionary in _WEIGHTED_DROPS:
		cumulative += entry["weight"] as float
		if roll_value <= cumulative:
			return entry["item"] as ItemData
	return HEALTH_POTION
