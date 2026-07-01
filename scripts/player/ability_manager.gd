class_name AbilityManager
extends Node

@export var abilities: Array[AbilityData] = []

var _cooldown_timers: Array[float] = []
var _damage_multiplier: float = 1.0
var _buff_timer: float = 0.0
var _sprite: AnimatedSprite2D = null
var _player_stats: PlayerStats = null

func _ready() -> void:
	_cooldown_timers.resize(abilities.size())
	_cooldown_timers.fill(0.0)
	await owner.ready
	_sprite = owner.get_node("AnimatedSprite2D") as AnimatedSprite2D
	_player_stats = owner.get_node_or_null("PlayerStats") as PlayerStats

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
			EventBus.player_buff_expired.emit()

func is_ability_ready(index: int) -> bool:
	return index >= 0 and index < _cooldown_timers.size() and _cooldown_timers[index] <= 0.0

func start_cooldown(index: int) -> void:
	if index >= 0 and index < abilities.size():
		var cdr: float = 0.0
		if _player_stats and _player_stats.has_effect(&"cooldown_reduction"):
			cdr = clampf(_player_stats.get_effect_value(&"cooldown_reduction"), 0.0, GameConfig.config.ability_max_cooldown_reduction)
		var actual_cooldown: float = abilities[index].cooldown * (1.0 - cdr)
		_cooldown_timers[index] = actual_cooldown
		EventBus.ability_cooldown_started.emit(index, actual_cooldown)

func get_ability(index: int) -> AbilityData:
	if index >= 0 and index < abilities.size():
		return abilities[index]
	return null

func get_damage_multiplier() -> float:
	return _damage_multiplier

func apply_buff(multiplier: float, duration: float, buff_name: String = "") -> void:
	_damage_multiplier = multiplier
	_buff_timer = duration
	if _sprite:
		_sprite.self_modulate = GameConfig.config.ui_war_cry_buff_color
	EventBus.player_buff_applied.emit(buff_name, GameConfig.config.ui_war_cry_buff_color, duration)

func get_cooldown_remaining(index: int) -> float:
	if index >= 0 and index < _cooldown_timers.size():
		return _cooldown_timers[index]
	return 0.0
