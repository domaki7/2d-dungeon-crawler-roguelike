extends CharacterBody2D

enum FacingDirection { DOWN, UP, LEFT, RIGHT }

var speed: float:
	get:
		var base: float = GameConfig.config.skeleton_speed
		if status_effect_component:
			return base * status_effect_component.get_speed_multiplier()
		return base
var acceleration: float:
	get: return GameConfig.config.skeleton_acceleration
var friction: float:
	get: return GameConfig.config.skeleton_friction

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

func _ready() -> void:
	add_to_group(&"enemies")
	health_component.damaged.connect(_on_health_damaged)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	EventBus.room_entered.connect(_on_room_entered)
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
		is_player_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_detected = false

func _on_room_entered(_room_id: int) -> void:
	is_aggroed = true

func _on_enemy_aggroed() -> void:
	is_aggroed = true
