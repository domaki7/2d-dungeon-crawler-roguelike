extends Control

func _ready() -> void:
	size = get_viewport().get_visible_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	center.add_child(vbox)

	var title: Label = Label.new()
	title.text = "DUNGEON DESCENT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	vbox.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "A Roguelike Dungeon Crawler"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 6)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(subtitle)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var new_run_btn: Button = Button.new()
	new_run_btn.text = "New Run"
	new_run_btn.add_theme_font_size_override("font_size", 8)
	new_run_btn.pressed.connect(_on_new_run_pressed)
	vbox.add_child(new_run_btn)

	var unlocks_btn: Button = Button.new()
	unlocks_btn.text = "Unlocks"
	unlocks_btn.add_theme_font_size_override("font_size", 8)
	unlocks_btn.pressed.connect(_on_unlocks_pressed)
	vbox.add_child(unlocks_btn)

	var quit_btn: Button = Button.new()
	quit_btn.text = "Quit"
	quit_btn.add_theme_font_size_override("font_size", 8)
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)

	new_run_btn.grab_focus()

func _on_new_run_pressed() -> void:
	GameManager.start_run()

func _on_unlocks_pressed() -> void:
	var unlocks_scene: PackedScene = load("res://scenes/ui/unlocks_screen.tscn") as PackedScene
	var unlocks: Control = unlocks_scene.instantiate() as Control
	unlocks.set_back_callback(func() -> void: visible = true)
	get_parent().add_child(unlocks)
	visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
