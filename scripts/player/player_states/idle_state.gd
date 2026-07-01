extends PlayerState

func enter() -> void:
	player.play_directional_animation("idle")

func physics_process_state(delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * delta)
	player.move_and_slide()

	var direction: Vector2 = get_input_direction()
	if direction != Vector2.ZERO:
		transition_requested.emit(self, &"RunState")
		return

	var mouse_dir: Vector2 = player.get_mouse_direction()
	if player.update_facing_from_angle(mouse_dir):
		player.play_directional_animation("idle")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		var parryable: CharacterBody2D = _find_parryable_enemy()
		if parryable:
			player.parry_target = parryable
			transition_requested.emit(self, &"ParryState")
		else:
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

func _find_parryable_enemy() -> CharacterBody2D:
	var range_sq: float = GameConfig.config.player_parry_range * GameConfig.config.player_parry_range
	for enemy: Node in get_tree().get_nodes_in_group(&"enemies"):
		var enemy_body: CharacterBody2D = enemy as CharacterBody2D
		if enemy_body == null:
			continue
		if player.global_position.distance_squared_to(enemy_body.global_position) > range_sq:
			continue
		var sm_node: Node = enemy_body.get_node_or_null("StateMachine")
		if sm_node == null:
			continue
		var sm: StateMachine = sm_node as StateMachine
		if sm == null or sm.current_state == null:
			continue
		if sm.current_state.has_method(&"is_in_parry_window") and sm.current_state.is_in_parry_window():
			return enemy_body
	return null
