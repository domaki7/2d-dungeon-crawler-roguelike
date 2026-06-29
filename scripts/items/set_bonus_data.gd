class_name SetBonusData
extends Resource

@export var set_id: StringName = &""
@export var set_name: String = ""
@export var required_pieces: int = 2
@export_multiline var description: String = ""

@export_group("Stat Bonuses")
@export var bonus_damage: int = 0
@export var bonus_defense: int = 0
@export var bonus_max_hp: int = 0
@export var bonus_speed: float = 0.0
@export var bonus_crit_chance: float = 0.0

@export_group("Special Effect")
@export var effect_id: StringName = &""
@export var effect_value: float = 0.0
