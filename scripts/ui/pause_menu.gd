extends CanvasLayer

var _is_paused: bool = false
var _panel: PanelContainer
var _sfx_slider: HSlider
var _music_slider: HSlider
var _fullscreen_check: CheckButton
var _shake_check: CheckButton

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if _is_paused:
			resume()
		elif not get_tree().paused:
			pause()
		get_viewport().set_input_as_handled()

func pause() -> void:
	_is_paused = true
	visible = true
	get_tree().paused = true
	_sync_controls()

func resume() -> void:
	_is_paused = false
	visible = false
	get_tree().paused = false

func _sync_controls() -> void:
	_sfx_slider.value = SaveManager.get_setting("sfx_volume_db", -5.0)
	_music_slider.value = SaveManager.get_setting("music_volume_db", -10.0)
	_fullscreen_check.button_pressed = SaveManager.get_setting("fullscreen", false)
	_shake_check.button_pressed = SaveManager.get_setting("screen_shake_enabled", true)

func _build_ui() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(160, 170)
	_panel.position = Vector2(-80, -85)
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.08, 0.15, 0.95)
	panel_style.border_color = Color(0.4, 0.35, 0.5)
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 3)
	_panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep1: HSeparator = HSeparator.new()
	vbox.add_child(sep1)

	var vol_min: float = GameConfig.config.ui_pause_volume_min_db
	var vol_max: float = GameConfig.config.ui_pause_volume_max_db

	_sfx_slider = _create_slider_row(vbox, "SFX", vol_min, vol_max, -5.0)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	_music_slider = _create_slider_row(vbox, "Music", vol_min, vol_max, -10.0)
	_music_slider.value_changed.connect(_on_music_volume_changed)

	_fullscreen_check = _create_toggle_row(vbox, "Fullscreen", false)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)

	_shake_check = _create_toggle_row(vbox, "Shake", true)
	_shake_check.toggled.connect(_on_shake_toggled)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var resume_btn: Button = _create_button("Resume")
	resume_btn.pressed.connect(resume)
	vbox.add_child(resume_btn)

	var restart_btn: Button = _create_button("Restart Run")
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

	var quit_btn: Button = _create_button("Quit to Title")
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)

func _create_slider_row(parent: VBoxContainer, label_text: String, min_val: float, max_val: float, default_val: float) -> HSlider:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	parent.add_child(hbox)

	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 7)
	label.custom_minimum_size.x = 36
	hbox.add_child(label)

	var slider: HSlider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 1.0
	slider.value = default_val
	slider.custom_minimum_size = Vector2(70, 10)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(slider)

	return slider

func _create_toggle_row(parent: VBoxContainer, label_text: String, default_val: bool) -> CheckButton:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	parent.add_child(hbox)

	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 7)
	label.custom_minimum_size.x = 36
	hbox.add_child(label)

	var toggle: CheckButton = CheckButton.new()
	toggle.button_pressed = default_val
	hbox.add_child(toggle)

	return toggle

func _create_button(text: String) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 7)
	btn.custom_minimum_size = Vector2(100, 14)
	return btn

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	SaveManager.set_setting("sfx_volume_db", value)

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	SaveManager.set_setting("music_volume_db", value)

func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SaveManager.set_setting("fullscreen", pressed)

func _on_shake_toggled(pressed: bool) -> void:
	SaveManager.set_setting("screen_shake_enabled", pressed)

func _on_restart_pressed() -> void:
	resume()
	RunManager.end_run(false)
	GameManager.start_run()

func _on_quit_pressed() -> void:
	resume()
	RunManager.end_run(false)
	GameManager.return_to_title()
