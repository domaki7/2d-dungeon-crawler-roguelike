extends EnemyState

var hitbox_offset: float:
	get: return GameConfig.config.skeleton_hitbox_offset

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var direction: Vector2 = get_direction_to_player()
	enemy.update_facing(direction)
	enemy.play_directional_animation("attack")
	_position_hitbox()
	enemy.hitbox.activate()
	enemy.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	enemy.hitbox.deactivate()
	if enemy.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		enemy.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

func _position_hitbox() -> void:
	var offset: Vector2 = Vector2.ZERO
	match enemy.facing_direction:
		enemy.FacingDirection.DOWN:
			offset = Vector2(0, hitbox_offset)
		enemy.FacingDirection.UP:
			offset = Vector2(0, -hitbox_offset)
		enemy.FacingDirection.LEFT:
			offset = Vector2(-hitbox_offset, 0)
		enemy.FacingDirection.RIGHT:
			offset = Vector2(hitbox_offset, 0)
	enemy.hitbox.position = offset

func _on_animation_finished() -> void:
	if enemy.is_player_detected and get_distance_to_player() <= 24.0:
		transition_requested.emit(self, &"ChaseState")
	else:
		transition_requested.emit(self, &"IdleState")
