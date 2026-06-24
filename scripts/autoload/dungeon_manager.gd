extends Node

@export var fade_duration: float = 0.3

const ROOM_SCENES: Dictionary = {
	"room_001": "res://scenes/rooms/combat_rooms/room_001.tscn",
	"room_002": "res://scenes/rooms/combat_rooms/room_002.tscn",
	"room_003": "res://scenes/rooms/combat_rooms/room_003.tscn",
}

var _floor_graph: Dictionary = {}
var _current_room_id: int = 0
var _current_room: RoomTemplate = null
var _is_transitioning: bool = false
var _room_container: Node2D = null
var _player: CharacterBody2D = null
var _transition_overlay: ColorRect = null

func initialize(room_container: Node2D, player: CharacterBody2D) -> void:
	_cleanup()
	_room_container = room_container
	_player = player
	_current_room_id = 0
	_current_room = null
	_is_transitioning = false
	_floor_graph.clear()
	_generate_floor()
	_create_transition_overlay()
	if not EventBus.door_transition_requested.is_connected(_on_door_transition_requested):
		EventBus.door_transition_requested.connect(_on_door_transition_requested)
	if not EventBus.room_cleared.is_connected(_on_room_cleared):
		EventBus.room_cleared.connect(_on_room_cleared)
	_load_room(_current_room_id)
	_configure_doors(_current_room_id)
	_player.global_position = _current_room.get_player_spawn_position()
	_set_camera_limits()
	_current_room.activate()
	_floor_graph[_current_room_id].is_visited = true

func _generate_floor() -> void:
	_add_room_node(0, ROOM_SCENES["room_001"], "combat", {Door.Direction.SOUTH: 1})
	_add_room_node(1, ROOM_SCENES["room_002"], "combat", {Door.Direction.NORTH: 0, Door.Direction.SOUTH: 2})
	_add_room_node(2, ROOM_SCENES["room_003"], "combat", {Door.Direction.NORTH: 1, Door.Direction.SOUTH: 3})
	_add_room_node(3, ROOM_SCENES["room_001"], "combat", {Door.Direction.NORTH: 2, Door.Direction.SOUTH: 4})
	_add_room_node(4, ROOM_SCENES["room_002"], "combat", {Door.Direction.NORTH: 3})

func _add_room_node(id: int, scene_path: String, room_type: String, connections: Dictionary) -> void:
	_floor_graph[id] = {
		"id": id,
		"scene_path": scene_path,
		"room_type": room_type,
		"connections": connections,
		"is_visited": false,
		"is_cleared": false,
	}

func _cleanup() -> void:
	if _transition_overlay and is_instance_valid(_transition_overlay):
		var canvas_parent: Node = _transition_overlay.get_parent()
		if canvas_parent:
			canvas_parent.queue_free()
		_transition_overlay = null

func _create_transition_overlay() -> void:
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
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 384
		cam.limit_bottom = 256

func _on_room_cleared(room_id: int) -> void:
	if _floor_graph.has(room_id):
		_floor_graph[room_id].is_cleared = true
