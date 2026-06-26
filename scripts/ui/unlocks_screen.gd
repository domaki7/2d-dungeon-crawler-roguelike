extends Control

var _back_callback: Callable

func _ready() -> void:
	size = get_viewport().get_visible_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func set_back_callback(callback: Callable) -> void:
	_back_callback = callback

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)

	var title: Label = Label.new()
	title.text = "UNLOCKS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	vbox.add_child(title)

	var currency_label: Label = Label.new()
	currency_label.text = "Souls: %d" % SaveManager.get_meta_currency()
	currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	currency_label.add_theme_font_size_override("font_size", 7)
	currency_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9))
	vbox.add_child(currency_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer)

	var placeholder: Label = Label.new()
	placeholder.text = "No unlocks available yet."
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.add_theme_font_size_override("font_size", 6)
	placeholder.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(placeholder)

	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer2)

	var back_btn: Button = Button.new()
	back_btn.text = "Back"
	back_btn.add_theme_font_size_override("font_size", 8)
	back_btn.pressed.connect(_on_back_pressed)
	vbox.add_child(back_btn)
	back_btn.grab_focus()

func _on_back_pressed() -> void:
	if _back_callback.is_valid():
		_back_callback.call()
	queue_free()
