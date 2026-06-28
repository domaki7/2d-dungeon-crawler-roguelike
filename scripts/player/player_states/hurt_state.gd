extends PlayerState

var stun_duration: float:
	get: return GameConfig.config.player_hurt_stun_duration

var _stun_timer: float = 0.0

func enter() -> void:
	_stun_timer = stun_duration
	var material: ShaderMaterial = player.animated_sprite.material as ShaderMaterial
	if material:
		material.set_shader_parameter("flash_intensity", 1.0)
		var tween: Tween = player.create_tween()
		tween.tween_property(material, "shader_parameter/flash_intensity", 0.0, 0.15)

func exit() -> void:
	var material: ShaderMaterial = player.animated_sprite.material as ShaderMaterial
	if material:
		material.set_shader_parameter("flash_intensity", 0.0)

func physics_process_state(delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()
	_stun_timer -= delta
	if _stun_timer <= 0.0:
		if player.health_component.current_hp <= 0:
			transition_requested.emit(self, &"DeadState")
		else:
			transition_requested.emit(self, &"IdleState")
