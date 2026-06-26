extends CharacterBody2D

enum FacingDirection { DOWN, UP, LEFT, RIGHT }

@export var acceleration: float = 800.0
@export var friction: float = 600.0

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var player_stats: PlayerStats = $PlayerStats
@onready var ability_manager: AbilityManager = $AbilityManager

var facing_direction: int = FacingDirection.DOWN
var gold: int = 0
var speed: float = 120.0

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

func get_defense() -> int:
	return player_stats.get_effective_defense()

func get_ability_damage(base_damage: int) -> int:
	return int(float(base_damage) * ability_manager.get_damage_multiplier())

func _on_stats_changed() -> void:
	speed = player_stats.get_effective_speed()
	hitbox.damage = player_stats.get_effective_damage()
	hitbox.knockback_force = player_stats.get_effective_knockback_force()
	hitbox.crit_chance = player_stats.get_effective_crit_chance()
	health_component.set_max_hp(player_stats.get_effective_max_hp())

func _on_health_damaged(_amount: int) -> void:
	state_machine.transition_to(&"HurtState")
