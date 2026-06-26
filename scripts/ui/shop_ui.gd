extends CanvasLayer

const RARITY_COLORS: Dictionary = {
	0: Color(0.8, 0.8, 0.8),
	1: Color(0.3, 0.8, 0.3),
	2: Color(0.3, 0.5, 1.0),
}

var _is_open: bool = false
var _player_stats: PlayerStats = null
var _player_ref: CharacterBody2D = null
var _shop_items: Array[ItemData] = []
var _item_rows: Array[HBoxContainer] = []
var _buy_buttons: Array[Button] = []
var _gold_label: Label
var _items_container: VBoxContainer
var _panel: PanelContainer
var _selected_index: int = 0
var _tooltip_name: Label
var _tooltip_stats: Label
var _tooltip_effect: Label

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	EventBus.shop_opened.connect(_on_shop_opened)
	_build_ui()
	_connect_to_player.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"pause"):
		_close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"move_up"):
		_select_item((_selected_index - 1 + _shop_items.size()) % _shop_items.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"move_down"):
		_select_item((_selected_index + 1) % _shop_items.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"attack"):
		_buy_selected()
		get_viewport().set_input_as_handled()

func _connect_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player:
		_player_ref = player as CharacterBody2D
		if player.has_node("PlayerStats"):
			_player_stats = player.get_node("PlayerStats") as PlayerStats

func _on_shop_opened(items: Array) -> void:
	_shop_items.clear()
	for item: Variant in items:
		if item is ItemData:
			_shop_items.append(item as ItemData)
	_open()

func _open() -> void:
	_is_open = true
	visible = true
	get_tree().paused = true
	_refresh_items()
	if not _shop_items.is_empty():
		_select_item(0)

func _close() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false
	EventBus.shop_closed.emit()

func _build_ui() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(220, 190)
	_panel.position = Vector2(-110, -95)
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.08, 0.15, 0.95)
	panel_style.border_color = Color(0.5, 0.4, 0.2)
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 3)
	_panel.add_child(main_vbox)

	var title: Label = Label.new()
	title.text = "SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	main_vbox.add_child(title)

	var sep1: HSeparator = HSeparator.new()
	main_vbox.add_child(sep1)

	_items_container = VBoxContainer.new()
	_items_container.add_theme_constant_override("separation", 2)
	main_vbox.add_child(_items_container)

	var sep2: HSeparator = HSeparator.new()
	main_vbox.add_child(sep2)

	var tooltip_panel: PanelContainer = PanelContainer.new()
	var tp_style: StyleBoxFlat = StyleBoxFlat.new()
	tp_style.bg_color = Color(0.08, 0.06, 0.12)
	tp_style.set_content_margin_all(4)
	tooltip_panel.add_theme_stylebox_override("panel", tp_style)
	tooltip_panel.custom_minimum_size.y = 36
	main_vbox.add_child(tooltip_panel)

	var tooltip_vbox: VBoxContainer = VBoxContainer.new()
	tooltip_vbox.add_theme_constant_override("separation", 1)
	tooltip_panel.add_child(tooltip_vbox)

	_tooltip_name = Label.new()
	_tooltip_name.add_theme_font_size_override("font_size", 8)
	tooltip_vbox.add_child(_tooltip_name)

	_tooltip_stats = Label.new()
	_tooltip_stats.add_theme_font_size_override("font_size", 7)
	_tooltip_stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	tooltip_vbox.add_child(_tooltip_stats)

	_tooltip_effect = Label.new()
	_tooltip_effect.add_theme_font_size_override("font_size", 7)
	_tooltip_effect.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	tooltip_vbox.add_child(_tooltip_effect)

	var sep3: HSeparator = HSeparator.new()
	main_vbox.add_child(sep3)

	var bottom_hbox: HBoxContainer = HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(bottom_hbox)

	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 8)
	_gold_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_gold_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(_gold_label)

	var hint_label: Label = Label.new()
	hint_label.text = "LMB: Buy  F: Close"
	hint_label.add_theme_font_size_override("font_size", 6)
	hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	bottom_hbox.add_child(hint_label)

func _refresh_items() -> void:
	for child: Node in _items_container.get_children():
		child.queue_free()
	_item_rows.clear()
	_buy_buttons.clear()

	if _player_ref:
		_gold_label.text = "Gold: %d" % _player_ref.gold

	for i: int in range(_shop_items.size()):
		var item: ItemData = _shop_items[i]
		var row_panel: PanelContainer = PanelContainer.new()
		var row_style: StyleBoxFlat = StyleBoxFlat.new()
		row_style.bg_color = Color(0.15, 0.12, 0.2)
		row_style.border_color = Color(0.3, 0.25, 0.4)
		row_style.set_border_width_all(1)
		row_style.set_content_margin_all(2)
		row_panel.add_theme_stylebox_override("panel", row_style)
		_items_container.add_child(row_panel)

		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 4)
		row_panel.add_child(hbox)
		_item_rows.append(hbox)

		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = Vector2(12, 12)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if item.icon:
			icon.texture = item.icon
		hbox.add_child(icon)

		var name_label: Label = Label.new()
		name_label.text = item.display_name
		name_label.add_theme_font_size_override("font_size", 7)
		var rarity_color: Color = RARITY_COLORS.get(item.rarity as int, Color.WHITE)
		name_label.add_theme_color_override("font_color", rarity_color)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(name_label)

		var price_label: Label = Label.new()
		price_label.text = "%dg" % item.buy_price
		price_label.add_theme_font_size_override("font_size", 7)
		var can_afford: bool = _player_ref != null and _player_ref.gold >= item.buy_price
		price_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0) if can_afford else Color(0.5, 0.3, 0.3))
		hbox.add_child(price_label)

func _select_item(index: int) -> void:
	if _shop_items.is_empty():
		return
	_selected_index = clampi(index, 0, _shop_items.size() - 1)
	for i: int in range(_items_container.get_child_count()):
		var panel: PanelContainer = _items_container.get_child(i) as PanelContainer
		if panel:
			var style: StyleBoxFlat = panel.get_theme_stylebox("panel") as StyleBoxFlat
			if i == _selected_index:
				style.border_color = Color(0.8, 0.7, 0.3)
			else:
				style.border_color = Color(0.3, 0.25, 0.4)
	_update_tooltip()

func _update_tooltip() -> void:
	if _selected_index >= _shop_items.size():
		return
	var item: ItemData = _shop_items[_selected_index]
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

func _buy_selected() -> void:
	if _selected_index >= _shop_items.size():
		return
	if _player_ref == null or _player_stats == null:
		return
	var item: ItemData = _shop_items[_selected_index]
	if _player_ref.gold < item.buy_price:
		return
	_player_ref.gold -= item.buy_price
	EventBus.gold_changed.emit(_player_ref.gold)
	var old_item: ItemData = _player_stats.equip(item)
	EventBus.item_picked_up.emit(item)
	if old_item:
		_player_ref.gold += old_item.sell_price
		EventBus.gold_changed.emit(_player_ref.gold)
	_refresh_items()
	if not _shop_items.is_empty():
		_select_item(_selected_index)
