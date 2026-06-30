class_name PressurePlate
extends Area2D

var _triggered: bool = false

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	collision_layer = 256
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.is_in_group(&"player"):
		return
	_triggered = true
	_sprite.modulate = GameConfig.config.pressure_plate_triggered_color
	AudioManager.play_sfx(&"ui_click")

	var room: RoomTemplate = _find_room()
	if room == null:
		return
	var count: int = randi_range(
		GameConfig.config.pressure_plate_ambush_count_min,
		GameConfig.config.pressure_plate_ambush_count_max
	)
	room.spawn_ambush(count, global_position)

func _find_room() -> RoomTemplate:
	var node: Node = get_parent()
	while node and not (node is RoomTemplate):
		node = node.get_parent()
	return node as RoomTemplate
