class_name AbilityState
extends PlayerState

@export var ability_index: int = 0

var _ability_data: AbilityData

func enter() -> void:
	_ability_data = player.ability_manager.get_ability(ability_index)
	player.velocity = Vector2.ZERO
	player.ability_manager.start_cooldown(ability_index)
	EventBus.ability_used.emit(ability_index)
	if _ability_data:
		AudioManager.play_sfx(_ability_data.ability_id)
	if not player.health_component.died.is_connected(_on_player_died):
		player.health_component.died.connect(_on_player_died)

func exit() -> void:
	if player.health_component.died.is_connected(_on_player_died):
		player.health_component.died.disconnect(_on_player_died)

func _transition_to_idle() -> void:
	transition_requested.emit(self, &"IdleState")

func _on_player_died() -> void:
	transition_requested.emit(self, &"DeadState")
