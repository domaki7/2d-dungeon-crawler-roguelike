class_name AbilitySlot
extends PanelContainer

@export var key_label_text: String = "Q"

var _cooldown_overlay: ColorRect = null
var _cooldown_total: float = 0.0
var _cooldown_remaining: float = 0.0
var _is_on_cooldown: bool = false

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

	_cooldown_overlay = ColorRect.new()
	_cooldown_overlay.color = Color(0.0, 0.0, 0.0, 0.6)
	_cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cooldown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cooldown_overlay.visible = false
	add_child(_cooldown_overlay)

func start_cooldown(duration: float) -> void:
	_cooldown_total = duration
	_cooldown_remaining = duration
	_is_on_cooldown = true
	_cooldown_overlay.visible = true
	_cooldown_overlay.anchor_top = 0.0
	_cooldown_overlay.anchor_bottom = 1.0

func _process(delta: float) -> void:
	if not _is_on_cooldown:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		_is_on_cooldown = false
		_cooldown_overlay.visible = false
	else:
		var ratio: float = _cooldown_remaining / _cooldown_total
		_cooldown_overlay.anchor_top = 1.0 - ratio
