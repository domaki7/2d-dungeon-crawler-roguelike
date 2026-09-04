extends Area2D

var gold_multiplier: float = 1.0

var gold_value: int:
	get: return maxi(1, int(GameConfig.config.economy_gold_pickup_value * gold_multiplier))

var _player: CharacterBody2D = null
var _player_stats: PlayerStats = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not _ensure_player():
		return
	var to_player: Vector2 = _player.global_position - global_position
	var distance: float = to_player.length()
	var radius: float = _get_magnet_radius()
	if distance > radius or distance <= 0.01:
		return
	# Accelerate as the coin closes in, so the last stretch snaps rather than
	# trailing the player around the room.
	var closeness: float = 1.0 - (distance / radius)
	var speed: float = lerpf(
		GameConfig.config.economy_gold_magnet_min_speed,
		GameConfig.config.economy_gold_magnet_max_speed,
		closeness
	)
	global_position += (to_player / distance) * speed * delta

func _ensure_player() -> bool:
	if _player != null and is_instance_valid(_player):
		return true
	_player = get_tree().get_first_node_in_group(&"player") as CharacterBody2D
	if _player == null:
		return false
	_player_stats = _player.get_node_or_null("PlayerStats") as PlayerStats
	return true

func _get_magnet_radius() -> float:
	var radius: float = GameConfig.config.economy_gold_magnet_base_radius
	if _player_stats and _player_stats.has_effect(&"gold_magnet"):
		radius += _player_stats.get_effect_value(&"gold_magnet")
	return radius

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		var stats: PlayerStats = body.get_node_or_null("PlayerStats") as PlayerStats
		var meta_mult: float = stats.meta_gold_multiplier if stats else 1.0
		body.gold += maxi(1, int(gold_value * meta_mult))
		EventBus.gold_changed.emit(body.gold)
		AudioManager.play_sfx(&"gold_pickup")
		queue_free()
