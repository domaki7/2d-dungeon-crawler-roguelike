extends RoomTemplate

const ROOM_WIDTH: int = 24
const ROOM_HEIGHT: int = 16

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var wall_layer: TileMapLayer = $WallLayer

var _door_gap_cols: Array[int] = [11, 12]
var _door_gap_rows: Array[int] = [7, 8]

func _ready() -> void:
	_paint_room()
	super._ready()

func _paint_room() -> void:
	for x: int in range(1, ROOM_WIDTH - 1):
		for y: int in range(1, ROOM_HEIGHT - 1):
			floor_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	for x: int in range(ROOM_WIDTH):
		if x not in _door_gap_cols:
			wall_layer.set_cell(Vector2i(x, 0), 3, Vector2i(0, 0))
			wall_layer.set_cell(Vector2i(x, ROOM_HEIGHT - 1), 3, Vector2i(0, 0))
	for y: int in range(ROOM_HEIGHT):
		if y not in _door_gap_rows:
			wall_layer.set_cell(Vector2i(0, y), 4, Vector2i(0, 0))
			wall_layer.set_cell(Vector2i(ROOM_WIDTH - 1, y), 4, Vector2i(0, 0))
