extends PlayerState

func enter() -> void:
	player.play_directional_animation("walk")

func physics_process_state(delta: float) -> void:
	var direction: Vector2 = get_input_direction()

	if direction == Vector2.ZERO:
		transition_requested.emit(self, &"IdleState")
		return

	if player.update_facing(direction):
		player.play_directional_animation("walk")

	player.velocity = player.velocity.move_toward(direction * player.speed, player.acceleration * delta)
	player.move_and_slide()
