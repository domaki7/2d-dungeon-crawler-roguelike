extends RoomTemplate

const ROOM_WIDTH: int = 24
const ROOM_HEIGHT: int = 16

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var wall_layer: TileMapLayer = $WallLayer

var _door_gap_cols: Array[int] = [11, 12]
var _door_gap_rows: Array[int] = [7, 8]
var _choice_chests: Array[Chest] = []
var _hint_label: Label = null

func _ready() -> void:
	_paint_room()
	super._ready()
	_setup_choice_pedestals()

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

## The room's chests become a single choice: opening one seals the rest, so
## free loot turns into a build decision.
func _setup_choice_pedestals() -> void:
	for child: Node in get_children():
		var chest: Chest = child as Chest
		if chest and not chest.is_opened():
			_choice_chests.append(chest)
	if _choice_chests.size() < 2:
		return
	for chest: Chest in _choice_chests:
		chest.opened.connect(_on_chest_chosen.bind(chest))
	_create_hint_label()

func _create_hint_label() -> void:
	var center: Vector2 = Vector2.ZERO
	for chest: Chest in _choice_chests:
		center += chest.position
	center /= float(_choice_chests.size())

	_hint_label = Label.new()
	_hint_label.text = GameConfig.config.chest_choice_hint
	_hint_label.add_theme_font_size_override("font_size", 7)
	_hint_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.45))
	_hint_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_hint_label.add_theme_constant_override("outline_size", 2)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.size = Vector2(160.0, 10.0)
	_hint_label.position = center + Vector2(-80.0, -34.0)
	add_child(_hint_label)

func _on_chest_chosen(chosen: Chest) -> void:
	for chest: Chest in _choice_chests:
		if chest != chosen and is_instance_valid(chest):
			chest.seal()
	if _hint_label:
		var tween: Tween = create_tween()
		tween.tween_property(_hint_label, "modulate:a", 0.0, 0.4)
		tween.tween_callback(_hint_label.queue_free)
		_hint_label = null
