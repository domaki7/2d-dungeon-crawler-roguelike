extends PlayerState

func enter() -> void:
	player.velocity = Vector2.ZERO
	EventBus.player_died.emit()

func physics_process_state(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
