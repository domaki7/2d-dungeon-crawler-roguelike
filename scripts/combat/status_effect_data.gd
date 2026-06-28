class_name StatusEffectData
extends Resource

enum Type { STUN, BURN, POISON, FREEZE, SLOW }

## Which status effect this represents
@export var type: Type = Type.BURN
## How long the effect lasts (seconds)
@export var duration: float = 3.0
## Time between damage ticks for DoT effects (seconds). 0.0 = no ticking
@export var tick_interval: float = 0.0
## Damage dealt per tick (0 for non-damage effects)
@export var damage_per_tick: int = 0
## Movement speed multiplier while active (1.0 = no change, 0.1 = 90% slow)
@export var speed_multiplier: float = 1.0
## Tint color applied to the entity's sprite while active
@export var tint_color: Color = Color.WHITE
## Looping particle scene spawned on the entity while active
@export var particle_scene: PackedScene = null
