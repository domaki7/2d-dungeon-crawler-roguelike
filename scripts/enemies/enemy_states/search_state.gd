extends EnemyState

var search_duration: float:
	get: return GameConfig.config.enemy_search_duration
var arrival_threshold: float:
	get: return GameConfig.config.enemy_search_arrival_threshold

var _timer: float = 0.0
var _target_position: Vector2 = Vector2.ZERO
var _has_arrived: bool = false

func enter() -> void:
	_timer = search_duration
	_target_position = enemy.last_known_player_position
	_has_arrived = false
	enemy.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	if enemy.is_player_detected or enemy.is_aggroed:
		transition_requested.emit(self, &"ChaseState")
		return

	_timer -= delta
	if _timer <= 0.0:
		transition_requested.emit(self, &"IdleState")
		return

	if not _has_arrived:
		var direction: Vector2 = enemy.global_position.direction_to(_target_position)
		var distance: float = enemy.global_position.distance_to(_target_position)
		if distance <= arrival_threshold:
			_has_arrived = true
			enemy.play_directional_animation("idle")
		else:
			if enemy.update_facing(direction):
				enemy.play_directional_animation("walk")
			enemy.velocity = enemy.velocity.move_toward(direction * enemy.speed, enemy.acceleration * delta)
	else:
		enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()
