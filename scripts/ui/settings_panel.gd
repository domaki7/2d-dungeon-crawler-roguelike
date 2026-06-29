extends VBoxContainer

var _sfx_slider: HSlider
var _music_slider: HSlider
var _fullscreen_check: CheckButton
var _shake_check: CheckButton

func _ready() -> void:
	add_theme_constant_override("separation", 3)
	_build_controls()
	sync_controls()

func sync_controls() -> void:
	_sfx_slider.value = SaveManager.get_setting("sfx_volume_db", -5.0)
	_music_slider.value = SaveManager.get_setting("music_volume_db", -10.0)
	_fullscreen_check.button_pressed = SaveManager.get_setting("fullscreen", false)
	_shake_check.button_pressed = SaveManager.get_setting("screen_shake_enabled", true)

func _build_controls() -> void:
	var vol_min: float = GameConfig.config.ui_settings_volume_min_db
	var vol_max: float = GameConfig.config.ui_settings_volume_max_db

	_sfx_slider = _create_slider_row("SFX", vol_min, vol_max)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	_music_slider = _create_slider_row("Music", vol_min, vol_max)
	_music_slider.value_changed.connect(_on_music_volume_changed)

	_fullscreen_check = _create_toggle_row("Fullscreen", false)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)

	_shake_check = _create_toggle_row("Shake", true)
	_shake_check.toggled.connect(_on_shake_toggled)

func _create_slider_row(label_text: String, min_val: float, max_val: float) -> HSlider:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	add_child(hbox)

	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 7)
	label.custom_minimum_size.x = 36
	hbox.add_child(label)

	var slider: HSlider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 1.0
	slider.custom_minimum_size = Vector2(70, 10)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(slider)

	return slider

func _create_toggle_row(label_text: String, default_val: bool) -> CheckButton:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	add_child(hbox)

	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 7)
	label.custom_minimum_size.x = 36
	hbox.add_child(label)

	var toggle: CheckButton = CheckButton.new()
	toggle.button_pressed = default_val
	hbox.add_child(toggle)

	return toggle

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
