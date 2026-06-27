class_name Chest
extends Area2D

signal opened()

@export var loot_table: LootTable
@export var item_pickup_scene: PackedScene
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

var _is_opened: bool = false
var _player_nearby: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _interact_label: Label = $InteractLabel

func _ready() -> void:
	_interact_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if closed_texture:
		_sprite.texture = closed_texture

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and not _is_opened and event.is_action_pressed(&"interact"):
		open()

func open() -> void:
	_is_opened = true
	_interact_label.visible = false
	if open_texture:
		_sprite.texture = open_texture
	else:
		_sprite.modulate = Color(0.6, 0.6, 0.6)
	_spawn_contents()
	AudioManager.play_sfx(&"chest_open")
	opened.emit()

func _spawn_contents() -> void:
	if loot_table == null or item_pickup_scene == null:
		return
	var item: ItemData = loot_table.roll()
	if item:
		var pickup: Node2D = item_pickup_scene.instantiate() as Node2D
		pickup.item_data = item
		pickup.global_position = global_position + Vector2(0.0, 16.0)
		get_parent().call_deferred("add_child", pickup)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = true
		if not _is_opened:
			_interact_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = false
		_interact_label.visible = false
