class_name ItemEffectHandler
extends Node

var _player_stats: PlayerStats
var _health_component: HealthComponent
var _hitbox: Hitbox
var _hurtbox: Hurtbox
var _owner_node: CharacterBody2D
var _revive_used: bool = false
var _initialized: bool = false

func _ready() -> void:
	await owner.ready
	_owner_node = owner as CharacterBody2D
	_player_stats = owner.get_node("PlayerStats") as PlayerStats
	_health_component = owner.get_node("HealthComponent") as HealthComponent
	_hitbox = owner.get_node_or_null("Hitbox") as Hitbox
	_hurtbox = owner.get_node("Hurtbox") as Hurtbox
	_initialized = true
	EventBus.enemy_killed.connect(_on_enemy_killed)
	_hurtbox.hit_received.connect(_on_player_received_hit)
	if _hitbox:
		_hitbox.hit_landed.connect(_on_player_hit_landed)
	_health_component.health_changed.connect(_on_health_changed)

func reset_for_run() -> void:
	_revive_used = false

func has_revive() -> bool:
	if not _initialized or _revive_used:
		return false
	return _player_stats.has_effect(&"revive_once")

func consume_revive() -> int:
	_revive_used = true
	return int(_player_stats.get_effect_value(&"revive_once"))

func get_bonus_damage() -> int:
	if not _initialized:
		return 0
	var bonus: int = 0
	if _player_stats.has_effect(&"damage_below_half"):
		var hp_ratio: float = float(_health_component.current_hp) / float(_health_component.max_hp)
		if hp_ratio < 0.5:
			bonus += int(_player_stats.get_effect_value(&"damage_below_half"))
	return bonus

func _on_enemy_killed(_enemy_data: Dictionary) -> void:
	if not _initialized:
		return
	if _player_stats.has_effect(&"heal_on_kill"):
		var heal_amount: int = int(_player_stats.get_effect_value(&"heal_on_kill"))
		_health_component.heal(heal_amount)
	if _player_stats.has_effect(&"gold_on_kill"):
		var gold_amount: int = int(_player_stats.get_effect_value(&"gold_on_kill"))
		_owner_node.gold += gold_amount
		EventBus.gold_changed.emit(_owner_node.gold)

func _on_player_received_hit(hitbox: Hitbox) -> void:
	if not _initialized:
		return
	if _player_stats.has_effect(&"thorns"):
		var thorns_damage: int = int(_player_stats.get_effect_value(&"thorns"))
		var attacker_hc: HealthComponent = hitbox.get_parent().get_node_or_null("HealthComponent") as HealthComponent
		if attacker_hc:
			attacker_hc.take_damage(thorns_damage)

func _on_player_hit_landed(hurtbox: Hurtbox) -> void:
	if not _initialized:
		return
	if _player_stats.has_effect(&"burn_on_hit"):
		var target_sec: StatusEffectComponent = hurtbox.get_parent().get_node_or_null("StatusEffectComponent") as StatusEffectComponent
		if target_sec:
			var burn: StatusEffectData = StatusEffectData.new()
			burn.type = StatusEffectData.Type.BURN
			burn.duration = GameConfig.config.status_burn_duration
			burn.tick_interval = GameConfig.config.status_burn_tick_interval
			burn.damage_per_tick = GameConfig.config.status_burn_damage_per_tick
			burn.tint_color = GameConfig.config.status_burn_tint_color
			target_sec.apply_effect(burn)

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	if not _initialized:
		return
	_refresh_damage()

func _refresh_damage() -> void:
	if _hitbox:
		_hitbox.damage = _player_stats.get_effective_damage() + get_bonus_damage()
