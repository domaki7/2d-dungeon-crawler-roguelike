extends EnemyState

var attack_range: float:
	get: return GameConfig.config.bat_attack_range
var jitter_interval: float:
	get: return GameConfig.config.bat_jitter_interval
var jitter_strength: float:
	get: return GameConfig.config.bat_jitter_strength

var _jitter_timer: float = 0.0
var _jitter_direction: float = 1.0

func enter() -> void:
	enemy.play_directional_animation("walk")
	_jitter_timer = 0.0
	_jitter_direction = 1.0

func physics_process_state(delta: float) -> void:
	if not enemy.is_player_detected and not enemy.is_aggroed:
		transition_requested.emit(self, &"IdleState")
		return

	_jitter_timer += delta
	if _jitter_timer >= jitter_interval:
		_jitter_timer = 0.0
		_jitter_direction *= -1.0

	var direction: Vector2 = get_direction_to_player()
	if direction != Vector2.ZERO:
		var perpendicular: Vector2 = Vector2(-direction.y, direction.x) * _jitter_direction * jitter_strength
		var move_dir: Vector2 = (direction + perpendicular).normalized()
		if enemy.update_facing(direction):
			enemy.play_directional_animation("walk")
		enemy.velocity = enemy.velocity.move_toward(move_dir * enemy.speed, enemy.acceleration * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if get_distance_to_player() <= attack_range:
		transition_requested.emit(self, &"AttackState")
