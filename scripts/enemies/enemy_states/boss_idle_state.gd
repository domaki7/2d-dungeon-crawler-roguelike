extends EnemyState

var _pause_timer: float = 0.0

func enter() -> void:
	enemy.play_directional_animation("idle")
	_pause_timer = randf_range(GameConfig.config.enemy_wander_pause_min, GameConfig.config.enemy_wander_pause_max)

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * delta)
	enemy.move_and_slide()

	if enemy.is_player_detected:
		enemy.start_boss_fight()
		transition_requested.emit(self, &"ChaseState")
		return

	_pause_timer -= delta
	if _pause_timer <= 0.0:
		transition_requested.emit(self, &"WanderState")
