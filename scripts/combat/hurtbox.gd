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
	var final_damage: int = CombatManager.calculate_damage(hitbox.damage, defense, hitbox.crit_chance)

	if hitbox.stun_duration > 0.0:
		var parent: Node2D = get_parent() as Node2D
		if parent:
			parent.set_meta(&"stun_duration", hitbox.stun_duration)

	if _health_component:
		_health_component.take_damage(final_damage)

	if _knockback_component:
		var direction: Vector2 = (get_parent().global_position - hitbox.global_position).normalized()
		_knockback_component.apply_knockback(direction, hitbox.knockback_force)

	CombatManager.spawn_damage_number(final_damage, get_parent().global_position + Vector2(0, -16))
	CombatManager.apply_hit_pause(0.06)
	CombatManager.apply_screen_shake(2.0, 0.15)

	hit_received.emit(hitbox)
	AudioManager.play_sfx(&"hit")
