extends EnemyState

var default_stun_duration: float:
	get: return GameConfig.config.boss_stunned_duration

var _stun_timer: float = 0.0

func enter() -> void:
	_stun_timer = enemy.get_meta(&"stun_duration", default_stun_duration) as float
	if enemy.has_meta(&"stun_duration"):
		enemy.remove_meta(&"stun_duration")
	enemy.velocity = Vector2.ZERO
	enemy.animated_sprite.modulate = GameConfig.config.combat_stunned_color
	enemy.animated_sprite.pause()

func exit() -> void:
	enemy.animated_sprite.modulate = Color.WHITE
	enemy.animated_sprite.play()

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	_stun_timer -= delta
	if _stun_timer <= 0.0:
		if enemy.health_component.current_hp <= 0:
			transition_requested.emit(self, &"DeadState")
		else:
			transition_requested.emit(self, &"ChaseState")
