extends Node

var _hit_sparks_scene: PackedScene = preload("res://scenes/effects/hit_sparks.tscn")
var _death_poof_scene: PackedScene = preload("res://scenes/effects/death_poof.tscn")
var _crit_flash_scene: PackedScene = preload("res://scenes/effects/crit_flash.tscn")
var _melee_swing_scene: PackedScene = preload("res://scenes/effects/melee_swing.tscn")
var _alert_indicator_scene: PackedScene = preload("res://scenes/effects/alert_indicator.tscn")

var _flash_tweens: Dictionary = {}
var _unique_materials: Dictionary = {}

func apply_hit_flash(sprite: CanvasItem, duration: float = -1.0) -> void:
	var material: ShaderMaterial = sprite.material as ShaderMaterial
	if material == null:
		return
	if not _unique_materials.has(sprite):
		material = material.duplicate() as ShaderMaterial
		sprite.material = material
		_unique_materials[sprite] = true
	if duration < 0.0:
		duration = GameConfig.config.vfx_hit_flash_duration

	if _flash_tweens.has(sprite) and is_instance_valid(_flash_tweens[sprite]):
		(_flash_tweens[sprite] as Tween).kill()

	material.set_shader_parameter("flash_intensity", 1.0)
	var tween: Tween = sprite.create_tween()
	tween.tween_property(material, "shader_parameter/flash_intensity", 0.0, duration)
	_flash_tweens[sprite] = tween

func spawn_particles_at(scene: PackedScene, global_pos: Vector2) -> void:
	var particles: GPUParticles2D = scene.instantiate() as GPUParticles2D
	if particles == null:
		return
	var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
	if game_world == null:
		particles.queue_free()
		return
	game_world.add_child(particles)
	particles.global_position = global_pos
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

func spawn_hit_sparks(global_pos: Vector2) -> void:
	spawn_particles_at(_hit_sparks_scene, global_pos)

func spawn_death_poof(global_pos: Vector2) -> void:
	spawn_particles_at(_death_poof_scene, global_pos)

func spawn_crit_flash(global_pos: Vector2) -> void:
	spawn_particles_at(_crit_flash_scene, global_pos)

func spawn_alert_indicator(global_pos: Vector2) -> void:
	var icon: Sprite2D = _alert_indicator_scene.instantiate() as Sprite2D
	if icon == null:
		return
	var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
	if game_world == null:
		icon.queue_free()
		return
	game_world.add_child(icon)
	icon.global_position = global_pos
	var rise: float = GameConfig.config.enemy_alert_icon_rise
	var duration: float = GameConfig.config.enemy_alert_icon_duration
	var tween: Tween = icon.create_tween()
	tween.tween_property(icon, "position:y", icon.position.y - rise, duration)
	tween.parallel().tween_property(icon, "modulate:a", 0.0, duration)
	tween.tween_callback(icon.queue_free)

func spawn_melee_swing(global_pos: Vector2, angle: float) -> void:
	var swing: AnimatedSprite2D = _melee_swing_scene.instantiate() as AnimatedSprite2D
	if swing == null:
		return
	var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
	if game_world == null:
		swing.queue_free()
		return
	game_world.add_child(swing)
	swing.global_position = global_pos
	swing.rotation = angle
	swing.animation_finished.connect(swing.queue_free)
