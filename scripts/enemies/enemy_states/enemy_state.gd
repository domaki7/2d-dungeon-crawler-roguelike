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

func update_last_known_position() -> void:
	if not enemy.is_player_detected:
		return
	var player: CharacterBody2D = get_player()
	if player:
		enemy.last_known_player_position = player.global_position

func get_surround_direction(spread_radius: float) -> Vector2:
	var player: CharacterBody2D = get_player()
	if player == null:
		return Vector2.ZERO

	var chasers: Array[Node] = get_tree().get_nodes_in_group(&"melee_chasers")
	var active: Array[Node] = []
	for chaser: Node in chasers:
		if not is_instance_valid(chaser):
			continue
		var sm: StateMachine = chaser.get("state_machine")
		if sm and sm.current_state and sm.current_state.name == &"ChaseState":
			active.append(chaser)

	if active.size() < GameConfig.config.enemy_surround_min_chasers:
		return get_direction_to_player()

	active.sort_custom(func(a: Node, b: Node) -> bool: return a.get_instance_id() < b.get_instance_id())
	var index: int = active.find(enemy)
	var angle: float = (TAU / active.size()) * index
	var target: Vector2 = player.global_position + Vector2(spread_radius, 0.0).rotated(angle)
	return enemy.global_position.direction_to(target)
