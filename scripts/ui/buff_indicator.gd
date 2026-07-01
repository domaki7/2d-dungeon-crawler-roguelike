class_name BuffIndicator
extends Control

var _name_label: Label
var _bar_bg: ColorRect
var _bar_fill: ColorRect
var _total_duration: float = 0.0
var _remaining: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	_build_ui()
	EventBus.player_buff_applied.connect(_on_buff_applied)
	EventBus.player_buff_expired.connect(_on_buff_expired)
	visible = false

func _build_ui() -> void:
	var bar_w: float = GameConfig.config.ui_buff_bar_width
	var bar_h: float = GameConfig.config.ui_buff_bar_height
	custom_minimum_size = Vector2(bar_w, 6.0 + bar_h)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 5)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.custom_minimum_size = Vector2(bar_w, 6.0)
	add_child(_name_label)

	_bar_bg = ColorRect.new()
	_bar_bg.color = Color(0.1, 0.1, 0.15)
	_bar_bg.size = Vector2(bar_w, bar_h)
	_bar_bg.position = Vector2(0.0, 6.0)
	add_child(_bar_bg)

	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(1.0, 0.8, 0.2)
	_bar_fill.size = Vector2(bar_w, bar_h)
	_bar_fill.position = Vector2(0.0, 6.0)
	add_child(_bar_fill)

func _process(delta: float) -> void:
	if not _is_active:
		return
	_remaining = maxf(0.0, _remaining - delta)
	var ratio: float = _remaining / _total_duration if _total_duration > 0.0 else 0.0
	_bar_fill.size.x = GameConfig.config.ui_buff_bar_width * ratio
	if _remaining <= 0.0:
		_is_active = false
		visible = false

func _on_buff_applied(buff_name: String, buff_color: Color, duration: float) -> void:
	_total_duration = duration
	_remaining = duration
	_is_active = true
	_name_label.text = buff_name
	_bar_fill.color = buff_color
	_bar_fill.size.x = GameConfig.config.ui_buff_bar_width
	visible = true

func _on_buff_expired() -> void:
	_is_active = false
	visible = false
