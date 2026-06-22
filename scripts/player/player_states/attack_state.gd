extends PlayerState

@export var hitbox_offset: float = 12.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_directional_animation("attack")
	_position_hitbox()
	player.hitbox.activate()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	player.hitbox.deactivate()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _position_hitbox() -> void:
	var offset: Vector2 = Vector2.ZERO
	match player.facing_direction:
		player.FacingDirection.DOWN:
			offset = Vector2(0, hitbox_offset)
		player.FacingDirection.UP:
			offset = Vector2(0, -hitbox_offset)
		player.FacingDirection.LEFT:
			offset = Vector2(-hitbox_offset, 0)
		player.FacingDirection.RIGHT:
			offset = Vector2(hitbox_offset, 0)
	player.hitbox.position = offset

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
