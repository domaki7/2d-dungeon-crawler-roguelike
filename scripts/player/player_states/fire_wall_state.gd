extends AbilityState

var _fire_wall_scene: PackedScene = preload("res://scenes/effects/fire_wall_zone.tscn")

func enter() -> void:
	super.enter()
	player.mana_component.use_mana(_ability_data.mana_cost)
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.play_directional_animation("cast")
	_create_fire_wall()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _create_fire_wall() -> void:
	var target_pos: Vector2 = player.get_global_mouse_position()
	var direction: Vector2 = player.get_mouse_direction()
	var dmg: int = player.get_ability_damage(_ability_data.damage)

	var burn_effect: StatusEffectData = StatusEffectData.new()
	burn_effect.type = StatusEffectData.Type.BURN
	burn_effect.duration = _ability_data.burn_duration
	burn_effect.tick_interval = GameConfig.config.status_burn_tick_interval
	burn_effect.damage_per_tick = GameConfig.config.status_burn_damage_per_tick
	burn_effect.tint_color = GameConfig.config.status_burn_tint_color
	burn_effect.particle_scene = preload("res://scenes/effects/burn_particles.tscn")

	var wall: Node2D = _fire_wall_scene.instantiate() as Node2D
	wall.global_position = target_pos
	wall.rotation = direction.angle()
	player.get_parent().add_child(wall)
	wall.setup(dmg, _ability_data.knockback_force, _ability_data.wall_length, _ability_data.wall_width, _ability_data.wall_duration, _ability_data.wall_tick_interval, burn_effect)
	AudioManager.play_sfx_varied(&"fire_wall")

func _on_animation_finished() -> void:
	_transition_to_idle()
