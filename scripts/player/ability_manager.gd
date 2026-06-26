class_name AbilityManager
extends Node

@export var abilities: Array[AbilityData] = []

var _cooldown_timers: Array[float] = []
var _damage_multiplier: float = 1.0
var _buff_timer: float = 0.0
var _sprite: AnimatedSprite2D = null

func _ready() -> void:
	_cooldown_timers.resize(abilities.size())
	_cooldown_timers.fill(0.0)
	await owner.ready
	_sprite = owner.get_node("AnimatedSprite2D") as AnimatedSprite2D

func _process(delta: float) -> void:
	for i: int in _cooldown_timers.size():
		if _cooldown_timers[i] > 0.0:
			_cooldown_timers[i] -= delta
			if _cooldown_timers[i] < 0.0:
				_cooldown_timers[i] = 0.0

	if _buff_timer > 0.0:
		_buff_timer -= delta
		if _buff_timer <= 0.0:
			_buff_timer = 0.0
			_damage_multiplier = 1.0
			if _sprite:
				_sprite.self_modulate = Color.WHITE

func is_ability_ready(index: int) -> bool:
	return index >= 0 and index < _cooldown_timers.size() and _cooldown_timers[index] <= 0.0

func start_cooldown(index: int) -> void:
	if index >= 0 and index < abilities.size():
		_cooldown_timers[index] = abilities[index].cooldown
		EventBus.ability_cooldown_started.emit(index, abilities[index].cooldown)

func get_ability(index: int) -> AbilityData:
	if index >= 0 and index < abilities.size():
		return abilities[index]
	return null

func get_damage_multiplier() -> float:
	return _damage_multiplier

func apply_buff(multiplier: float, duration: float) -> void:
	_damage_multiplier = multiplier
	_buff_timer = duration
	if _sprite:
		_sprite.self_modulate = Color(1.2, 1.1, 0.8, 1.0)

func get_cooldown_remaining(index: int) -> float:
	if index >= 0 and index < _cooldown_timers.size():
		return _cooldown_timers[index]
	return 0.0
