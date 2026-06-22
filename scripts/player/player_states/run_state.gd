extends PlayerState

func physics_process_state(delta: float) -> void:
	var direction: Vector2 = get_input_direction()

	if direction == Vector2.ZERO:
		transition_requested.emit(self, &"IdleState")
		return

	player.velocity = player.velocity.move_toward(direction * player.speed, player.acceleration * delta)
	player.move_and_slide()
