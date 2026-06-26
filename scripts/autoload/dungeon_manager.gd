extends Node

@export var fade_duration: float = 0.3

var _floor_graph: Dictionary = {}
var _current_room_id: int = 0
var _current_room: RoomTemplate = null
var _is_transitioning: bool = false
var _room_container: Node2D = null
var _player: CharacterBody2D = null
var _transition_overlay: ColorRect = null
var _current_floor_number: int = 1

func initialize(room_container: Node2D, player: CharacterBody2D) -> void:
	_room_container = room_container
	_player = player
	_create_transition_overlay()
	if not EventBus.door_transition_requested.is_connected(_on_door_transition_requested):
		EventBus.door_transition_requested.connect(_on_door_transition_requested)
	if not EventBus.room_cleared.is_connected(_on_room_cleared):
		EventBus.room_cleared.connect(_on_room_cleared)

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

func is_final_room(room_id: int) -> bool:
	var room_data: Dictionary = _floor_graph.get(room_id, {})
	return room_data.get("is_final", false)

func _build_floor_graph(config: FloorConfig) -> void:
	var room_count: int = randi_range(config.room_count_min, config.room_count_max)
	var combat_scenes: Array[PackedScene] = config.combat_room_scenes
	if combat_scenes.is_empty():
		push_error("FloorConfig has no combat room scenes")
		return

	var room_types: Array[String] = []
	for i: int in range(room_count):
		room_types.append("combat")

	var special_positions: Array[int] = []
	for i: int in range(1, room_count - 1):
		special_positions.append(i)
	special_positions.shuffle()

	if config.has_shop and config.shop_room_scene and not special_positions.is_empty():
		var pos: int = special_positions.pop_front()
		room_types[pos] = "shop"

	if config.has_treasure and config.treasure_room_scene and not special_positions.is_empty():
		var pos: int = special_positions.pop_front()
		room_types[pos] = "treasure"

	var total_rooms: int = room_count
	if config.has_boss and config.boss_room_scene:
		total_rooms += 1

	for i: int in range(total_rooms):
		var scene_path: String
		var room_type: String
		var is_final: bool = false

		if config.has_boss and config.boss_room_scene and i == total_rooms - 1:
			scene_path = config.boss_room_scene.resource_path
			room_type = "boss"
			is_final = true
		elif i < room_count:
			room_type = room_types[i]
			match room_type:
				"shop":
					scene_path = config.shop_room_scene.resource_path
				"treasure":
					scene_path = config.treasure_room_scene.resource_path
				_:
					scene_path = combat_scenes.pick_random().resource_path
		else:
			continue

		if not config.has_boss and i == total_rooms - 1:
			is_final = true

		var connections: Dictionary = {}
		if i > 0:
			connections[Door.Direction.NORTH] = i - 1
		if i < total_rooms - 1:
			connections[Door.Direction.SOUTH] = i + 1

		_floor_graph[i] = {
			"id": i,
			"scene_path": scene_path,
			"room_type": room_type,
			"connections": connections,
			"is_visited": false,
			"is_cleared": false,
			"is_final": is_final,
		}

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
