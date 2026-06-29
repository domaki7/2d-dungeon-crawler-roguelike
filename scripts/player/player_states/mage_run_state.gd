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
		transition_requested.emit(self, &"CastState")
	elif event.is_action_pressed(&"dodge"):
		_try_ability(3, &"BlinkState")
	elif event.is_action_pressed(&"ability_1"):
		_try_ability(0, &"IceShardState")
	elif event.is_action_pressed(&"ability_2"):
		_try_ability(1, &"ChainLightningState")
	elif event.is_action_pressed(&"ability_3"):
		_try_ability(2, &"FireWallState")

func _try_ability(index: int, state_name: StringName) -> void:
	if not player.ability_manager.is_ability_ready(index):
		return
	var ability: AbilityData = player.ability_manager.get_ability(index)
	if ability and ability.mana_cost > 0 and not player.mana_component.has_mana(ability.mana_cost):
		return
	transition_requested.emit(self, state_name)
