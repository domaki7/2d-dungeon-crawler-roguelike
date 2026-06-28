extends EnemyState

var _stun_timer: float = 0.0

func enter() -> void:
	var sec: StatusEffectComponent = enemy.status_effect_component
	if sec and sec.has_effect(StatusEffectData.Type.STUN):
		_stun_timer = sec.get_effect_remaining(StatusEffectData.Type.STUN)
	else:
		_stun_timer = GameConfig.config.combat_default_stun_duration
	enemy.velocity = Vector2.ZERO
	enemy.animated_sprite.pause()

func exit() -> void:
	enemy.animated_sprite.play()

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	_stun_timer -= delta
	if _stun_timer <= 0.0:
		var sec: StatusEffectComponent = enemy.status_effect_component
		if sec:
			sec.remove_effect(StatusEffectData.Type.STUN)
		if enemy.health_component.current_hp <= 0:
			transition_requested.emit(self, &"DeadState")
		elif enemy.is_player_detected:
			transition_requested.emit(self, &"ChaseState")
		else:
			transition_requested.emit(self, &"IdleState")
