class_name ItemData
extends Resource

## CONSUMABLE is appended last so the integer values of the existing equipment
## slots stay stable — every item .tres stores slot_type as a raw int.
enum SlotType { WEAPON, ARMOR, RING, ACCESSORY, CONSUMABLE }
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
enum ConsumableEffect { NONE, HEAL, HEAL_PERCENT, DAMAGE_BUFF, SPEED_BUFF, CLEANSE }

@export var item_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var slot_type: SlotType = SlotType.WEAPON
@export var rarity: Rarity = Rarity.COMMON

@export_group("Stats")
@export var bonus_damage: int = 0
@export var bonus_defense: int = 0
@export var bonus_max_hp: int = 0
@export var bonus_speed: float = 0.0
@export var bonus_knockback_force: float = 0.0
@export var bonus_crit_chance: float = 0.0

@export_group("Set")
@export var set_id: StringName = &""

@export_group("Special Effect")
@export var effect_id: StringName = &""
@export var effect_value: float = 0.0

@export_group("Consumable")
## What using this item from the belt does. NONE on all equipment.
@export var consumable_effect: ConsumableEffect = ConsumableEffect.NONE
## Flat HP for HEAL, fraction of max HP for HEAL_PERCENT, bonus damage for
## DAMAGE_BUFF, bonus speed for SPEED_BUFF.
@export var consumable_value: float = 0.0
## Buff lifetime in seconds. Ignored by the instant effects.
@export var consumable_duration: float = 0.0
## How many of this consumable the belt slot can hold at once.
@export var max_stack: int = 5

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0

func is_consumable() -> bool:
	return slot_type == SlotType.CONSUMABLE
