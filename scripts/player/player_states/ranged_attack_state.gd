extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.play_directional_animation("shoot")
	player.fire_arrow(direction)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
