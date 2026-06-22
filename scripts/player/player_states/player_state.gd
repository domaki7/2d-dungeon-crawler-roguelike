class_name PlayerState
extends State

var player: CharacterBody2D

func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody2D

func get_input_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
