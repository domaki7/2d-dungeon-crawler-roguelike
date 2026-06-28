extends EnemyState

var stun_duration: float:
	get: return GameConfig.config.slime_stun_duration

var _stun_timer: float = 0.0

func enter() -> void:
	_stun_timer = stun_duration

func exit() -> void:
	pass

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	_stun_timer -= delta
	if _stun_timer <= 0.0:
		if enemy.health_component.current_hp <= 0:
			transition_requested.emit(self, &"DeadState")
		elif enemy.is_player_detected:
			transition_requested.emit(self, &"ChaseState")
		else:
			transition_requested.emit(self, &"IdleState")
