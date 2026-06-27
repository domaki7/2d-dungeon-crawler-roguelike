extends EnemyState

@export var stun_duration: float = 0.2

var _stun_timer: float = 0.0

func enter() -> void:
	_stun_timer = stun_duration
	var material: ShaderMaterial = enemy.animated_sprite.material as ShaderMaterial
	if material:
		material.set_shader_parameter("flash_intensity", 1.0)
		var tween: Tween = enemy.create_tween()
		tween.tween_property(material, "shader_parameter/flash_intensity", 0.0, 0.15)

func exit() -> void:
	var material: ShaderMaterial = enemy.animated_sprite.material as ShaderMaterial
	if material:
		material.set_shader_parameter("flash_intensity", 0.0)

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	_stun_timer -= delta
	if _stun_timer <= 0.0:
		if enemy.health_component.current_hp <= 0:
			transition_requested.emit(self, &"DeadState")
		else:
			transition_requested.emit(self, &"ChaseState")
