extends Area2D

@export var gold_value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		body.gold += gold_value
		EventBus.gold_changed.emit(body.gold)
		AudioManager.play_sfx(&"gold_pickup")
		queue_free()
