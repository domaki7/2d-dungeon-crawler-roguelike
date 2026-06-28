extends EnemyState

func enter() -> void:
	enemy.play_directional_animation("idle")

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * delta)
	enemy.move_and_slide()

	if enemy.is_player_detected or enemy.is_aggroed:
		transition_requested.emit(self, &"ChaseState")
