class_name ItemData
extends Resource

enum SlotType { WEAPON, ARMOR, RING, ACCESSORY }
enum Rarity { COMMON, UNCOMMON, RARE }

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

@export_group("Special Effect")
@export var effect_id: StringName = &""
@export var effect_value: float = 0.0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
