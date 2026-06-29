extends Control

var _main_vbox: VBoxContainer
var _class_select_container: Control

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

	_main_vbox = VBoxContainer.new()
	_main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_main_vbox.add_theme_constant_override("separation", 10)
	center.add_child(_main_vbox)

	var title: Label = Label.new()
	title.text = "DUNGEON DESCENT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	_main_vbox.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "A Roguelike Dungeon Crawler"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 6)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	_main_vbox.add_child(subtitle)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	_main_vbox.add_child(spacer)

	var new_run_btn: Button = Button.new()
	new_run_btn.text = "New Run"
	new_run_btn.add_theme_font_size_override("font_size", 8)
	new_run_btn.pressed.connect(_on_new_run_pressed)
	_main_vbox.add_child(new_run_btn)

	var unlocks_btn: Button = Button.new()
	unlocks_btn.text = "Unlocks"
	unlocks_btn.add_theme_font_size_override("font_size", 8)
	unlocks_btn.pressed.connect(_on_unlocks_pressed)
	_main_vbox.add_child(unlocks_btn)

	var quit_btn: Button = Button.new()
	quit_btn.text = "Quit"
	quit_btn.add_theme_font_size_override("font_size", 8)
	quit_btn.pressed.connect(_on_quit_pressed)
	_main_vbox.add_child(quit_btn)

	new_run_btn.grab_focus()

func _on_new_run_pressed() -> void:
	_show_class_selection()

func _on_unlocks_pressed() -> void:
	var unlocks_scene: PackedScene = load("res://scenes/ui/unlocks_screen.tscn") as PackedScene
	var unlocks: Control = unlocks_scene.instantiate() as Control
	unlocks.set_back_callback(func() -> void: visible = true)
	get_parent().add_child(unlocks)
	visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _show_class_selection() -> void:
	_main_vbox.visible = false

	_class_select_container = Control.new()
	_class_select_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_class_select_container)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_class_select_container.add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	var header: Label = Label.new()
	header.text = "CHOOSE YOUR CLASS"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 10)
	header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	vbox.add_child(header)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer)

	var classes_hbox: HBoxContainer = HBoxContainer.new()
	classes_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	classes_hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(classes_hbox)

	var warrior_btn: Button = _create_class_button(
		"Warrior",
		"Melee fighter with\nhigh HP and armor.",
		"HP: 10  DMG: 3\nSPD: 120  DEF: 0",
		Color(0.8, 0.3, 0.2),
	)
	warrior_btn.pressed.connect(func() -> void:
		GameManager.start_run(GameManager.PlayerClass.WARRIOR))
	classes_hbox.add_child(warrior_btn)

	var ranger_btn: Button = _create_class_button(
		"Ranger",
		"Ranged archer with\nfast movement.",
		"HP: 8  DMG: 2\nSPD: 130  CRIT: 5%",
		Color(0.2, 0.7, 0.3),
	)
	ranger_btn.pressed.connect(func() -> void:
		GameManager.start_run(GameManager.PlayerClass.RANGER))
	classes_hbox.add_child(ranger_btn)

	var mage_btn: Button = _create_class_button(
		"Mage",
		"Ranged spellcaster with\nmana and AoE spells.",
		"HP: 7  DMG: 4\nSPD: 110  MANA: 50",
		Color(0.7, 0.2, 0.2),
	)
	mage_btn.pressed.connect(func() -> void:
		GameManager.start_run(GameManager.PlayerClass.MAGE))
	classes_hbox.add_child(mage_btn)

	var spacer2: Control = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(spacer2)

	var back_btn: Button = Button.new()
	back_btn.text = "Back"
	back_btn.add_theme_font_size_override("font_size", 7)
	back_btn.pressed.connect(_on_back_from_class_select)
	vbox.add_child(back_btn)

	warrior_btn.grab_focus()

func _create_class_button(class_name_text: String, desc: String, stats: String, color: Color) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(90, 60)
	btn.add_theme_font_size_override("font_size", 6)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	var name_label: Label = Label.new()
	name_label.text = class_name_text
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.add_theme_color_override("font_color", color)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = desc
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 5)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_label)

	var stats_label: Label = Label.new()
	stats_label.text = stats
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 5)
	stats_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stats_label)

	return btn

func _on_back_from_class_select() -> void:
	if _class_select_container:
		_class_select_container.queue_free()
		_class_select_container = null
	_main_vbox.visible = true
