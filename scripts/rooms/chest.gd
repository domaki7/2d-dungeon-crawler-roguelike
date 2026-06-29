class_name Chest
extends Area2D

signal opened()

enum ChestType { NORMAL, LOCKED, MIMIC, GILDED }

@export var chest_type: ChestType = ChestType.NORMAL
@export var loot_table: LootTable
@export var item_pickup_scene: PackedScene
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

var _is_opened: bool = false
var _player_nearby: bool = false
var _player_ref: CharacterBody2D = null
var _mimic_enemies_alive: int = 0

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
		_try_open()

func _try_open() -> void:
	match chest_type:
		ChestType.NORMAL:
			_open_normal()
		ChestType.LOCKED:
			_open_locked()
		ChestType.MIMIC:
			_open_mimic()
		ChestType.GILDED:
			_open_gilded()

func _open_normal() -> void:
	_finish_open()
	_spawn_contents()

func _open_locked() -> void:
	if _player_ref == null:
		return
	var floor_num: int = DungeonManager.get_current_floor_number()
	var cost: int = GameConfig.config.chest_locked_base_cost + (floor_num - 1) * GameConfig.config.chest_locked_cost_per_floor
	if _player_ref.gold < cost:
		_interact_label.text = "Need %dg" % cost
		_interact_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		var timer: SceneTreeTimer = get_tree().create_timer(1.0)
		timer.timeout.connect(_reset_interact_label)
		return
	_player_ref.gold -= cost
	EventBus.gold_changed.emit(_player_ref.gold)
	_finish_open()
	_spawn_contents()

func _open_mimic() -> void:
	_interact_label.visible = false
	_sprite.modulate = Color(1.0, 0.5, 0.5)
	AudioManager.play_sfx(&"hit")
	_spawn_chest_enemies(GameConfig.config.chest_mimic_enemy_count, false)

func _open_gilded() -> void:
	_interact_label.visible = false
	AudioManager.play_sfx(&"chest_open")
	_spawn_chest_enemies(GameConfig.config.chest_gilded_guard_count, true)

func _spawn_chest_enemies(count: int, is_gilded: bool) -> void:
	_is_opened = true
	var enemy_pool: Array[PackedScene] = DungeonManager.get_enemy_pool()
	if enemy_pool.is_empty():
		_finish_open()
		_spawn_contents_guaranteed(is_gilded)
		return
	_mimic_enemies_alive = count
	var spawned: Array = []
	for i: int in range(count):
		var scene: PackedScene = enemy_pool.pick_random()
		var enemy_node: Node2D = scene.instantiate() as Node2D
		var angle: float = TAU * float(i) / float(count)
		enemy_node.global_position = global_position + Vector2(cos(angle), sin(angle)) * 24.0
		get_parent().call_deferred("add_child", enemy_node)
		spawned.append(enemy_node)
		var hc: HealthComponent = enemy_node.get_node_or_null("HealthComponent") as HealthComponent
		if hc:
			hc.died.connect(_on_chest_enemy_died.bind(is_gilded))
	EventBus.chest_enemies_spawned.emit(spawned)

func _on_chest_enemy_died(is_gilded: bool) -> void:
	_mimic_enemies_alive -= 1
	if _mimic_enemies_alive <= 0:
		_finish_open()
		_spawn_contents_guaranteed(is_gilded)

func _finish_open() -> void:
	_is_opened = true
	_interact_label.visible = false
	if open_texture:
		_sprite.texture = open_texture
	else:
		_sprite.modulate = Color(0.6, 0.6, 0.6)
	AudioManager.play_sfx(&"chest_open")
	opened.emit()

func _spawn_contents() -> void:
	if loot_table == null or item_pickup_scene == null:
		return
	var rare_mult: float = DungeonManager.get_rare_weight_multiplier()
	var leg_mult: float = DungeonManager.get_legendary_weight_multiplier()
	var excluded: Array[int] = []
	if RunManager.has_legendary_limit_reached():
		excluded.append(ItemData.Rarity.LEGENDARY as int)
	var item: ItemData = loot_table.roll_for_floor(rare_mult, leg_mult, excluded)
	if item:
		_spawn_item_pickup(item)

func _spawn_contents_guaranteed(rare_plus_only: bool) -> void:
	if loot_table == null or item_pickup_scene == null:
		return
	var rare_mult: float = DungeonManager.get_rare_weight_multiplier()
	var leg_mult: float = DungeonManager.get_legendary_weight_multiplier()
	var excluded: Array[int] = []
	if RunManager.has_legendary_limit_reached():
		excluded.append(ItemData.Rarity.LEGENDARY as int)
	if rare_plus_only:
		excluded.append(ItemData.Rarity.COMMON as int)
		excluded.append(ItemData.Rarity.UNCOMMON as int)
	var item: ItemData = loot_table.roll_guaranteed_for_floor(rare_mult, leg_mult, excluded)
	if item:
		_spawn_item_pickup(item)

func _spawn_item_pickup(item: ItemData) -> void:
	var pickup: Node2D = item_pickup_scene.instantiate() as Node2D
	pickup.item_data = item
	pickup.global_position = global_position + Vector2(0.0, 16.0)
	get_parent().call_deferred("add_child", pickup)

func _reset_interact_label() -> void:
	if _player_nearby and not _is_opened:
		var floor_num: int = DungeonManager.get_current_floor_number()
		var cost: int = GameConfig.config.chest_locked_base_cost + (floor_num - 1) * GameConfig.config.chest_locked_cost_per_floor
		_interact_label.text = "[F] %dg" % cost
		_interact_label.add_theme_color_override("font_color", Color.WHITE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = true
		_player_ref = body as CharacterBody2D
		if not _is_opened:
			if chest_type == ChestType.LOCKED:
				var floor_num: int = DungeonManager.get_current_floor_number()
				var cost: int = GameConfig.config.chest_locked_base_cost + (floor_num - 1) * GameConfig.config.chest_locked_cost_per_floor
				_interact_label.text = "[F] %dg" % cost
			else:
				_interact_label.text = "[F]"
			_interact_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_player_nearby = false
		_player_ref = null
		_interact_label.visible = false
