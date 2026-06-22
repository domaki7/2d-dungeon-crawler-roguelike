extends PlayerState

func physics_process_state(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * delta)
	player.move_and_slide()

	var direction: Vector2 = get_input_direction()
	if direction != Vector2.ZERO:
		transition_requested.emit(self, &"RunState")
