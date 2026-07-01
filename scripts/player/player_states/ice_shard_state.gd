extends AbilityState

func enter() -> void:
	super.enter()
	player.mana_component.use_mana(_ability_data.mana_cost)
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.play_directional_animation("cast")
	var dmg: int = player.get_ability_damage(_ability_data.damage)
	var slow_effect: StatusEffectData = StatusEffectData.new()
	slow_effect.type = StatusEffectData.Type.SLOW
	slow_effect.duration = _ability_data.slow_duration
	slow_effect.speed_multiplier = GameConfig.config.status_slow_speed_multiplier
	slow_effect.tint_color = GameConfig.config.status_slow_tint_color
	slow_effect.particle_scene = preload("res://scenes/effects/slow_particles.tscn")
	player.fire_ice_shard(direction, dmg, slow_effect)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	super.exit()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _on_animation_finished() -> void:
	_transition_to_idle()
