extends Control

var room_size: Vector2:
	get: return GameConfig.config.ui_minimap_room_size
var room_spacing: float:
	get: return GameConfig.config.ui_minimap_room_spacing

var _is_visible: bool = true

func _ready() -> void:
	_is_visible = true
	visible = _is_visible
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.floor_started.connect(_on_floor_started)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"minimap_toggle"):
		_is_visible = not _is_visible
		visible = _is_visible
		get_viewport().set_input_as_handled()

func _draw() -> void:
	var floor_graph: Dictionary = DungeonManager.get_floor_graph()
	if floor_graph.is_empty():
		return

	var current_id: int = DungeonManager.get_current_room_id()
	var current_room: Dictionary = floor_graph.get(current_id, {})
	var current_grid: Vector2i = current_room.get("grid_pos", Vector2i.ZERO) as Vector2i
	var center_offset: Vector2 = size / 2.0 - Vector2(current_grid) * room_spacing - room_size / 2.0

	for room_id: int in floor_graph:
		var room: Dictionary = floor_graph[room_id]
		var grid_pos: Vector2i = room.get("grid_pos", Vector2i.ZERO) as Vector2i
		var pos: Vector2 = Vector2(grid_pos) * room_spacing + center_offset

		var connections: Dictionary = room.get("connections", {})
		for dir: int in connections:
			var target_id: int = connections[dir] as int
			var target_room: Dictionary = floor_graph.get(target_id, {})
			var target_grid: Vector2i = target_room.get("grid_pos", Vector2i.ZERO) as Vector2i
			var target_pos: Vector2 = Vector2(target_grid) * room_spacing + center_offset
			draw_line(
				pos + room_size / 2.0,
				target_pos + room_size / 2.0,
				Color(0.3, 0.3, 0.35),
				1.0
			)

		var color: Color = _get_room_color(room, room_id == current_id)
		draw_rect(Rect2(pos, room_size), color)

		var room_type: String = room.get("room_type", "combat")
		if room_type == "boss":
			draw_rect(Rect2(pos, room_size), Color(0.8, 0.1, 0.1), false, 1.0)
		elif room_type == "shop":
			draw_rect(Rect2(pos, room_size), Color(0.9, 0.8, 0.2), false, 1.0)
		elif room_type == "treasure":
			draw_rect(Rect2(pos, room_size), Color(0.2, 0.7, 0.9), false, 1.0)
		elif room_type == "trap":
			draw_rect(Rect2(pos, room_size), Color(0.9, 0.5, 0.1), false, 1.0)
		elif room_type == "dark":
			draw_rect(Rect2(pos, room_size), Color(0.6, 0.2, 0.9), false, 1.0)

func _get_room_color(room: Dictionary, is_current: bool) -> Color:
	if is_current:
		return Color.WHITE
	if not room.get("is_visited", false):
		return Color(0.15, 0.15, 0.2)
	if room.get("is_cleared", false):
		return Color(0.2, 0.65, 0.3)
	return Color(0.7, 0.65, 0.2)

func _on_room_entered(_room_id: int) -> void:
	queue_redraw()

func _on_room_cleared(_room_id: int) -> void:
	queue_redraw()

func _on_floor_started(_floor_number: int) -> void:
	queue_redraw()
