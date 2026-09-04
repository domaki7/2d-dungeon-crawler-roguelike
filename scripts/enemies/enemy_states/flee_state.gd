extends EnemyState

var flee_duration: float:
	get: return GameConfig.config.enemy_flee_duration
var flee_speed_multiplier: float:
	get: return GameConfig.config.enemy_flee_speed_multiplier

var _timer: float = 0.0

func enter() -> void:
	_timer = flee_duration
	enemy.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	update_last_known_position()
	_timer -= delta

	var away: Vector2 = -get_direction_to_player()
	if away != Vector2.ZERO:
		if enemy.update_facing(away):
			enemy.play_directional_animation("walk")
		enemy.velocity = enemy.velocity.move_toward(away * enemy.speed * flee_speed_multiplier, enemy.acceleration * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if _timer <= 0.0:
		if enemy.is_player_detected or enemy.is_aggroed:
			transition_requested.emit(self, &"ChaseState")
		else:
			transition_requested.emit(self, &"SearchState")
