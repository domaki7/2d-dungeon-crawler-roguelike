extends CanvasLayer

const SLOT_NAMES: Array[String] = ["Weapon", "Armor", "Ring", "Accessory"]
const SLOT_TYPES: Array[int] = [0, 1, 2, 3]
const RARITY_COLORS: Dictionary = {
	0: Color(0.8, 0.8, 0.8),
	1: Color(0.3, 0.8, 0.3),
	2: Color(0.3, 0.5, 1.0),
}

var _is_open: bool = false
var _player_stats: PlayerStats = null
var _selected_index: int = 0
var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[TextureRect] = []
var _slot_labels: Array[Label] = []
var _tooltip_name: Label
var _tooltip_stats: Label
var _tooltip_effect: Label
var _panel: PanelContainer

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()
	_connect_to_player.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_inventory"):
		toggle()
		get_viewport().set_input_as_handled()
		return
	if not _is_open:
		return
	if event.is_action_pressed(&"move_up"):
		_select_slot((_selected_index - 1 + SLOT_NAMES.size()) % SLOT_NAMES.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"move_down"):
		_select_slot((_selected_index + 1) % SLOT_NAMES.size())
		get_viewport().set_input_as_handled()

func toggle() -> void:
	_is_open = not _is_open
	visible = _is_open
	get_tree().paused = _is_open
	if _is_open:
		_refresh_slots()
		_select_slot(0)

func _connect_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player and player.has_node("PlayerStats"):
		_player_stats = player.get_node("PlayerStats") as PlayerStats
		_player_stats.equipment_changed.connect(_on_equipment_changed)

func _build_ui() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(200, 180)
	_panel.position = Vector2(-100, -90)
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.08, 0.15, 0.95)
	panel_style.border_color = Color(0.4, 0.35, 0.5)
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(main_vbox)

	var title: Label = Label.new()
	title.text = "EQUIPMENT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	main_vbox.add_child(title)

	var sep1: HSeparator = HSeparator.new()
	main_vbox.add_child(sep1)

	for i: int in range(SLOT_NAMES.size()):
		var slot_panel: PanelContainer = PanelContainer.new()
		var slot_style: StyleBoxFlat = StyleBoxFlat.new()
		slot_style.bg_color = Color(0.15, 0.12, 0.2)
		slot_style.border_color = Color(0.3, 0.25, 0.4)
		slot_style.set_border_width_all(1)
		slot_style.set_content_margin_all(3)
		slot_panel.add_theme_stylebox_override("panel", slot_style)
		main_vbox.add_child(slot_panel)
		_slot_panels.append(slot_panel)

		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 4)
		slot_panel.add_child(hbox)

		var slot_label: Label = Label.new()
		slot_label.text = SLOT_NAMES[i] + ":"
		slot_label.add_theme_font_size_override("font_size", 7)
		slot_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.7))
		slot_label.custom_minimum_size.x = 48
		hbox.add_child(slot_label)

		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = Vector2(12, 12)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hbox.add_child(icon)
		_slot_icons.append(icon)

		var item_label: Label = Label.new()
		item_label.text = "Empty"
		item_label.add_theme_font_size_override("font_size", 7)
		item_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(item_label)
		_slot_labels.append(item_label)

	var sep2: HSeparator = HSeparator.new()
	main_vbox.add_child(sep2)

	var tooltip_panel: PanelContainer = PanelContainer.new()
	var tp_style: StyleBoxFlat = StyleBoxFlat.new()
	tp_style.bg_color = Color(0.08, 0.06, 0.12)
	tp_style.set_content_margin_all(4)
	tooltip_panel.add_theme_stylebox_override("panel", tp_style)
	tooltip_panel.custom_minimum_size.y = 40
	main_vbox.add_child(tooltip_panel)

	var tooltip_vbox: VBoxContainer = VBoxContainer.new()
	tooltip_vbox.add_theme_constant_override("separation", 2)
	tooltip_panel.add_child(tooltip_vbox)

	_tooltip_name = Label.new()
	_tooltip_name.add_theme_font_size_override("font_size", 8)
	_tooltip_name.add_theme_color_override("font_color", Color.WHITE)
	tooltip_vbox.add_child(_tooltip_name)

	_tooltip_stats = Label.new()
	_tooltip_stats.add_theme_font_size_override("font_size", 7)
	_tooltip_stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	tooltip_vbox.add_child(_tooltip_stats)

	_tooltip_effect = Label.new()
	_tooltip_effect.add_theme_font_size_override("font_size", 7)
	_tooltip_effect.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	tooltip_vbox.add_child(_tooltip_effect)

func _refresh_slots() -> void:
	if _player_stats == null:
		return
	for i: int in range(SLOT_NAMES.size()):
		var item: ItemData = _player_stats.get_equipped(SLOT_TYPES[i] as ItemData.SlotType)
		if item:
			_slot_icons[i].texture = item.icon
			_slot_labels[i].text = item.display_name
			var rarity_color: Color = RARITY_COLORS.get(item.rarity as int, Color.WHITE)
			_slot_labels[i].add_theme_color_override("font_color", rarity_color)
		else:
			_slot_icons[i].texture = null
			_slot_labels[i].text = "Empty"
			_slot_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _select_slot(index: int) -> void:
	for i: int in range(_slot_panels.size()):
		var style: StyleBoxFlat = _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
		if i == index:
			style.border_color = Color(0.8, 0.7, 0.3)
		else:
			style.border_color = Color(0.3, 0.25, 0.4)
	_selected_index = index
	_update_tooltip()

func _update_tooltip() -> void:
	if _player_stats == null:
		return
	var item: ItemData = _player_stats.get_equipped(SLOT_TYPES[_selected_index] as ItemData.SlotType)
	if item == null:
		_tooltip_name.text = SLOT_NAMES[_selected_index] + " - Empty"
		_tooltip_stats.text = "No item equipped"
		_tooltip_effect.text = ""
		return
	var rarity_color: Color = RARITY_COLORS.get(item.rarity as int, Color.WHITE)
	_tooltip_name.add_theme_color_override("font_color", rarity_color)
	_tooltip_name.text = item.display_name
	var stats_parts: Array[String] = []
	if item.bonus_damage != 0:
		stats_parts.append("+%d Damage" % item.bonus_damage)
	if item.bonus_defense != 0:
		stats_parts.append("+%d Defense" % item.bonus_defense)
	if item.bonus_max_hp != 0:
		stats_parts.append("+%d Max HP" % item.bonus_max_hp)
	if item.bonus_speed != 0.0:
		stats_parts.append("+%.0f Speed" % item.bonus_speed)
	if item.bonus_knockback_force != 0.0:
		stats_parts.append("+%.0f Knockback" % item.bonus_knockback_force)
	if item.bonus_crit_chance != 0.0:
		stats_parts.append("+%.0f%% Crit" % (item.bonus_crit_chance * 100.0))
	_tooltip_stats.text = ", ".join(stats_parts) if not stats_parts.is_empty() else "No stat bonuses"
	if item.effect_id != &"":
		_tooltip_effect.text = item.description
	else:
		_tooltip_effect.text = ""

func _on_equipment_changed(_slot_type: int, _item_data: ItemData) -> void:
	if _is_open:
		_refresh_slots()
		_update_tooltip()
