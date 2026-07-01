class_name DarkRoom
extends RoomTemplate

const ROOM_WIDTH: int = 24
const ROOM_HEIGHT: int = 16

var _door_gap_cols: Array[int] = [11, 12]
var _door_gap_rows: Array[int] = [7, 8]
var _darkness_shader: Shader = preload("res://shaders/darkness_overlay.gdshader")

@onready var _floor_layer: TileMapLayer = $FloorLayer
@onready var _wall_layer: TileMapLayer = $WallLayer

var _overlay_layer: CanvasLayer = null
var _overlay_material: ShaderMaterial = null
var _player_ref: Node2D = null

func _ready() -> void:
	_paint_room()
	super._ready()
	_setup_darkness()

func _paint_room() -> void:
	var floor_sources: Array[int] = [0, 1, 2]
	for x: int in range(1, ROOM_WIDTH - 1):
		for y: int in range(1, ROOM_HEIGHT - 1):
			var source_id: int = floor_sources.pick_random()
			_floor_layer.set_cell(Vector2i(x, y), source_id, Vector2i(0, 0))
	for x: int in range(ROOM_WIDTH):
		if x not in _door_gap_cols:
			_wall_layer.set_cell(Vector2i(x, 0), 3, Vector2i(0, 0))
			_wall_layer.set_cell(Vector2i(x, ROOM_HEIGHT - 1), 3, Vector2i(0, 0))
	for y: int in range(ROOM_HEIGHT):
		if y not in _door_gap_rows:
			_wall_layer.set_cell(Vector2i(0, y), 4, Vector2i(0, 0))
			_wall_layer.set_cell(Vector2i(ROOM_WIDTH - 1, y), 4, Vector2i(0, 0))

func _setup_darkness() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 10
	add_child(_overlay_layer)

	var overlay_rect: ColorRect = ColorRect.new()
	overlay_rect.size = Vector2(480.0, 270.0)
	overlay_rect.position = Vector2.ZERO
	overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_overlay_material = ShaderMaterial.new()
	_overlay_material.shader = _darkness_shader
	_overlay_material.set_shader_parameter("light_radius", GameConfig.config.dark_room_light_radius)
	_overlay_material.set_shader_parameter("edge_softness", GameConfig.config.dark_room_edge_softness)
	_overlay_material.set_shader_parameter("viewport_size", Vector2(480.0, 270.0))
	_overlay_material.set_shader_parameter("player_screen_pos", Vector2(240.0, 135.0))
	overlay_rect.material = _overlay_material
	_overlay_layer.add_child(overlay_rect)

func activate(already_cleared: bool = false) -> void:
	super.activate(already_cleared)
	_player_ref = get_tree().get_first_node_in_group(&"player") as Node2D
	AudioManager.play_sfx(&"cave_ambience")

func _process(_delta: float) -> void:
	if _overlay_material == null or _player_ref == null or not is_instance_valid(_player_ref):
		return
	var world_to_vp: Transform2D = get_viewport().get_canvas_transform()
	var player_screen_pos: Vector2 = world_to_vp * _player_ref.global_position
	_overlay_material.set_shader_parameter("player_screen_pos", player_screen_pos)
