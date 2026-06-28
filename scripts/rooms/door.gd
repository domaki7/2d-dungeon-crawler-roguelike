class_name Door
extends Area2D

signal door_entered(door: Door)

enum Direction { NORTH, SOUTH, EAST, WEST }

@export var direction: Direction = Direction.NORTH
@export var is_locked: bool = false

var locked_color: Color:
	get: return GameConfig.config.ui_door_locked_color
var unlocked_color: Color:
	get: return GameConfig.config.ui_door_unlocked_color

@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_blocker: StaticBody2D = $WallBlocker
@onready var wall_blocker_shape: CollisionShape2D = $WallBlocker/CollisionShape2D

func _ready() -> void:
	collision_layer = 256
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	_update_visual()

func lock() -> void:
	is_locked = true
	wall_blocker_shape.set_deferred("disabled", false)
	_update_visual()
	AudioManager.play_sfx(&"door_lock")

func unlock() -> void:
	is_locked = false
	wall_blocker_shape.set_deferred("disabled", true)
	_update_visual()
	AudioManager.play_sfx(&"door_open")

func _update_visual() -> void:
	if sprite:
		sprite.modulate = locked_color if is_locked else unlocked_color

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player") and not is_locked:
		door_entered.emit(self)
		EventBus.door_transition_requested.emit(self)
