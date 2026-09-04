extends Node

var _hit_sparks_scene: PackedScene = preload("res://scenes/effects/hit_sparks.tscn")
var _death_poof_scene: PackedScene = preload("res://scenes/effects/death_poof.tscn")
var _crit_flash_scene: PackedScene = preload("res://scenes/effects/crit_flash.tscn")
var _melee_swing_scene: PackedScene = preload("res://scenes/effects/melee_swing.tscn")
var _alert_indicator_scene: PackedScene = preload("res://scenes/effects/alert_indicator.tscn")
var _footstep_dust_scene: PackedScene = preload("res://scenes/effects/footstep_dust.tscn")
var _dust_motes_scene: PackedScene = preload("res://scenes/effects/dust_motes.tscn")
var _heal_burst_scene: PackedScene = preload("res://scenes/effects/heal_burst.tscn")

var _flash_tweens: Dictionary = {}
var _unique_materials: Dictionary = {}
## Live decals in spawn order, so the oldest can be retired when the cap is hit.
var _decals: Array[DeathDecal] = []

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

func spawn_heal_burst(global_pos: Vector2) -> void:
	spawn_particles_at(_heal_burst_scene, global_pos)

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

func spawn_footstep_dust(global_pos: Vector2) -> void:
	spawn_particles_at(_footstep_dust_scene, global_pos)

## Continuous drifting motes sized to a room. Parented to the room itself so it
## dies with the room rather than leaking into the next one.
func spawn_room_motes(room: Node2D, room_size: Vector2) -> void:
	var motes: GPUParticles2D = _dust_motes_scene.instantiate() as GPUParticles2D
	if motes == null:
		return
	motes.amount = maxi(1, GameConfig.config.vfx_dust_mote_count)
	motes.lifetime = GameConfig.config.vfx_dust_mote_lifetime
	motes.preprocess = motes.lifetime
	motes.modulate = GameConfig.config.vfx_dust_mote_color
	motes.position = room_size * 0.5
	var material: ParticleProcessMaterial = motes.process_material as ParticleProcessMaterial
	if material:
		# Duplicated so resizing one room's emission box can't affect another's.
		material = material.duplicate() as ParticleProcessMaterial
		material.emission_box_extents = Vector3(room_size.x * 0.5, room_size.y * 0.5, 1.0)
		motes.process_material = material
	room.add_child(motes)

## Leaves a splatter where something died. Capped so a long fight in one room
## cannot pile up unbounded nodes.
func spawn_death_decal(global_pos: Vector2, color: Color) -> void:
	var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
	if game_world == null:
		return
	_decals = _decals.filter(func(d: DeathDecal) -> bool: return is_instance_valid(d))
	var max_count: int = maxi(1, GameConfig.config.vfx_decal_max_count)
	while _decals.size() >= max_count:
		var oldest: DeathDecal = _decals.pop_front()
		if is_instance_valid(oldest):
			oldest.dismiss()

	var decal: DeathDecal = DeathDecal.new()
	game_world.add_child(decal)
	decal.global_position = global_pos
	decal.setup(color, hash(global_pos))
	_decals.append(decal)

func spawn_melee_swing(global_pos: Vector2, angle: float, swing_scale: float = 1.0) -> void:
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
	swing.scale = Vector2(swing_scale, swing_scale)
	swing.animation_finished.connect(swing.queue_free)
