class_name ItemEffectHandler
extends Node

var _player_stats: PlayerStats
var _health_component: HealthComponent

func _ready() -> void:
	await owner.ready
	_player_stats = owner.get_node("PlayerStats") as PlayerStats
	_health_component = owner.get_node("HealthComponent") as HealthComponent
	EventBus.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(_enemy_data: Dictionary) -> void:
	if _player_stats.has_effect(&"heal_on_kill"):
		var heal_amount: int = int(_player_stats.get_effect_value(&"heal_on_kill"))
		_health_component.heal(heal_amount)
