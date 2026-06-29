extends Node

var max_floors: int:
	get: return GameConfig.config.dungeon_max_floors

var current_floor: int = 0
var run_active: bool = false
var run_stats: Dictionary = {}

const PLAYER_SCENES: Dictionary = {
	GameManager.PlayerClass.WARRIOR: "res://scenes/player/player.tscn",
	GameManager.PlayerClass.RANGER: "res://scenes/player/player_ranger.tscn",
	GameManager.PlayerClass.MAGE: "res://scenes/player/player_mage.tscn",
}

var _floor_configs: Array[FloorConfig] = []
var _game_scene: PackedScene = preload("res://scenes/main/game.tscn")
var _game_instance: Node = null
var _selected_class: int = GameManager.PlayerClass.WARRIOR
var _run_start_time: float = 0.0
var _last_gold: int = 0

func _ready() -> void:
	_load_floor_configs()
	EventBus.floor_completed.connect(_on_floor_completed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.item_picked_up.connect(_on_item_picked_up)

func start_run(player_class: int = GameManager.PlayerClass.WARRIOR) -> void:
	_selected_class = player_class
	current_floor = 0
	run_active = true
	_run_start_time = Time.get_ticks_msec() / 1000.0
	_last_gold = 0
	run_stats = {
		"kills": 0,
		"rooms_cleared": 0,
		"floors_cleared": 0,
		"gold_earned": 0,
		"time_elapsed": 0.0,
		"legendaries_found": 0,
	}
	_spawn_game_scene()
	_spawn_player()
	advance_floor()
	EventBus.run_started.emit()

func advance_floor() -> void:
	current_floor += 1
	if current_floor > max_floors:
		end_run(true)
		return
	var config_index: int = mini(current_floor - 1, _floor_configs.size() - 1)
	var config: FloorConfig = _floor_configs[config_index]
	var player: CharacterBody2D = _get_player()
	if player:
		_reset_player_for_floor(player)
	DungeonManager.generate_floor(current_floor, config)

func end_run(victory: bool) -> void:
	if not run_active:
		return
	run_active = false
	run_stats.time_elapsed = (Time.get_ticks_msec() / 1000.0) - _run_start_time
	run_stats.floors_cleared = current_floor - 1 if not victory else current_floor
	var meta_currency: int = _calculate_meta_currency(victory)
	run_stats["meta_currency_earned"] = meta_currency
	if meta_currency > 0:
		SaveManager.add_meta_currency(meta_currency)
		SaveManager.update_lifetime_stats(run_stats)
		SaveManager.save()
	EventBus.run_ended.emit(victory, run_stats)

func cleanup_game() -> void:
	DungeonManager.cleanup()
	if _game_instance and is_instance_valid(_game_instance):
		_game_instance.queue_free()
		_game_instance = null

func _spawn_game_scene() -> void:
	cleanup_game()
	_game_instance = _game_scene.instantiate()
	get_tree().root.add_child(_game_instance)

func _spawn_player() -> void:
	var scene_path: String = PLAYER_SCENES.get(_selected_class, PLAYER_SCENES[GameManager.PlayerClass.WARRIOR])
	var player_scene: PackedScene = load(scene_path) as PackedScene
	var player_node: CharacterBody2D = player_scene.instantiate() as CharacterBody2D
	_game_instance.initialize_with_player(player_node)

func _get_player() -> CharacterBody2D:
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.is_empty():
		return null
	return players[0] as CharacterBody2D

func _reset_player_for_floor(player: CharacterBody2D) -> void:
	var hc: HealthComponent = player.get_node_or_null("HealthComponent") as HealthComponent
	if hc:
		hc.heal(hc.max_hp)
	player.velocity = Vector2.ZERO

func _calculate_meta_currency(victory: bool) -> int:
	var currency: int = 0
	currency += run_stats.get("floors_cleared", 0) * GameConfig.config.economy_floor_multiplier
	currency += run_stats.get("kills", 0) * GameConfig.config.economy_kill_multiplier
	if victory:
		currency += GameConfig.config.economy_victory_bonus
	return currency

func _load_floor_configs() -> void:
	_floor_configs.clear()
	var floor_index: int = 1
	while true:
		var path: String = "res://resources/floors/floor_%d.tres" % floor_index
		if not ResourceLoader.exists(path):
			break
		var config: FloorConfig = load(path) as FloorConfig
		if config:
			_floor_configs.append(config)
		floor_index += 1
	if _floor_configs.is_empty():
		push_error("RunManager: No floor configs found in res://resources/floors/")

func _on_floor_completed(_floor_number: int) -> void:
	if run_active:
		run_stats.floors_cleared = current_floor
		advance_floor()

func _on_player_died() -> void:
	if run_active:
		await get_tree().create_timer(1.5).timeout
		end_run(false)

func _on_enemy_killed(_enemy_data: Dictionary) -> void:
	run_stats.kills = run_stats.get("kills", 0) + 1

func _on_room_cleared(_room_id: int) -> void:
	run_stats.rooms_cleared = run_stats.get("rooms_cleared", 0) + 1

func _on_gold_changed(new_amount: int) -> void:
	var delta: int = new_amount - _last_gold
	if delta > 0:
		run_stats.gold_earned = run_stats.get("gold_earned", 0) + delta
	_last_gold = new_amount

func _on_item_picked_up(item_data: Resource) -> void:
	if not run_active:
		return
	var item: ItemData = item_data as ItemData
	if item and item.rarity == ItemData.Rarity.LEGENDARY:
		run_stats.legendaries_found = run_stats.get("legendaries_found", 0) + 1
		EventBus.legendary_item_found.emit(item)

func has_legendary_limit_reached() -> bool:
	var max_per_run: int = GameConfig.config.legendary_max_per_run
	if max_per_run <= 0:
		return false
	return run_stats.get("legendaries_found", 0) >= max_per_run
