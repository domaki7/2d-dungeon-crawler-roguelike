extends EnemyState

@export var default_stun_duration: float = 1.0

var _stun_timer: float = 0.0

func enter() -> void:
	_stun_timer = enemy.get_meta(&"stun_duration", default_stun_duration) as float
	if enemy.has_meta(&"stun_duration"):
		enemy.remove_meta(&"stun_duration")
	enemy.velocity = Vector2.ZERO
	enemy.animated_sprite.modulate = Color(1.0, 1.0, 0.5, 1.0)
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
		elif enemy.is_player_detected:
			transition_requested.emit(self, &"ChaseState")
		else:
			transition_requested.emit(self, &"IdleState")
