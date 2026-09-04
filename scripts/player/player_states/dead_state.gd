extends PlayerState

var flash_duration: float:
	get: return GameConfig.config.player_dead_flash_duration
var fade_duration: float:
	get: return GameConfig.config.player_dead_fade_duration

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.set_collision_layer_value(2, false)
	player.hurtbox.set_deferred("monitorable", false)
	for child: Node in player.hurtbox.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)

	EventBus.player_died.emit()

	var material: ShaderMaterial = player.animated_sprite.material as ShaderMaterial
	if material:
		material.set_shader_parameter("flash_intensity", 1.0)

	var tween: Tween = player.create_tween()
	if material:
		tween.tween_property(material, "shader_parameter/flash_intensity", 0.0, flash_duration)
	tween.tween_property(player.animated_sprite, "modulate:a", 0.0, fade_duration)
	tween.parallel().tween_property(player, "scale", Vector2(0.5, 0.5), fade_duration)

func physics_process_state(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
