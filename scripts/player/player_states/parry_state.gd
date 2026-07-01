extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	var target: CharacterBody2D = player.parry_target
	if target and is_instance_valid(target):
		var dir: Vector2 = player.global_position.direction_to(target.global_position)
		player.update_facing_from_angle(dir)
		var sec: StatusEffectComponent = target.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
		if sec:
			var stun_data: StatusEffectData = StatusEffectData.new()
			stun_data.type = StatusEffectData.Type.STUN
			stun_data.duration = GameConfig.config.player_parry_stun_duration
			stun_data.speed_multiplier = 1.0
			stun_data.tint_color = GameConfig.config.combat_stunned_color
			sec.apply_effect(stun_data)
		var sm: StateMachine = target.get_node_or_null("StateMachine") as StateMachine
		if sm:
			sm.transition_to(&"StunnedState")
		VFXHelper.spawn_hit_sparks(target.global_position)
	player.parry_target = null
	player.riposte_timer = GameConfig.config.player_parry_riposte_duration
	player.play_directional_animation("attack")
	AudioManager.play_sfx_varied(&"hit")
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
