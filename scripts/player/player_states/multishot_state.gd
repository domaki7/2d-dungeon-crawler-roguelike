extends AbilityState

func enter() -> void:
	super.enter()
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.play_directional_animation("shoot")
	_fire_spread(direction)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _fire_spread(center_direction: Vector2) -> void:
	var base_angle: float = center_direction.angle()
	var count: int = _ability_data.arrow_count
	var spread_rad: float = deg_to_rad(_ability_data.spread_angle_degrees)
	var step: float = spread_rad / float(count - 1) if count > 1 else 0.0
	var start_angle: float = base_angle - spread_rad / 2.0
	var dmg: int = player.get_ability_damage(_ability_data.damage)
	for i: int in range(count):
		var angle: float = start_angle + step * float(i)
		var dir: Vector2 = Vector2.from_angle(angle)
		var arrow: Area2D = player.arrow_scene.instantiate() as Area2D
		arrow.global_position = player.global_position
		arrow.setup(dir, dmg)
		player.get_parent().add_child(arrow)
	AudioManager.play_sfx_varied(&"arrow_fire")

func _on_animation_finished() -> void:
	_transition_to_idle()
