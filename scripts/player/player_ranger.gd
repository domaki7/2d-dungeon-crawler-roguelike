extends CharacterBody2D

enum FacingDirection { DOWN, DOWN_RIGHT, RIGHT, UP_RIGHT, UP, UP_LEFT, LEFT, DOWN_LEFT }

var acceleration: float:
	get: return GameConfig.config.ranger_acceleration
var friction: float:
	get: return GameConfig.config.ranger_friction
@export var arrow_scene: PackedScene

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var player_stats: PlayerStats = $PlayerStats
@onready var ability_manager: AbilityManager = $AbilityManager
@onready var item_effect_handler: ItemEffectHandler = $ItemEffectHandler

var facing_direction: int = FacingDirection.DOWN
var gold: int = 0
var speed: float = 130.0
var effective_damage: int = 2

func _ready() -> void:
	add_to_group(&"player")
	$Camera2D.add_to_group(&"main_camera")
	health_component.damaged.connect(_on_health_damaged)
	health_component.damaged.connect(func(amount: int) -> void:
		EventBus.player_damaged.emit(amount, health_component.current_hp))
	health_component.healed.connect(func(amount: int) -> void:
		EventBus.player_healed.emit(amount, health_component.current_hp))
	player_stats.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.start(&"IdleState")

func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func fire_arrow(direction: Vector2, damage_override: int = -1) -> void:
	var arrow: Area2D = arrow_scene.instantiate() as Area2D
	arrow.global_position = global_position
	var dmg: int = damage_override if damage_override > 0 else _get_live_damage()
	arrow.setup(direction, dmg)
	get_parent().add_child(arrow)
	AudioManager.play_sfx_varied(&"arrow_fire")

func update_facing(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
	var old_direction: int = facing_direction
	if absf(direction.x) > absf(direction.y):
		facing_direction = FacingDirection.RIGHT if direction.x > 0.0 else FacingDirection.LEFT
	else:
		facing_direction = FacingDirection.DOWN if direction.y > 0.0 else FacingDirection.UP
	return facing_direction != old_direction

func update_facing_from_angle(direction: Vector2) -> bool:
	if direction.is_zero_approx():
		return false
	var old_direction: int = facing_direction
	var angle: float = direction.angle()
	if angle >= -PI / 8.0 and angle < PI / 8.0:
		facing_direction = FacingDirection.RIGHT
	elif angle >= PI / 8.0 and angle < 3.0 * PI / 8.0:
		facing_direction = FacingDirection.DOWN_RIGHT
	elif angle >= 3.0 * PI / 8.0 and angle < 5.0 * PI / 8.0:
		facing_direction = FacingDirection.DOWN
	elif angle >= 5.0 * PI / 8.0 and angle < 7.0 * PI / 8.0:
		facing_direction = FacingDirection.DOWN_LEFT
	elif angle >= 7.0 * PI / 8.0 or angle < -7.0 * PI / 8.0:
		facing_direction = FacingDirection.LEFT
	elif angle >= -7.0 * PI / 8.0 and angle < -5.0 * PI / 8.0:
		facing_direction = FacingDirection.UP_LEFT
	elif angle >= -5.0 * PI / 8.0 and angle < -3.0 * PI / 8.0:
		facing_direction = FacingDirection.UP
	else:
		facing_direction = FacingDirection.UP_RIGHT
	return facing_direction != old_direction

func play_directional_animation(base_name: String) -> void:
	var suffix: String
	match facing_direction:
		FacingDirection.DOWN:
			suffix = "_down"
			animated_sprite.flip_h = false
		FacingDirection.UP:
			suffix = "_up"
			animated_sprite.flip_h = false
		FacingDirection.LEFT:
			suffix = "_side"
			animated_sprite.flip_h = true
		FacingDirection.RIGHT:
			suffix = "_side"
			animated_sprite.flip_h = false
		FacingDirection.DOWN_LEFT:
			suffix = "_down_side"
			animated_sprite.flip_h = true
		FacingDirection.DOWN_RIGHT:
			suffix = "_down_side"
			animated_sprite.flip_h = false
		FacingDirection.UP_LEFT:
			suffix = "_up_side"
			animated_sprite.flip_h = true
		FacingDirection.UP_RIGHT:
			suffix = "_up_side"
			animated_sprite.flip_h = false
	var anim_name: StringName = StringName(base_name + suffix)
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		suffix = _get_fallback_suffix()
		anim_name = StringName(base_name + suffix)
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func get_defense() -> int:
	return player_stats.get_effective_defense()

func get_ability_damage(base_damage: int) -> int:
	return int(float(base_damage) * ability_manager.get_damage_multiplier())

func _get_live_damage() -> int:
	var dmg: int = player_stats.get_effective_damage()
	if item_effect_handler:
		dmg += item_effect_handler.get_bonus_damage()
	return int(float(dmg) * ability_manager.get_damage_multiplier())

func _get_fallback_suffix() -> String:
	match facing_direction:
		FacingDirection.DOWN_LEFT:
			animated_sprite.flip_h = true
			return "_down"
		FacingDirection.DOWN_RIGHT:
			animated_sprite.flip_h = false
			return "_down"
		FacingDirection.UP_LEFT:
			animated_sprite.flip_h = true
			return "_up"
		FacingDirection.UP_RIGHT:
			animated_sprite.flip_h = false
			return "_up"
	return "_down"

func _on_stats_changed() -> void:
	speed = player_stats.get_effective_speed()
	effective_damage = player_stats.get_effective_damage()
	if item_effect_handler:
		effective_damage += item_effect_handler.get_bonus_damage()
	health_component.set_max_hp(player_stats.get_effective_max_hp())

func _on_health_damaged(_amount: int) -> void:
	AudioManager.play_sfx_varied(&"player_hurt")
	state_machine.transition_to(&"HurtState")
