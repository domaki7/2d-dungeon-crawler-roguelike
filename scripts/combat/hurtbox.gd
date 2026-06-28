class_name Hurtbox
extends Area2D

signal hit_received(hitbox: Hitbox)

var _health_component: HealthComponent = null
var _knockback_component: KnockbackComponent = null

func _ready() -> void:
	monitoring = false
	monitorable = true
	_health_component = get_parent().get_node_or_null("HealthComponent") as HealthComponent
	_knockback_component = get_parent().get_node_or_null("KnockbackComponent") as KnockbackComponent

func receive_hit(hitbox: Hitbox) -> void:
	if _health_component and _health_component.is_invincible():
		return

	var defense: int = 0
	var owner_node: Node2D = get_parent() as Node2D
	if owner_node and owner_node.has_method("get_defense"):
		defense = owner_node.get_defense()
	var result: Dictionary = CombatManager.calculate_damage(hitbox.damage, defense, hitbox.crit_chance)
	var final_damage: int = result["damage"] as int
	var is_crit: bool = result["is_crit"] as bool

	if hitbox.stun_duration > 0.0:
		var parent: Node2D = get_parent() as Node2D
		if parent:
			parent.set_meta(&"stun_duration", hitbox.stun_duration)

	if _health_component:
		_health_component.take_damage(final_damage)

	if _knockback_component:
		var direction: Vector2 = (get_parent().global_position - hitbox.global_position).normalized()
		_knockback_component.apply_knockback(direction, hitbox.knockback_force)

	var dmg_color: Color = Color.GOLD if is_crit else Color.WHITE
	CombatManager.spawn_damage_number(final_damage, get_parent().global_position + Vector2(0, -16), dmg_color)

	var pause_duration: float = hitbox.hit_pause_duration if hitbox.hit_pause_duration >= 0.0 else GameConfig.config.combat_hit_pause_duration
	var shake_intensity: float = hitbox.screen_shake_intensity if hitbox.screen_shake_intensity >= 0.0 else GameConfig.config.combat_screen_shake_intensity
	var shake_duration: float = hitbox.screen_shake_duration if hitbox.screen_shake_duration >= 0.0 else GameConfig.config.combat_screen_shake_duration
	CombatManager.apply_hit_pause(pause_duration)
	CombatManager.apply_screen_shake(shake_intensity, shake_duration)

	var sprite: CanvasItem = get_parent().get_node_or_null("AnimatedSprite2D")
	if sprite:
		VFXHelper.apply_hit_flash(sprite)

	VFXHelper.spawn_hit_sparks(get_parent().global_position)
	if is_crit:
		VFXHelper.spawn_crit_flash(get_parent().global_position)

	hit_received.emit(hitbox)
	AudioManager.play_sfx_varied(&"hit")

	if get_parent().is_in_group(&"enemies"):
		EventBus.enemy_aggroed.emit()
