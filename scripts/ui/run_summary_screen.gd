extends Control

var _victory: bool = false
var _stats: Dictionary = {}

func _ready() -> void:
	size = get_viewport().get_visible_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(victory: bool, stats: Dictionary) -> void:
	_victory = victory
	_stats = stats
	_build_ui()

func _build_ui() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	var title: Label = Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	if _victory:
		title.text = "VICTORY"
		title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))
	else:
		title.text = "YOU DIED"
		title.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
	vbox.add_child(title)

	var spacer_top: Control = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer_top)

	_add_stat_line(vbox, "Floor Reached", str(_stats.get("floors_cleared", 0)))
	_add_stat_line(vbox, "Enemies Killed", str(_stats.get("kills", 0)))
	_add_stat_line(vbox, "Rooms Cleared", str(_stats.get("rooms_cleared", 0)))
	var time_secs: float = _stats.get("time_elapsed", 0.0)
	var minutes: int = int(time_secs) / 60
	var seconds: int = int(time_secs) % 60
	_add_stat_line(vbox, "Time", "%d:%02d" % [minutes, seconds])

	var spacer_mid: Control = Control.new()
	spacer_mid.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer_mid)

	var currency_earned: int = _stats.get("meta_currency_earned", 0)
	var currency_label: Label = Label.new()
	currency_label.text = "Souls Earned: %d" % currency_earned
	currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	currency_label.add_theme_font_size_override("font_size", 8)
	currency_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9))
	vbox.add_child(currency_label)

	var total_label: Label = Label.new()
	total_label.text = "Total Souls: %d" % SaveManager.get_meta_currency()
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_label.add_theme_font_size_override("font_size", 6)
	total_label.add_theme_color_override("font_color", Color(0.5, 0.35, 0.75))
	vbox.add_child(total_label)

	var spacer_bottom: Control = Control.new()
	spacer_bottom.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer_bottom)

	var continue_btn: Button = Button.new()
	continue_btn.text = "Continue"
	continue_btn.add_theme_font_size_override("font_size", 8)
	continue_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_btn)
	continue_btn.grab_focus()

func _add_stat_line(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)

	var label: Label = Label.new()
	label.text = label_text + ":"
	label.add_theme_font_size_override("font_size", 6)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(label)

	var value: Label = Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 6)
	value.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	hbox.add_child(value)

func _on_continue_pressed() -> void:
	GameManager.return_to_title()
