class_name EliteModifier
extends RefCounted

static func apply(enemy: Node2D, spawn_type: SpawnPoint.SpawnType) -> void:
	if spawn_type == SpawnPoint.SpawnType.BOSS or spawn_type == SpawnPoint.SpawnType.GOLD or spawn_type == SpawnPoint.SpawnType.CHEST:
		return

	enemy.is_elite = true

	var hc: HealthComponent = enemy.get_node_or_null("HealthComponent") as HealthComponent
	if hc:
		hc.max_hp = maxi(1, int(float(hc.max_hp) * GameConfig.config.elite_hp_multiplier))
		hc.current_hp = hc.max_hp

	var hitbox: Hitbox = enemy.get_node_or_null("Hitbox") as Hitbox
	if hitbox:
		hitbox.damage = maxi(1, int(float(hitbox.damage) * GameConfig.config.elite_damage_multiplier))
		hitbox.applied_status_effect = _create_status_effect(spawn_type)

	enemy.difficulty_speed_multiplier *= GameConfig.config.elite_speed_multiplier

	var sprite: AnimatedSprite2D = enemy.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite:
		sprite.modulate = GameConfig.config.elite_tint_color
		sprite.scale *= GameConfig.config.elite_scale


static func _create_status_effect(spawn_type: SpawnPoint.SpawnType) -> StatusEffectData:
	var effect: StatusEffectData = StatusEffectData.new()

	match spawn_type:
		SpawnPoint.SpawnType.SKELETON:
			effect.type = StatusEffectData.Type.SLOW
			effect.duration = GameConfig.config.elite_skeleton_status_duration
			effect.speed_multiplier = GameConfig.config.status_slow_speed_multiplier
			effect.tint_color = GameConfig.config.status_slow_tint_color
		SpawnPoint.SpawnType.SLIME:
			effect.type = StatusEffectData.Type.POISON
			effect.duration = GameConfig.config.elite_slime_status_duration
			effect.tick_interval = GameConfig.config.status_poison_tick_interval
			effect.damage_per_tick = GameConfig.config.status_poison_damage_per_tick
			effect.tint_color = GameConfig.config.status_poison_tint_color
		SpawnPoint.SpawnType.BAT:
			effect.type = StatusEffectData.Type.BURN
			effect.duration = GameConfig.config.elite_bat_status_duration
			effect.tick_interval = GameConfig.config.status_burn_tick_interval
			effect.damage_per_tick = GameConfig.config.status_burn_damage_per_tick
			effect.tint_color = GameConfig.config.status_burn_tint_color
		_:
			effect.type = StatusEffectData.Type.FREEZE
			effect.duration = GameConfig.config.elite_archer_status_duration
			effect.speed_multiplier = GameConfig.config.status_freeze_speed_multiplier
			effect.tint_color = GameConfig.config.status_freeze_tint_color

	return effect
