extends AbilityState

var _blink_poof_scene: PackedScene = preload("res://scenes/effects/blink_poof.tscn")

func enter() -> void:
	super.enter()
	player.mana_component.use_mana(_ability_data.mana_cost)
	var input_dir: Vector2 = get_input_direction()
	if input_dir == Vector2.ZERO:
		input_dir = player.get_mouse_direction()
	var blink_dir: Vector2 = input_dir.normalized()
	player.update_facing(blink_dir)
	player.play_directional_animation("blink")

	_spawn_poof(player.global_position)
	player.hurtbox.set_deferred("monitorable", false)
	player.global_position += blink_dir * _ability_data.blink_distance
	_spawn_poof(player.global_position)

	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	player.hurtbox.set_deferred("monitorable", true)
	player.velocity = Vector2.ZERO
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = Vector2.ZERO
	player.move_and_slide()

func _spawn_poof(pos: Vector2) -> void:
	var poof: GPUParticles2D = _blink_poof_scene.instantiate() as GPUParticles2D
	poof.global_position = pos
	player.get_parent().add_child(poof)
	poof.emitting = true
	var timer: SceneTreeTimer = player.get_tree().create_timer(1.0)
	timer.timeout.connect(poof.queue_free)

func _on_animation_finished() -> void:
	_transition_to_idle()
