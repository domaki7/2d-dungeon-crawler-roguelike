extends Node

func _ready() -> void:
	GameManager.show_title_screen.call_deferred()
