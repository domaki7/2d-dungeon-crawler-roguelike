extends EnemyState

var _target_position: Vector2 = Vector2.ZERO
var _wander_speed: float = 0.0
var _patrol_index: int = 0

func enter() -> void:
	var is_boss: bool = enemy.is_in_group(&"bosses")
	var speed_mult: float = GameConfig.config.boss_wander_speed_multiplier if is_boss else GameConfig.config.enemy_wander_speed_multiplier
	_wander_speed = enemy.speed * speed_mult
	_target_position = _pick_target_position()
	var direction: Vector2 = enemy.global_position.direction_to(_target_position)
	if direction != Vector2.ZERO:
		enemy.update_facing(direction)
	enemy.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	if _is_aggroed():
		transition_requested.emit(self, &"ChaseState")
		return

	var direction: Vector2 = enemy.global_position.direction_to(_target_position)
	var distance: float = enemy.global_position.distance_to(_target_position)

	if distance < 2.0:
		if _has_patrol_points():
			_patrol_index = (_patrol_index + 1) % enemy.patrol_points.size()
		transition_requested.emit(self, &"IdleState")
		return

	enemy.update_facing(direction)
	enemy.velocity = enemy.velocity.move_toward(direction * _wander_speed, enemy.acceleration * delta)
	enemy.move_and_slide()

func _is_aggroed() -> bool:
	if enemy.is_player_detected:
		return true
	if "is_aggroed" in enemy and enemy.is_aggroed:
		return true
	return false

func _has_patrol_points() -> bool:
	return "patrol_points" in enemy and (enemy.patrol_points as Array).size() > 0

func _pick_target_position() -> Vector2:
	if _has_patrol_points():
		return (enemy.patrol_points[_patrol_index] as Marker2D).global_position
	return _pick_random_point(GameConfig.config.enemy_wander_radius)

func _pick_random_point(radius: float) -> Vector2:
	var angle: float = randf() * TAU
	var dist: float = randf_range(radius * 0.3, radius)
	return enemy.spawn_position + Vector2(cos(angle), sin(angle)) * dist
