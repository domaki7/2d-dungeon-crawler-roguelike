class_name StatusEffectComponent
extends Node

signal effect_applied(type: int)
signal effect_removed(type: int)
signal effect_ticked(type: int, damage: int)

var _active_effects: Dictionary = {}
var _active_particles: Dictionary = {}
var _sprite: CanvasItem = null
var _health_component: HealthComponent = null
var _is_player: bool = false

var _particle_scenes: Dictionary = {
	StatusEffectData.Type.BURN: preload("res://scenes/effects/burn_particles.tscn"),
	StatusEffectData.Type.POISON: preload("res://scenes/effects/poison_particles.tscn"),
	StatusEffectData.Type.FREEZE: preload("res://scenes/effects/freeze_particles.tscn"),
	StatusEffectData.Type.SLOW: preload("res://scenes/effects/slow_particles.tscn"),
}

func _ready() -> void:
	var parent: Node = get_parent()
	_sprite = parent.get_node_or_null("AnimatedSprite2D") as CanvasItem
	_health_component = parent.get_node_or_null("HealthComponent") as HealthComponent
	_is_player = parent.is_in_group(&"player")

func apply_effect(effect_data: StatusEffectData) -> void:
	if effect_data == null:
		return
	var type: int = effect_data.type
	if _active_effects.has(type):
		_active_effects[type]["timer"] = effect_data.duration
		return
	var entry: Dictionary = {
		"data": effect_data,
		"timer": effect_data.duration,
		"tick_timer": effect_data.tick_interval,
		"duration": effect_data.duration,
	}
	_active_effects[type] = entry
	var particle_scene: PackedScene = effect_data.particle_scene
	if particle_scene == null and _particle_scenes.has(type):
		particle_scene = _particle_scenes[type] as PackedScene
	if particle_scene:
		_spawn_particles(type, particle_scene)
	_update_tint()
	effect_applied.emit(type)
	if _is_player:
		EventBus.status_effect_applied.emit(type, effect_data.duration)

func remove_effect(type: int) -> void:
	if not _active_effects.has(type):
		return
	_active_effects.erase(type)
	_remove_particles(type)
	_update_tint()
	effect_removed.emit(type)
	if _is_player:
		EventBus.status_effect_removed.emit(type)

func has_effect(type: int) -> bool:
	return _active_effects.has(type)

func is_stunned() -> bool:
	return _active_effects.has(StatusEffectData.Type.STUN)

func get_speed_multiplier() -> float:
	var multiplier: float = 1.0
	for entry: Dictionary in _active_effects.values():
		var data: StatusEffectData = entry["data"] as StatusEffectData
		multiplier *= data.speed_multiplier
	return multiplier

func get_effect_remaining(type: int) -> float:
	if not _active_effects.has(type):
		return 0.0
	return _active_effects[type]["timer"] as float

func get_effect_duration(type: int) -> float:
	if not _active_effects.has(type):
		return 0.0
	return _active_effects[type]["duration"] as float

func clear_all() -> void:
	var types: Array = _active_effects.keys().duplicate()
	for type: int in types:
		remove_effect(type)

func _process(delta: float) -> void:
	if _active_effects.is_empty():
		return
	var expired: Array[int] = []
	for type: int in _active_effects:
		var entry: Dictionary = _active_effects[type]
		entry["timer"] = (entry["timer"] as float) - delta
		if (entry["timer"] as float) <= 0.0:
			expired.append(type)
			continue
		var data: StatusEffectData = entry["data"] as StatusEffectData
		if data.tick_interval > 0.0 and data.damage_per_tick > 0:
			entry["tick_timer"] = (entry["tick_timer"] as float) - delta
			if (entry["tick_timer"] as float) <= 0.0:
				entry["tick_timer"] = data.tick_interval
				_apply_tick_damage(type, data.damage_per_tick)
	for type: int in expired:
		remove_effect(type)

func _apply_tick_damage(type: int, damage: int) -> void:
	if _health_component == null:
		return
	_health_component.take_damage(damage)
	effect_ticked.emit(type, damage)
	var color: Color = Color(1.0, 0.5, 0.0) if type == StatusEffectData.Type.BURN else Color(0.4, 0.9, 0.2)
	CombatManager.spawn_damage_number(damage, get_parent().global_position + Vector2(8, -16), color)

func _spawn_particles(type: int, scene: PackedScene) -> void:
	var particles: GPUParticles2D = scene.instantiate() as GPUParticles2D
	if particles == null:
		return
	get_parent().add_child(particles)
	particles.position = Vector2.ZERO
	particles.emitting = true
	_active_particles[type] = particles

func _remove_particles(type: int) -> void:
	if not _active_particles.has(type):
		return
	var particles: GPUParticles2D = _active_particles[type] as GPUParticles2D
	if is_instance_valid(particles):
		particles.emitting = false
		particles.finished.connect(particles.queue_free)
	_active_particles.erase(type)

const _TINT_PRIORITY: Array[int] = [
	StatusEffectData.Type.STUN,
	StatusEffectData.Type.FREEZE,
	StatusEffectData.Type.BURN,
	StatusEffectData.Type.POISON,
	StatusEffectData.Type.SLOW,
]

func _update_tint() -> void:
	if _sprite == null:
		return
	if _active_effects.is_empty():
		_sprite.modulate = Color.WHITE
		return
	for type: int in _TINT_PRIORITY:
		if _active_effects.has(type):
			var data: StatusEffectData = _active_effects[type]["data"] as StatusEffectData
			_sprite.modulate = data.tint_color
			return
	_sprite.modulate = Color.WHITE
