extends EnemyState

@export var preferred_range: float = 80.0
@export var attack_range: float = 90.0
@export var too_close_range: float = 40.0

func enter() -> void:
	enemy.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	if not enemy.is_player_detected and not enemy.is_aggroed:
		transition_requested.emit(self, &"IdleState")
		return

	var direction: Vector2 = get_direction_to_player()
	var distance: float = get_distance_to_player()

	if direction != Vector2.ZERO:
		if enemy.update_facing(direction):
			enemy.play_directional_animation("walk")

		if distance < too_close_range:
			var retreat_dir: Vector2 = -direction
			enemy.velocity = enemy.velocity.move_toward(retreat_dir * enemy.speed, enemy.acceleration * delta)
		elif distance > attack_range:
			enemy.velocity = enemy.velocity.move_toward(direction * enemy.speed, enemy.acceleration * delta)
		else:
			enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.friction * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if distance <= attack_range and distance >= too_close_range * 0.5:
		transition_requested.emit(self, &"AttackState")
