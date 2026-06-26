extends AbilityState

func enter() -> void:
	super.enter()
	player.animated_sprite.play(&"war_cry")
	player.ability_manager.apply_buff(_ability_data.damage_multiplier, _ability_data.buff_duration)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _on_animation_finished() -> void:
	_transition_to_idle()
