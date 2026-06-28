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
	elif event.is_action_pressed(&"dodge"):
		if player.ability_manager.is_ability_ready(3):
			transition_requested.emit(self, &"DodgeRollState")
	elif event.is_action_pressed(&"ability_1"):
		if player.ability_manager.is_ability_ready(0):
			transition_requested.emit(self, &"ShieldBashState")
	elif event.is_action_pressed(&"ability_2"):
		if player.ability_manager.is_ability_ready(1):
			transition_requested.emit(self, &"WhirlwindState")
	elif event.is_action_pressed(&"ability_3"):
		if player.ability_manager.is_ability_ready(2):
			transition_requested.emit(self, &"WarCryState")
