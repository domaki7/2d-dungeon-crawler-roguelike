extends Area2D

var gold_multiplier: float = 1.0

var gold_value: int:
	get: return maxi(1, int(GameConfig.config.economy_gold_pickup_value * gold_multiplier))

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		var stats: PlayerStats = body.get_node_or_null("PlayerStats") as PlayerStats
		var meta_mult: float = stats.meta_gold_multiplier if stats else 1.0
		body.gold += maxi(1, int(gold_value * meta_mult))
		EventBus.gold_changed.emit(body.gold)
		AudioManager.play_sfx(&"gold_pickup")
		queue_free()
