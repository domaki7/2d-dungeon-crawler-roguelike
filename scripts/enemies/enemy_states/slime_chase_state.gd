extends EnemyState

var attack_range: float:
	get: return GameConfig.config.slime_attack_range

func enter() -> void:
	enemy.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	if not enemy.is_player_detected and not enemy.is_aggroed:
		transition_requested.emit(self, &"IdleState")
		return

	var direction: Vector2 = get_direction_to_player()
	if direction != Vector2.ZERO:
		if enemy.update_facing(direction):
			enemy.play_directional_animation("walk")
		enemy.velocity = enemy.velocity.move_toward(direction * enemy.speed, enemy.acceleration * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if get_distance_to_player() <= attack_range:
		transition_requested.emit(self, &"AttackState")
