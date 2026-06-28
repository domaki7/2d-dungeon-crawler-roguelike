extends CharacterBody2D

enum FacingDirection { DOWN, UP, LEFT, RIGHT }

var speed: float:
	get: return GameConfig.config.boss_speed
var acceleration: float:
	get: return GameConfig.config.boss_acceleration
var friction: float:
	get: return GameConfig.config.boss_friction
var phase_2_threshold: float:
	get: return GameConfig.config.boss_phase_2_threshold
var phase_3_threshold: float:
	get: return GameConfig.config.boss_phase_3_threshold

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var detection_area: Area2D = $DetectionArea

var facing_direction: int = FacingDirection.DOWN
var is_player_detected: bool = false
var current_phase: int = 1
var _fight_started: bool = false

func _ready() -> void:
	add_to_group(&"enemies")
	add_to_group(&"bosses")
	health_component.damaged.connect(_on_health_damaged)
	health_component.health_changed.connect(_on_health_changed)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.start(&"IdleState")

func start_boss_fight() -> void:
	if _fight_started:
		return
	_fight_started = true
	EventBus.boss_fight_started.emit("Skeleton Knight", health_component)

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
	if has_meta(&"stun_duration"):
		state_machine.transition_to(&"StunnedState")
	else:
		state_machine.transition_to(&"HurtState")

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	var hp_ratio: float = float(current_hp) / float(max_hp)
	var new_phase: int = 1
	if hp_ratio <= phase_3_threshold:
		new_phase = 3
	elif hp_ratio <= phase_2_threshold:
		new_phase = 2
	if new_phase != current_phase:
		current_phase = new_phase
		EventBus.boss_phase_changed.emit(current_phase, 3)

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_detected = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_detected = false
