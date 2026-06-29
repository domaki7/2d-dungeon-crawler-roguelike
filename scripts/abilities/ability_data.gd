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

@export_group("Multishot")
@export var arrow_count: int = 5
@export var spread_angle_degrees: float = 30.0

@export_group("Rain of Arrows")
@export var rain_delay: float = 0.4
@export var rain_duration: float = 0.6

@export_group("Mana")
@export var mana_cost: int = 0

@export_group("Ice Shard")
@export var slow_duration: float = 3.0

@export_group("Chain Lightning")
@export var bounce_count: int = 3
@export var bounce_range: float = 60.0
@export var cast_range: float = 80.0

@export_group("Fire Wall")
@export var wall_length: float = 48.0
@export var wall_width: float = 12.0
@export var wall_duration: float = 3.0
@export var wall_tick_interval: float = 0.5
@export var burn_duration: float = 2.0

@export_group("Blink")
@export var blink_distance: float = 60.0
