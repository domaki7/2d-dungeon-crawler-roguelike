extends Node2D

@onready var room_container: Node2D = $RoomContainer
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	DungeonManager.initialize(room_container, player)
