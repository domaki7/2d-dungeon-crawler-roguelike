class_name EnemyState
extends State

var enemy: CharacterBody2D

func _ready() -> void:
	await owner.ready
	enemy = owner as CharacterBody2D

func get_player() -> CharacterBody2D:
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		return players[0] as CharacterBody2D
	return null

func get_distance_to_player() -> float:
	var player: CharacterBody2D = get_player()
	if player:
		return enemy.global_position.distance_to(player.global_position)
	return INF

func get_direction_to_player() -> Vector2:
	var player: CharacterBody2D = get_player()
	if player:
		return enemy.global_position.direction_to(player.global_position)
	return Vector2.ZERO
