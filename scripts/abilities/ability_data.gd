class_name AbilityData
extends Resource

@export var ability_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Cooldown")
@export var cooldown: float = 5.0

@export_group("Damage")
@export var damage: int = 0
@export var knockback_force: float = 0.0

@export_group("Shield Bash")
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.15
@export var stun_duration: float = 1.0

@export_group("Whirlwind")
@export var aoe_radius: float = 20.0

@export_group("War Cry")
@export var buff_duration: float = 5.0
@export var damage_multiplier: float = 1.5
