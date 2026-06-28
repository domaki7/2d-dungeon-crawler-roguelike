extends Area2D

var gold_value: int:
	get: return GameConfig.config.economy_gold_pickup_value

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		body.gold += gold_value
		EventBus.gold_changed.emit(body.gold)
		AudioManager.play_sfx(&"gold_pickup")
		queue_free()
