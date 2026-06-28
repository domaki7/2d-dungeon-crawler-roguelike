extends Node2D

@onready var room_container: Node2D = $RoomContainer

func initialize_with_player(player_node: CharacterBody2D) -> void:
	player_node.position = Vector2(192, 224)
	add_child(player_node)
	DungeonManager.initialize(room_container, player_node)
