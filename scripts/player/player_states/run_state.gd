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

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		transition_requested.emit(self, &"AttackState")
