extends CharacterBody2D

enum FacingDirection { DOWN, UP, LEFT, RIGHT }

@export var patrol_points: Array[Marker2D] = []

var difficulty_speed_multiplier: float = 1.0
var is_elite: bool = false
var gold_multiplier: float = 1.0

var speed: float:
	get:
		var base: float = GameConfig.config.archer_speed * difficulty_speed_multiplier
		if status_effect_component:
			return base * status_effect_component.get_speed_multiplier()
		return base
var acceleration: float:
	get: return GameConfig.config.archer_acceleration
var friction: float:
	get: return GameConfig.config.archer_friction

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var detection_area: Area2D = $DetectionArea
@onready var status_effect_component: StatusEffectComponent = $StatusEffectComponent

var facing_direction: int = FacingDirection.DOWN
var is_player_detected: bool = false
var is_aggroed: bool = false
var spawn_position: Vector2 = Vector2.ZERO
var last_known_player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group(&"enemies")
	spawn_position = global_position
	health_component.damaged.connect(_on_health_damaged)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	EventBus.enemy_aggroed.connect(_on_enemy_aggroed)
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.start(&"IdleState")

func update_facing(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
	var old_direction: int = facing_direction
	if absf(direction.x) > absf(direction.y):
		facing_direction = FacingDirection.RIGHT if direction.x > 0.0 else FacingDirection.LEFT
	else:
		facing_direction = FacingDirection.DOWN if direction.y > 0.0 else FacingDirection.UP
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
	var anim_name: StringName = StringName(base_name + suffix)
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func _on_health_damaged(_amount: int) -> void:
	if status_effect_component and status_effect_component.is_stunned():
		state_machine.transition_to(&"StunnedState")
	else:
		state_machine.transition_to(&"HurtState")

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		if not is_player_detected:
			VFXHelper.spawn_alert_indicator(global_position + Vector2(0, GameConfig.config.enemy_alert_icon_offset_y))
			AudioManager.play_sfx_varied(&"enemy_hurt", GameConfig.config.enemy_alert_sfx_pitch_min, GameConfig.config.enemy_alert_sfx_pitch_max)
		is_player_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_detected = false

func _on_enemy_aggroed() -> void:
	is_aggroed = true
