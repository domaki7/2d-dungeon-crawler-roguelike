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
	if _player_stats.has_effect(&"defense_adds_damage"):
		bonus += _player_stats.get_effective_defense()
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
	if _player_stats.has_effect(&"explosion_on_kill"):
		var pos: Vector2 = _enemy_data.get("position", _owner_node.global_position) as Vector2
		_trigger_explosion_on_kill(pos)

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
	var target_sec: StatusEffectComponent = hurtbox.get_parent().get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	if _player_stats.has_effect(&"burn_on_hit") and target_sec:
		var burn: StatusEffectData = StatusEffectData.new()
		burn.type = StatusEffectData.Type.BURN
		burn.duration = GameConfig.config.status_burn_duration
		burn.tick_interval = GameConfig.config.status_burn_tick_interval
		burn.damage_per_tick = GameConfig.config.status_burn_damage_per_tick
		burn.tint_color = GameConfig.config.status_burn_tint_color
		target_sec.apply_effect(burn)
	if _player_stats.has_effect(&"freeze_on_hit") and target_sec:
		var freeze: StatusEffectData = StatusEffectData.new()
		freeze.type = StatusEffectData.Type.FREEZE
		freeze.duration = GameConfig.config.proc_freeze_duration
		freeze.speed_multiplier = GameConfig.config.status_freeze_speed_multiplier
		freeze.tint_color = GameConfig.config.status_freeze_tint_color
		target_sec.apply_effect(freeze)
	if _player_stats.has_effect(&"poison_on_hit") and target_sec:
		var poison: StatusEffectData = StatusEffectData.new()
		poison.type = StatusEffectData.Type.POISON
		poison.duration = GameConfig.config.proc_poison_duration
		poison.tick_interval = GameConfig.config.proc_poison_tick_interval
		poison.damage_per_tick = int(_player_stats.get_effect_value(&"poison_on_hit"))
		poison.tint_color = GameConfig.config.status_poison_tint_color
		target_sec.apply_effect(poison)
	if _player_stats.has_effect(&"lifesteal_on_hit"):
		var heal_amount: int = int(_player_stats.get_effect_value(&"lifesteal_on_hit"))
		_health_component.heal(heal_amount)
	if _player_stats.has_effect(&"lifesteal_percent"):
		var pct: float = _player_stats.get_effect_value(&"lifesteal_percent")
		var heal_amount: int = maxi(1, int(float(_hitbox.damage) * pct))
		_health_component.heal(heal_amount)
	if _player_stats.has_effect(&"chain_lightning_on_crit"):
		_try_chain_lightning(hurtbox)

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	if not _initialized:
		return
	_refresh_damage()

func _refresh_damage() -> void:
	if _hitbox:
		_hitbox.damage = _player_stats.get_effective_damage() + get_bonus_damage()

func _trigger_explosion_on_kill(pos: Vector2) -> void:
	var radius: float = GameConfig.config.legendary_explosion_radius
	var dmg: int = GameConfig.config.legendary_explosion_damage
	VFXHelper.spawn_death_poof(pos)
	CombatManager.apply_screen_shake(3.0, 0.2)
	var enemies: Array[Node] = _owner_node.get_tree().get_nodes_in_group(&"enemies")
	for enemy: Node in enemies:
		var enemy_node: Node2D = enemy as Node2D
		if enemy_node == null or not is_instance_valid(enemy_node):
			continue
		if enemy_node.global_position.distance_to(pos) <= radius:
			var hc: HealthComponent = enemy_node.get_node_or_null("HealthComponent") as HealthComponent
			if hc:
				hc.take_damage(dmg)

func _try_chain_lightning(hurtbox: Hurtbox) -> void:
	if _hitbox == null:
		return
	var is_crit: bool = _hitbox.crit_chance > 0.0 and randf() < _hitbox.crit_chance
	if not is_crit:
		return
	var bounces: int = GameConfig.config.legendary_chain_lightning_bounces
	var bounce_range: float = GameConfig.config.legendary_chain_lightning_range
	var bounce_damage: int = GameConfig.config.legendary_chain_lightning_damage
	var hit_targets: Array[Node] = [hurtbox.get_parent()]
	var current_pos: Vector2 = hurtbox.get_parent().global_position
	var enemies: Array[Node] = _owner_node.get_tree().get_nodes_in_group(&"enemies")
	for _i: int in range(bounces):
		var closest: Node2D = null
		var closest_dist: float = bounce_range
		for enemy: Node in enemies:
			var enemy_node: Node2D = enemy as Node2D
			if enemy_node == null or not is_instance_valid(enemy_node):
				continue
			if enemy_node in hit_targets:
				continue
			var dist: float = enemy_node.global_position.distance_to(current_pos)
			if dist < closest_dist:
				closest = enemy_node
				closest_dist = dist
		if closest == null:
			break
		hit_targets.append(closest)
		var hc: HealthComponent = closest.get_node_or_null("HealthComponent") as HealthComponent
		if hc:
			hc.take_damage(bounce_damage)
		VFXHelper.spawn_hit_sparks(closest.global_position)
		CombatManager.spawn_damage_number(bounce_damage, closest.global_position + Vector2(0, -16), Color(0.6, 0.8, 1.0))
		current_pos = closest.global_position
