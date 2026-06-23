extends Node2D

@onready var room_container: Node2D = $RoomContainer
@onready var player: CharacterBody2D = $Player

var _current_room: RoomTemplate = null

func _ready() -> void:
	_current_room = room_container.get_child(0) as RoomTemplate
	if _current_room:
		player.global_position = _current_room.get_player_spawn_position()
		_current_room.room_cleared_signal.connect(_on_room_cleared)
		_set_camera_limits()
		_current_room.activate()

func _set_camera_limits() -> void:
	var cam: Camera2D = player.get_node("Camera2D") as Camera2D
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 384
		cam.limit_bottom = 256

func _on_room_cleared() -> void:
	pass
