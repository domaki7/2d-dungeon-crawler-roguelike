class_name BeltSlot
extends Control

## HUD readout for the potion belt: framed icon, stack count and the hotkey
## hint. Sits beside the ability bar and mirrors EventBus.consumable_changed.

const SLOT_SIZE: Vector2 = Vector2(16.0, 16.0)

var _frame: Panel
var _icon: TextureRect
var _count_label: Label
var _key_label: Label
var _empty_label: Label
var _pulse_tween: Tween = null

func _ready() -> void:
	custom_minimum_size = SLOT_SIZE
	size = SLOT_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	EventBus.consumable_changed.connect(_on_consumable_changed)
	_show_empty()
	# The belt can be filled before this widget exists (the run grants a
	# starting potion during player spawn), so pull the current state too
	# rather than relying on catching the signal.
	_sync_from_player.call_deferred()

func _build_ui() -> void:
	_frame = Panel.new()
	_frame.size = SLOT_SIZE
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.8)
	style.border_color = Color(0.45, 0.4, 0.3)
	style.set_border_width_all(1)
	_frame.add_theme_stylebox_override("panel", style)
	add_child(_frame)

	_icon = TextureRect.new()
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.position = Vector2(1.0, 1.0)
	_icon.size = SLOT_SIZE - Vector2(2.0, 2.0)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)

	# Shown instead of the icon when the belt is empty, so the slot still
	# advertises that potions exist and which key drinks them.
	_empty_label = Label.new()
	_empty_label.text = "-"
	_empty_label.add_theme_font_size_override("font_size", 6)
	_empty_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.size = SLOT_SIZE
	_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_empty_label)

	_count_label = Label.new()
	_count_label.add_theme_font_size_override("font_size", 6)
	_count_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	_count_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	_count_label.add_theme_constant_override("outline_size", 2)
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count_label.position = Vector2(-1.0, 7.0)
	_count_label.size = Vector2(SLOT_SIZE.x, 8.0)
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_count_label)

	_key_label = Label.new()
	_key_label.text = "1"
	_key_label.add_theme_font_size_override("font_size", 5)
	_key_label.add_theme_color_override("font_color", Color(0.75, 0.7, 0.5))
	_key_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	_key_label.add_theme_constant_override("outline_size", 2)
	_key_label.position = Vector2(1.0, -1.0)
	_key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_key_label)

func _on_consumable_changed(item_data: Resource, count: int) -> void:
	var item: ItemData = item_data as ItemData
	if item == null or count <= 0:
		_show_empty()
		return
	_empty_label.visible = false
	_icon.visible = true
	_icon.texture = item.icon
	_count_label.text = str(count) if count > 1 else ""
	_pulse()

func _show_empty() -> void:
	_icon.visible = false
	_icon.texture = null
	_empty_label.visible = true
	_count_label.text = ""

## Brief scale pop so a pickup or a drink registers at the corner of the eye.
func _pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	pivot_offset = SLOT_SIZE / 2.0
	scale = Vector2(1.25, 1.25)
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_ease(Tween.EASE_OUT)

func _sync_from_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player == null:
		return
	var belt: ConsumableBelt = player.get_node_or_null("ConsumableBelt") as ConsumableBelt
	if belt == null or belt.is_empty():
		return
	_on_consumable_changed(belt.item, belt.count)
