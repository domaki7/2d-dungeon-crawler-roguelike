extends EnemyState

var engage_delay: float:
	get: return GameConfig.config.boss_engage_delay

var _timer: float = 0.0

func enter() -> void:
	_timer = engage_delay
	enemy.play_directional_animation("idle")
	enemy.start_boss_fight()

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * delta)
	enemy.move_and_slide()

	_timer -= delta
	if _timer <= 0.0 and enemy.is_player_detected:
		transition_requested.emit(self, &"ChaseState")
