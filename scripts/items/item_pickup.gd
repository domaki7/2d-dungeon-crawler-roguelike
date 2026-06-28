class_name ItemPickup
extends Area2D

@export var item_data: ItemData
var bob_amplitude: float:
	get: return GameConfig.config.economy_bob_amplitude
var bob_speed: float:
	get: return GameConfig.config.economy_bob_speed

var _player_ref: CharacterBody2D = null
var _time: float = 0.0
var _base_position: Vector2 = Vector2.ZERO

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _interact_label: Label = $InteractLabel

func _ready() -> void:
	_base_position = _sprite.position
	_interact_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if item_data and item_data.icon:
		_sprite.texture = item_data.icon

func _process(delta: float) -> void:
	_time += delta
	_sprite.position.y = _base_position.y + sin(_time * bob_speed) * bob_amplitude

func _unhandled_input(event: InputEvent) -> void:
	if _player_ref and event.is_action_pressed(&"interact"):
		_swap_item()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	var player: CharacterBody2D = body as CharacterBody2D
	var player_stats: PlayerStats = player.get_node_or_null("PlayerStats") as PlayerStats
	if player_stats == null:
		return
	var existing: ItemData = player_stats.get_equipped(item_data.slot_type)
	if existing == null:
		player_stats.equip(item_data)
		EventBus.item_picked_up.emit(item_data)
		AudioManager.play_sfx(&"item_pickup")
		queue_free()
	else:
		_player_ref = player
		_interact_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_ref = null
		_interact_label.visible = false

func _swap_item() -> void:
	var player_stats: PlayerStats = _player_ref.get_node("PlayerStats") as PlayerStats
	var old_item: ItemData = player_stats.equip(item_data)
	EventBus.item_picked_up.emit(item_data)
	AudioManager.play_sfx(&"item_pickup")
	if old_item:
		_spawn_replacement(old_item)
	queue_free()

func _spawn_replacement(old_item: ItemData) -> void:
	var pickup: ItemPickup = duplicate() as ItemPickup
	pickup.item_data = old_item
	pickup.global_position = global_position
	get_parent().call_deferred("add_child", pickup)
