extends Control

const RARITY_COLORS: Dictionary = {
	0: Color(0.8, 0.8, 0.8),
	1: Color(0.3, 0.8, 0.3),
	2: Color(0.3, 0.5, 1.0),
	3: Color(1.0, 0.84, 0.0),
}
const RARITY_NAMES: Dictionary = {
	0: "Common",
	1: "Uncommon",
	2: "Rare",
	3: "Legendary",
}
const ITEM_DIRS: Array[String] = [
	"res://resources/items/weapons/",
	"res://resources/items/armor/",
	"res://resources/items/rings/",
	"res://resources/items/accessories/",
]

var _back_callback: Callable
var _currency_label: Label
var _tab_container: TabContainer
var _item_entries: Array[Dictionary] = []
var _passive_entries: Array[Dictionary] = []

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

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	vbox.add_child(header)

	var title: Label = Label.new()
	title.text = "UNLOCKS"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	header.add_child(title)

	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	_currency_label = Label.new()
	_currency_label.add_theme_font_size_override("font_size", 9)
	_currency_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9))
	header.add_child(_currency_label)

	var back_btn: Button = Button.new()
	back_btn.text = "Back"
	back_btn.add_theme_font_size_override("font_size", 8)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_tab_container)

	var all_items: Array[ItemData] = _load_all_items()
	_build_item_tab("Weapons", all_items, [ItemData.SlotType.WEAPON])
	_build_item_tab("Armor", all_items, [ItemData.SlotType.ARMOR])
	_build_item_tab("Rings & Accs", all_items, [ItemData.SlotType.RING, ItemData.SlotType.ACCESSORY])
	_build_passive_tab()

	back_btn.grab_focus()
	_update_currency_display()

func _on_back_pressed() -> void:
	if _back_callback.is_valid():
		_back_callback.call()
	queue_free()

func _update_currency_display() -> void:
	_currency_label.text = "Soul Gems: %d" % SaveManager.get_meta_currency()

func _refresh_all() -> void:
	_update_currency_display()
	for entry: Dictionary in _item_entries:
		_refresh_item_card(entry)
	for entry: Dictionary in _passive_entries:
		_refresh_passive_card(entry)

# =============================================================================
# ITEMS
# =============================================================================

func _load_all_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for dir_path: String in ITEM_DIRS:
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			continue
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item: ItemData = load(dir_path + file_name) as ItemData
				if item:
					result.append(item)
			file_name = dir.get_next()
		dir.list_dir_end()
	return result

func _build_item_tab(tab_name: String, all_items: Array[ItemData], slots: Array) -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = tab_name
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)

	var items: Array[ItemData] = []
	for item: ItemData in all_items:
		if item.slot_type in slots:
			items.append(item)
	items.sort_custom(func(a: ItemData, b: ItemData) -> bool: return a.rarity < b.rarity)

	for item: ItemData in items:
		grid.add_child(_build_item_card(item))

func _build_item_card(item: ItemData) -> PanelContainer:
	var rarity_color: Color = RARITY_COLORS.get(item.rarity as int, Color.WHITE)
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(125, 72)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.16)
	style.border_color = rarity_color
	style.set_border_width_all(1)
	style.set_content_margin_all(5)
	card.add_theme_stylebox_override("panel", style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	vbox.add_child(hbox)

	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(14, 14)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if item.icon:
		icon.texture = item.icon
	hbox.add_child(icon)

	var name_label: Label = Label.new()
	name_label.text = item.display_name
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.add_theme_color_override("font_color", rarity_color)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hbox.add_child(name_label)

	var rarity_label: Label = Label.new()
	rarity_label.text = RARITY_NAMES.get(item.rarity as int, "")
	rarity_label.add_theme_font_size_override("font_size", 6)
	rarity_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(rarity_label)

	var status_btn: Button = Button.new()
	status_btn.add_theme_font_size_override("font_size", 7)
	vbox.add_child(status_btn)

	var entry: Dictionary = {"item": item, "button": status_btn}
	_item_entries.append(entry)
	status_btn.pressed.connect(_on_item_buy_pressed.bind(entry))
	_refresh_item_card(entry)

	return card

func _refresh_item_card(entry: Dictionary) -> void:
	var item: ItemData = entry["item"]
	var btn: Button = entry["button"]
	if item.rarity == ItemData.Rarity.COMMON:
		btn.text = "Always Available"
		btn.disabled = true
		return
	if SaveManager.is_unlocked(item.item_id):
		btn.text = "Unlocked"
		btn.disabled = true
		return
	var cost: int = GameConfig.config.get_unlock_cost_for_rarity(item.rarity as int)
	btn.text = "Unlock (%d)" % cost
	btn.disabled = SaveManager.get_meta_currency() < cost

func _on_item_buy_pressed(entry: Dictionary) -> void:
	var item: ItemData = entry["item"]
	var cost: int = GameConfig.config.get_unlock_cost_for_rarity(item.rarity as int)
	if not SaveManager.spend_meta_currency(cost):
		return
	SaveManager.unlock_item(item.item_id)
	SaveManager.save()
	_refresh_all()

# =============================================================================
# PASSIVES
# =============================================================================

func _build_passive_tab() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "Passives"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	var groups: Dictionary = {}
	for upgrade: UnlockData in SaveManager.get_passive_upgrades():
		var key: String = _passive_group_key(upgrade.unlock_id)
		if not groups.has(key):
			groups[key] = []
		(groups[key] as Array).append(upgrade)

	var keys: Array = groups.keys()
	keys.sort()
	for key: String in keys:
		var levels_raw: Array = groups[key]
		levels_raw.sort_custom(func(a: UnlockData, b: UnlockData) -> bool: return a.passive_level < b.passive_level)
		var levels: Array[UnlockData] = []
		for l: Variant in levels_raw:
			levels.append(l as UnlockData)
		vbox.add_child(_build_passive_card(levels))

func _passive_group_key(unlock_id: StringName) -> String:
	var s: String = str(unlock_id)
	var parts: PackedStringArray = s.rsplit("_", true, 1)
	if parts.size() == 2 and parts[1].is_valid_int():
		return parts[0]
	return s

func _strip_roman_numeral(display_name: String) -> String:
	var suffixes: Array[String] = [" III", " II", " I"]
	for suf: String in suffixes:
		if display_name.ends_with(suf):
			return display_name.substr(0, display_name.length() - suf.length())
	return display_name

func _build_passive_card(levels: Array[UnlockData]) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.16)
	style.border_color = Color(0.4, 0.35, 0.5)
	style.set_border_width_all(1)
	style.set_content_margin_all(6)
	card.add_theme_stylebox_override("panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_row: HBoxContainer = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	info_vbox.add_child(name_row)

	var name_label: Label = Label.new()
	name_label.text = _strip_roman_numeral(levels[0].display_name)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	name_row.add_child(name_label)

	var dots_label: Label = Label.new()
	dots_label.add_theme_font_size_override("font_size", 8)
	dots_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9))
	name_row.add_child(dots_label)

	var desc_label: Label = Label.new()
	desc_label.add_theme_font_size_override("font_size", 7)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	info_vbox.add_child(desc_label)

	var buy_btn: Button = Button.new()
	buy_btn.add_theme_font_size_override("font_size", 7)
	buy_btn.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(buy_btn)

	var entry: Dictionary = {
		"levels": levels,
		"dots_label": dots_label,
		"desc_label": desc_label,
		"button": buy_btn,
	}
	_passive_entries.append(entry)
	buy_btn.pressed.connect(_on_passive_buy_pressed.bind(entry))
	_refresh_passive_card(entry)

	return card

func _get_unlocked_level(levels: Array[UnlockData]) -> int:
	var current_level: int = 0
	for lvl: UnlockData in levels:
		if SaveManager.is_unlocked(lvl.unlock_id):
			current_level = lvl.passive_level
	return current_level

func _refresh_passive_card(entry: Dictionary) -> void:
	var levels: Array[UnlockData] = entry["levels"]
	var current_level: int = _get_unlocked_level(levels)
	var max_level: int = levels[levels.size() - 1].passive_level

	var dots: String = ""
	for i: int in range(1, max_level + 1):
		dots += "●" if i <= current_level else "○"
	entry["dots_label"].text = dots

	if current_level >= max_level:
		entry["desc_label"].text = levels[0].description
		entry["button"].text = "Maxed"
		entry["button"].disabled = true
		return

	var next_upgrade: UnlockData = levels[current_level]
	entry["desc_label"].text = next_upgrade.description
	entry["button"].text = "Upgrade (%d)" % next_upgrade.cost
	entry["button"].disabled = SaveManager.get_meta_currency() < next_upgrade.cost

func _on_passive_buy_pressed(entry: Dictionary) -> void:
	var levels: Array[UnlockData] = entry["levels"]
	var current_level: int = _get_unlocked_level(levels)
	var max_level: int = levels[levels.size() - 1].passive_level
	if current_level >= max_level:
		return
	var next_upgrade: UnlockData = levels[current_level]
	if not SaveManager.spend_meta_currency(next_upgrade.cost):
		return
	SaveManager.unlock_passive(next_upgrade.unlock_id)
	SaveManager.save()
	_refresh_all()
