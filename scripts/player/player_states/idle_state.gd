extends PlayerState

func enter() -> void:
	player.play_directional_animation("idle")

func physics_process_state(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * delta)
	player.move_and_slide()

	var direction: Vector2 = get_input_direction()
	if direction != Vector2.ZERO:
		transition_requested.emit(self, &"RunState")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
