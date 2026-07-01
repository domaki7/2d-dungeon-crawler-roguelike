extends AbilityState

var _roll_timer: float = 0.0
var _roll_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	var input_dir: Vector2 = get_input_direction()
	if input_dir == Vector2.ZERO:
		input_dir = player.get_mouse_direction()
	_roll_direction = input_dir.normalized()
	_roll_timer = _ability_data.dash_duration
	player.update_facing(_roll_direction)
	player.play_directional_animation("dodge_roll")
	AudioManager.play_sfx_varied(&"dodge", 0.7, 0.85)
	player.hurtbox.set_deferred("monitorable", false)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	player.hurtbox.set_deferred("monitorable", true)
	player.velocity = Vector2.ZERO
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	if _roll_timer > 0.0:
		player.velocity = _roll_direction * _ability_data.dash_speed
		_roll_timer -= delta
		if _roll_timer <= 0.0:
			player.velocity = Vector2.ZERO
	else:
		player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _on_animation_finished() -> void:
	_transition_to_idle()
