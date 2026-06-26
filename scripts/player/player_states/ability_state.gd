class_name AbilityState
extends PlayerState

@export var ability_index: int = 0

var _ability_data: AbilityData

func enter() -> void:
	_ability_data = player.ability_manager.get_ability(ability_index)
	player.velocity = Vector2.ZERO
	player.ability_manager.start_cooldown(ability_index)
	EventBus.ability_used.emit(ability_index)

func _transition_to_idle() -> void:
	transition_requested.emit(self, &"IdleState")
