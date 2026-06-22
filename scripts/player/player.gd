extends CharacterBody2D

enum FacingDirection { DOWN, UP, LEFT, RIGHT }

@export var speed: float = 120.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction: int = FacingDirection.DOWN

func _ready() -> void:
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
