class_name AbilitySlot
extends PanelContainer

@export var key_label_text: String = "Q"

var _cooldown_total: float = 0.0
var _cooldown_remaining: float = 0.0
var _is_on_cooldown: bool = false
var _countdown_label: Label

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	custom_minimum_size = Vector2(18, 22)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.8)
	style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	style.set_border_width_all(1)
	style.set_corner_radius_all(1)
	add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 1)
	add_child(vbox)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 2)
	vbox.add_child(spacer)

	var key_label: Label = Label.new()
	key_label.text = key_label_text
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.add_theme_font_size_override("font_size", 6)
	key_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.7))
	vbox.add_child(key_label)

	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", GameConfig.config.ui_cooldown_text_size)
	_countdown_label.add_theme_color_override("font_color", Color.WHITE)
	_countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	_countdown_label.visible = false
	_countdown_label.z_index = 1
	add_child(_countdown_label)

func start_cooldown(duration: float) -> void:
	_cooldown_total = duration
	_cooldown_remaining = duration
	_is_on_cooldown = true
	_countdown_label.visible = true
	queue_redraw()

func _process(delta: float) -> void:
	if not _is_on_cooldown:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		_is_on_cooldown = false
		_countdown_label.visible = false
		queue_redraw()
	else:
		_countdown_label.text = str(ceili(_cooldown_remaining))
		queue_redraw()

func _draw() -> void:
	if not _is_on_cooldown:
		return
	var rect_size: Vector2 = size
	var center: Vector2 = rect_size * 0.5
	var radius: float = maxf(rect_size.x, rect_size.y)
	var ratio: float = _cooldown_remaining / _cooldown_total
	var sweep_angle: float = ratio * TAU
	var start_angle: float = -PI / 2.0
	var segments: int = 32
	var points: PackedVector2Array = PackedVector2Array()
	points.append(center)
	for i: int in range(segments + 1):
		var angle: float = start_angle + (float(i) / float(segments)) * sweep_angle
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	var overlay_color: Color = GameConfig.config.ui_cooldown_overlay_color
	draw_colored_polygon(points, overlay_color)
