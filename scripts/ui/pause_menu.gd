extends CanvasLayer

var _is_paused: bool = false
var _panel: PanelContainer
var _vbox: VBoxContainer

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

func resume() -> void:
	_is_paused = false
	visible = false
	get_tree().paused = false

func _build_ui() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(120, 80)
	_panel.position = Vector2(-60, -40)
	add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(_vbox)

	var title: Label = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vbox.add_child(title)

	var resume_btn: Button = _create_button("Resume")
	resume_btn.pressed.connect(resume)
	_vbox.add_child(resume_btn)

	var restart_btn: Button = _create_button("Restart Run")
	restart_btn.pressed.connect(_on_restart_pressed)
	_vbox.add_child(restart_btn)

	var quit_btn: Button = _create_button("Quit to Title")
	quit_btn.pressed.connect(_on_quit_pressed)
	_vbox.add_child(quit_btn)

func _create_button(text: String) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 7)
	btn.custom_minimum_size = Vector2(100, 14)
	return btn

func _on_restart_pressed() -> void:
	resume()
	RunManager.end_run(false)
	GameManager.start_run()

func _on_quit_pressed() -> void:
	resume()
	RunManager.end_run(false)
	GameManager.return_to_title()
