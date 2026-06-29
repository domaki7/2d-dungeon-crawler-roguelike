extends Node

var fade_duration: float:
	get: return GameConfig.config.dungeon_fade_duration

var _floor_graph: Dictionary = {}
var _current_room_id: int = 0
var _current_room: RoomTemplate = null
var _is_transitioning: bool = false
var _room_container: Node2D = null
var _player: CharacterBody2D = null
var _transition_overlay: ColorRect = null
var _current_floor_number: int = 1
var _current_config: FloorConfig = null

func initialize(room_container: Node2D, player: CharacterBody2D) -> void:
	_room_container = room_container
	_player = player
	_create_transition_overlay()
	if not EventBus.door_transition_requested.is_connected(_on_door_transition_requested):
		EventBus.door_transition_requested.connect(_on_door_transition_requested)
	if not EventBus.room_cleared.is_connected(_on_room_cleared):
		EventBus.room_cleared.connect(_on_room_cleared)
	if not EventBus.boss_fight_started.is_connected(_on_boss_fight_started):
		EventBus.boss_fight_started.connect(_on_boss_fight_started)
	if not EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.connect(_on_boss_defeated)

func generate_floor(floor_number: int, config: FloorConfig) -> void:
	_is_transitioning = true
	if _player:
		_player.set_physics_process(false)
		_player.set_process(false)
		_player.velocity = Vector2.ZERO

	if _transition_overlay:
		var tween_out: Tween = create_tween()
		tween_out.tween_property(_transition_overlay, "modulate:a", 1.0, fade_duration)
		await tween_out.finished

	_cleanup_room()
	_current_floor_number = floor_number
	_current_config = config
	_current_room_id = 0
	_current_room = null
	_floor_graph.clear()
	_build_floor_graph(config)

	await get_tree().process_frame

	_load_room(_current_room_id)
	_configure_doors(_current_room_id)
	_player.global_position = _current_room.get_player_spawn_position()
	_set_camera_limits()
	_current_room.activate()
	_floor_graph[_current_room_id].is_visited = true
	EventBus.floor_started.emit(floor_number)
	AudioManager.play_music(&"dungeon_ambient")

	if _transition_overlay:
		var tween_in: Tween = create_tween()
		tween_in.tween_property(_transition_overlay, "modulate:a", 0.0, fade_duration)
		await tween_in.finished

	if _player:
		_player.set_physics_process(true)
		_player.set_process(true)
	_is_transitioning = false

func get_floor_graph() -> Dictionary:
	return _floor_graph

func get_current_room_id() -> int:
	return _current_room_id

func get_current_floor_number() -> int:
	return _current_floor_number

func get_difficulty_multiplier() -> float:
	if _current_config:
		return _current_config.enemy_difficulty_multiplier
	return 1.0

func get_speed_multiplier() -> float:
	if _current_config:
		return _current_config.enemy_speed_multiplier
	return 1.0

func get_elite_chance() -> float:
	if _current_config:
		return _current_config.elite_chance
	return 0.0

func get_gold_multiplier() -> float:
	if _current_config:
		return _current_config.gold_multiplier
	return 1.0

func get_enemy_pool() -> Array[PackedScene]:
	if _current_config:
		return _current_config.enemy_pool
	return []

func is_final_room(room_id: int) -> bool:
	var room_data: Dictionary = _floor_graph.get(room_id, {})
	return room_data.get("is_final", false)

func _build_floor_graph(config: FloorConfig) -> void:
	var room_count: int = randi_range(config.room_count_min, config.room_count_max)
	var combat_scenes: Array[PackedScene] = config.combat_room_scenes
	if combat_scenes.is_empty():
		push_error("FloorConfig has no combat room scenes")
		return

	var next_id: int = 0
	var grid_to_id: Dictionary = {}

	var room_types: Array[String] = []
	for i: int in range(room_count):
		room_types.append("combat")

	var special_positions: Array[int] = []
	for i: int in range(1, room_count - 1):
		special_positions.append(i)
	special_positions.shuffle()

	var shop_placed: bool = false
	var treasure_placed: bool = false

	if config.has_shop and config.shop_room_scene and not special_positions.is_empty():
		var pos: int = special_positions.pop_front()
		room_types[pos] = "shop"
		shop_placed = true

	if config.has_treasure and config.treasure_room_scene and not special_positions.is_empty():
		var pos: int = special_positions.pop_front()
		room_types[pos] = "treasure"
		treasure_placed = true

	var main_path_ids: Array[int] = []
	for i: int in range(room_count):
		var room_id: int = next_id
		next_id += 1
		main_path_ids.append(room_id)
		var grid_pos: Vector2i = Vector2i(0, i)
		grid_to_id[grid_pos] = room_id

		var scene_path: String = _get_scene_path_for_type(room_types[i], config, combat_scenes)
		var connections: Dictionary = {}
		if i > 0:
			connections[Door.Direction.NORTH] = main_path_ids[i - 1]
		_floor_graph[room_id] = {
			"id": room_id,
			"scene_path": scene_path,
			"room_type": room_types[i],
			"connections": connections,
			"is_visited": false,
			"is_cleared": false,
			"is_final": false,
			"grid_pos": grid_pos,
		}

	for i: int in range(room_count - 1):
		_floor_graph[main_path_ids[i]].connections[Door.Direction.SOUTH] = main_path_ids[i + 1]

	for i: int in range(1, room_count - 1):
		if randf() > config.branch_chance:
			continue

		var direction: Door.Direction
		var dx: int
		var east_pos: Vector2i = Vector2i(1, i)
		var west_pos: Vector2i = Vector2i(-1, i)
		var east_free: bool = not grid_to_id.has(east_pos)
		var west_free: bool = not grid_to_id.has(west_pos)

		if east_free and west_free:
			if randi() % 2 == 0:
				direction = Door.Direction.EAST
				dx = 1
			else:
				direction = Door.Direction.WEST
				dx = -1
		elif east_free:
			direction = Door.Direction.EAST
			dx = 1
		elif west_free:
			direction = Door.Direction.WEST
			dx = -1
		else:
			continue

		var opposite_dir: Door.Direction = Door.Direction.WEST if direction == Door.Direction.EAST else Door.Direction.EAST
		var branch_main_id: int = main_path_ids[i]

		var branch_type: String = "combat"
		var branch_depth: int = randi_range(1, config.max_branch_depth)

		var branch_grid_1: Vector2i = Vector2i(dx, i)
		var branch_id_1: int = next_id
		next_id += 1
		grid_to_id[branch_grid_1] = branch_id_1

		var scene_path_1: String = combat_scenes.pick_random().resource_path
		_floor_graph[branch_id_1] = {
			"id": branch_id_1,
			"scene_path": scene_path_1,
			"room_type": branch_type,
			"connections": {opposite_dir: branch_main_id},
			"is_visited": false,
			"is_cleared": false,
			"is_final": false,
			"grid_pos": branch_grid_1,
		}
		_floor_graph[branch_main_id].connections[direction] = branch_id_1

		if branch_depth >= 2:
			var branch_grid_2: Vector2i = Vector2i(dx, i + 1)
			if grid_to_id.has(branch_grid_2):
				continue

			var branch_id_2: int = next_id
			next_id += 1
			grid_to_id[branch_grid_2] = branch_id_2

			var depth2_type: String = "combat"
			if not shop_placed and config.has_shop and config.shop_room_scene:
				depth2_type = "shop"
				shop_placed = true
			elif not treasure_placed and config.has_treasure and config.treasure_room_scene:
				depth2_type = "treasure"
				treasure_placed = true

			var scene_path_2: String = _get_scene_path_for_type(depth2_type, config, combat_scenes)
			_floor_graph[branch_id_2] = {
				"id": branch_id_2,
				"scene_path": scene_path_2,
				"room_type": depth2_type,
				"connections": {Door.Direction.NORTH: branch_id_1},
				"is_visited": false,
				"is_cleared": false,
				"is_final": false,
				"grid_pos": branch_grid_2,
			}
			_floor_graph[branch_id_1].connections[Door.Direction.SOUTH] = branch_id_2

			var loop_target_grid: Vector2i = Vector2i(0, i + 1)
			if grid_to_id.has(loop_target_grid):
				var loop_target_id: int = grid_to_id[loop_target_grid] as int
				_floor_graph[branch_id_2].connections[opposite_dir] = loop_target_id
				_floor_graph[loop_target_id].connections[direction] = branch_id_2

	if config.has_boss and config.boss_room_scene:
		var boss_id: int = next_id
		var boss_grid: Vector2i = Vector2i(0, room_count)
		grid_to_id[boss_grid] = boss_id
		var last_main_id: int = main_path_ids[room_count - 1]

		_floor_graph[last_main_id].connections[Door.Direction.SOUTH] = boss_id
		_floor_graph[boss_id] = {
			"id": boss_id,
			"scene_path": config.boss_room_scene.resource_path,
			"room_type": "boss",
			"connections": {Door.Direction.NORTH: last_main_id},
			"is_visited": false,
			"is_cleared": false,
			"is_final": true,
			"grid_pos": boss_grid,
		}
	else:
		var last_id: int = main_path_ids[room_count - 1]
		_floor_graph[last_id].is_final = true

func _get_scene_path_for_type(room_type: String, config: FloorConfig, combat_scenes: Array[PackedScene]) -> String:
	match room_type:
		"shop":
			return config.shop_room_scene.resource_path
		"treasure":
			return config.treasure_room_scene.resource_path
		_:
			return combat_scenes.pick_random().resource_path

func _cleanup_room() -> void:
	if _current_room and is_instance_valid(_current_room):
		_current_room.queue_free()
		_current_room = null

func cleanup() -> void:
	_cleanup_room()
	if _transition_overlay and is_instance_valid(_transition_overlay):
		var canvas_parent: Node = _transition_overlay.get_parent()
		if canvas_parent:
			canvas_parent.queue_free()
		_transition_overlay = null
	_floor_graph.clear()

func _create_transition_overlay() -> void:
	if _transition_overlay and is_instance_valid(_transition_overlay):
		return
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.size = Vector2(480, 270)
	_transition_overlay.modulate.a = 0.0
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(_transition_overlay)

func _on_door_transition_requested(door: Node) -> void:
	if _is_transitioning:
		return
	var door_typed: Door = door as Door
	if door_typed == null:
		return
	var room_data: Dictionary = _floor_graph[_current_room_id]
	var connections: Dictionary = room_data.connections
	if not connections.has(door_typed.direction):
		return
	var target_id: int = connections[door_typed.direction] as int
	_transition_to_room(target_id, door_typed.direction)

func _transition_to_room(target_id: int, from_direction: Door.Direction) -> void:
	_is_transitioning = true
	_player.set_physics_process(false)
	_player.set_process(false)
	_player.velocity = Vector2.ZERO

	var tween_out: Tween = create_tween()
	tween_out.tween_property(_transition_overlay, "modulate:a", 1.0, fade_duration)
	await tween_out.finished

	_current_room.queue_free()
	await get_tree().process_frame

	_load_room(target_id)
	_configure_doors(target_id)
	_player.global_position = _current_room.get_door_spawn_position(from_direction)
	_current_room_id = target_id
	_set_camera_limits()

	var target_data: Dictionary = _floor_graph[target_id]
	target_data.is_visited = true
	_current_room.activate(target_data.is_cleared)

	var tween_in: Tween = create_tween()
	tween_in.tween_property(_transition_overlay, "modulate:a", 0.0, fade_duration)
	await tween_in.finished

	_player.set_physics_process(true)
	_player.set_process(true)
	_is_transitioning = false

func _load_room(room_id: int) -> void:
	var room_data: Dictionary = _floor_graph[room_id]
	var scene: PackedScene = load(room_data.scene_path) as PackedScene
	_current_room = scene.instantiate() as RoomTemplate
	_current_room.room_id = room_id
	_room_container.add_child(_current_room)

func _configure_doors(room_id: int) -> void:
	var connections: Dictionary = _floor_graph[room_id].connections
	for door_node: Node in _current_room.doors_container.get_children():
		var door: Door = door_node as Door
		if door and not connections.has(door.direction):
			door.lock()
			door.set_deferred("monitoring", false)

func _set_camera_limits() -> void:
	var cam: Camera2D = _player.get_node("Camera2D") as Camera2D
	if not cam:
		return
	var room_width: int = _current_room.room_pixel_width
	var room_height: int = _current_room.room_pixel_height
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = room_width
	cam.limit_bottom = room_height

func _on_room_cleared(room_id: int) -> void:
	if _floor_graph.has(room_id):
		_floor_graph[room_id].is_cleared = true

func _on_boss_fight_started(_boss_name: String, _health_component: Node) -> void:
	AudioManager.play_music(&"boss_fight")

func _on_boss_defeated(_boss_id: String) -> void:
	AudioManager.play_music(&"dungeon_ambient")
