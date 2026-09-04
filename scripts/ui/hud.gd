extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var gold_label: Label = $GoldLabel
@onready var death_screen: Control = $DeathScreen

var _floor_label: Label
var _mana_bar: ProgressBar = null
var _boss_bar: ProgressBar = null
var _boss_label: Label = null
var _boss_health_component: HealthComponent = null
var _vignette: ColorRect = null
var _vignette_tween: Tween = null
var _is_low_health: bool = false
var _damage_flash: ColorRect = null
var _damage_flash_tween: Tween = null
var _last_gold: int = 0

func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.floor_started.connect(_on_floor_started)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.mana_changed.connect(_on_mana_changed)
	EventBus.player_damaged_directional.connect(_on_player_damaged_directional)
	gold_label.text = "0"
	_create_ambient_vignette()
	_create_damage_flash()
	_create_ability_bar()
	_create_belt_slot()
	_create_buff_indicator()
	_create_floor_label()
	_create_minimap()
	_create_status_display()
	_create_vignette()
	_connect_to_player.call_deferred()

func _create_buff_indicator() -> void:
	var buff_indicator_script: Script = preload("res://scripts/ui/buff_indicator.gd")
	var indicator: Control = Control.new()
	indicator.set_script(buff_indicator_script)
	indicator.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	indicator.grow_horizontal = Control.GROW_DIRECTION_BOTH
	indicator.position.y = -42.0
	add_child(indicator)

## Bottom-left corner, clear of the centered ability bar.
func _create_belt_slot() -> void:
	var belt: Control = BeltSlot.new()
	belt.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	belt.grow_vertical = Control.GROW_DIRECTION_BEGIN
	belt.position = Vector2(4.0, -20.0)
	add_child(belt)

func _create_ability_bar() -> void:
	var ability_bar_script: Script = preload("res://scripts/ui/ability_bar.gd")
	var ability_bar: HBoxContainer = HBoxContainer.new()
	ability_bar.set_script(ability_bar_script)
	ability_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ability_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ability_bar.position.y = -28.0
	ability_bar.add_theme_constant_override("separation", 2)
	add_child(ability_bar)

func _connect_to_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player and player.has_node("HealthComponent"):
		var hc: HealthComponent = player.get_node("HealthComponent") as HealthComponent
		health_bar.max_value = hc.max_hp
		health_bar.value = hc.current_hp
		hc.health_changed.connect(_on_health_changed)
	if player and player.has_node("ManaComponent"):
		var mc: ManaComponent = player.get_node("ManaComponent") as ManaComponent
		_create_mana_bar(mc.current_mana, mc.max_mana)

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	_check_low_health(current_hp, max_hp)

## Constant, subtle dark edge vignette that frames the dungeon at all times.
func _create_ambient_vignette() -> void:
	var ambient: ColorRect = ColorRect.new()
	ambient.set_anchors_preset(Control.PRESET_FULL_RECT)
	ambient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = preload("res://shaders/vignette_dark.gdshader")
	ambient.material = mat
	add_child(ambient)
	move_child(ambient, 0)

func _create_vignette() -> void:
	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.modulate.a = 0.0
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = preload("res://shaders/vignette.gdshader")
	_vignette.material = mat
	add_child(_vignette)

func _check_low_health(current_hp: int, max_hp: int) -> void:
	if _vignette == null or max_hp <= 0:
		return
	var is_low: bool = float(current_hp) / float(max_hp) <= GameConfig.config.ui_low_health_threshold
	if is_low == _is_low_health:
		return
	_is_low_health = is_low
	# The heartbeat is the audio half of the same warning as the vignette.
	AudioManager.set_heartbeat(is_low, GameConfig.config.audio_heartbeat_rate)
	if _vignette_tween:
		_vignette_tween.kill()
	if is_low:
		_vignette_tween = create_tween().set_loops()
		var peak: float = GameConfig.config.ui_low_health_vignette_alpha
		var half: float = GameConfig.config.ui_low_health_pulse_duration / 2.0
		_vignette_tween.tween_property(_vignette, "modulate:a", peak, half)
		_vignette_tween.tween_property(_vignette, "modulate:a", 0.0, half)
	else:
		_vignette_tween = create_tween()
		_vignette_tween.tween_property(_vignette, "modulate:a", 0.0, 0.3)

func _on_gold_changed(new_amount: int) -> void:
	var gained: int = new_amount - _last_gold
	_last_gold = new_amount
	gold_label.text = str(new_amount)
	if gained > 0:
		_show_gold_popup(gained)

## Floating "+N" beside the counter, so a pickup registers without the player
## having to watch the number tick.
func _show_gold_popup(amount: int) -> void:
	var popup: Label = Label.new()
	popup.text = "+%d" % amount
	popup.add_theme_font_size_override("font_size", 6)
	popup.add_theme_color_override("font_color", GameConfig.config.ui_gold_popup_color)
	popup.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	popup.add_theme_constant_override("outline_size", 2)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Fixed offset rather than gold_label.size — the label has no measured size
	# on the frame the first pickup lands.
	popup.position = gold_label.position + Vector2(24.0, 0.0)
	add_child(popup)

	var duration: float = GameConfig.config.ui_gold_popup_duration
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - GameConfig.config.ui_gold_popup_rise, duration)
	tween.tween_property(popup, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(popup.queue_free)

## Full-screen overlay whose shader lights only the edge the hit came from.
func _create_damage_flash() -> void:
	_damage_flash = ColorRect.new()
	_damage_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = preload("res://shaders/directional_flash.gdshader")
	mat.set_shader_parameter("strength", 0.0)
	_damage_flash.material = mat
	add_child(_damage_flash)

func _on_player_damaged_directional(hit_direction: Vector2, _amount: int) -> void:
	if _damage_flash == null:
		return
	var mat: ShaderMaterial = _damage_flash.material as ShaderMaterial
	if mat == null:
		return
	if hit_direction == Vector2.ZERO:
		hit_direction = Vector2.DOWN
	mat.set_shader_parameter("flash_dir", hit_direction.normalized())
	mat.set_shader_parameter("flash_color", GameConfig.config.ui_damage_flash_color)
	mat.set_shader_parameter("band_width", GameConfig.config.ui_damage_flash_width)
	mat.set_shader_parameter("strength", GameConfig.config.ui_damage_flash_alpha)
	if _damage_flash_tween:
		_damage_flash_tween.kill()
	_damage_flash_tween = create_tween()
	_damage_flash_tween.tween_property(
		mat, "shader_parameter/strength", 0.0, GameConfig.config.ui_damage_flash_duration
	)

func _create_floor_label() -> void:
	_floor_label = Label.new()
	_floor_label.text = "Floor 1"
	_floor_label.add_theme_font_size_override("font_size", 6)
	_floor_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	_floor_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_floor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_floor_label.position.y = 2.0
	add_child(_floor_label)

func _create_minimap() -> void:
	var minimap_script: Script = preload("res://scripts/ui/minimap.gd")
	var minimap: Control = Control.new()
	minimap.set_script(minimap_script)
	minimap.position = Vector2(448, 8)
	minimap.custom_minimum_size = Vector2(24, 120)
	add_child(minimap)

func _create_status_display() -> void:
	var status_display_script: Script = preload("res://scripts/ui/status_effect_display.gd")
	var status_display: HBoxContainer = HBoxContainer.new()
	status_display.set_script(status_display_script)
	status_display.position = Vector2(68.0, 4.0)
	status_display.add_theme_constant_override("separation", 2)
	add_child(status_display)

func _on_floor_started(floor_number: int) -> void:
	var floor_title: String = ""
	var config: FloorConfig = DungeonManager.get_current_floor_config()
	if config:
		floor_title = config.floor_title
	if _floor_label:
		if floor_title != "":
			_floor_label.text = "Floor %d — %s" % [floor_number, floor_title]
		else:
			_floor_label.text = "Floor %d" % floor_number
	_show_banner("FLOOR %d" % floor_number, floor_title, Color(0.9, 0.8, 0.5))

## Big centered title + subtitle that fades in, holds, and fades out.
func _show_banner(title_text: String, subtitle_text: String, color: Color) -> void:
	var banner: VBoxContainer = VBoxContainer.new()
	banner.set_anchors_preset(Control.PRESET_CENTER)
	banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner.grow_vertical = Control.GROW_DIRECTION_BOTH
	banner.position.y = -40.0
	banner.alignment = BoxContainer.ALIGNMENT_CENTER
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var title: Label = Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", color)
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	title.add_theme_constant_override("outline_size", 3)
	banner.add_child(title)

	if subtitle_text != "":
		var subtitle: Label = Label.new()
		subtitle.text = subtitle_text
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle.add_theme_font_size_override("font_size", 7)
		subtitle.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		subtitle.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
		subtitle.add_theme_constant_override("outline_size", 2)
		banner.add_child(subtitle)

	banner.modulate.a = 0.0
	add_child(banner)
	var tween: Tween = create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.6)
	tween.tween_property(banner, "modulate:a", 0.0, 0.6)
	tween.tween_callback(banner.queue_free)

func _on_boss_fight_started(boss_name: String, health_comp: Node) -> void:
	_boss_health_component = health_comp as HealthComponent
	if _boss_health_component == null:
		return
	_boss_label = Label.new()
	_boss_label.text = boss_name
	_boss_label.add_theme_font_size_override("font_size", 6)
	_boss_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_label.position.y = 10.0
	add_child(_boss_label)
	_boss_bar = ProgressBar.new()
	_boss_bar.custom_minimum_size = Vector2(120, 6)
	_boss_bar.max_value = _boss_health_component.max_hp
	_boss_bar.value = _boss_health_component.current_hp
	_boss_bar.show_percentage = false
	_boss_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_bar.position = Vector2(-60.0, 18.0)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.7, 0.1, 0.1)
	_boss_bar.add_theme_stylebox_override("fill", style)
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15)
	_boss_bar.add_theme_stylebox_override("background", bg_style)
	add_child(_boss_bar)
	_boss_health_component.health_changed.connect(_on_boss_health_changed)

func _on_boss_health_changed(current_hp: int, max_hp: int) -> void:
	if _boss_bar:
		_boss_bar.max_value = max_hp
		_boss_bar.value = current_hp

func _on_boss_defeated(_boss_id: String) -> void:
	if _boss_health_component and _boss_health_component.health_changed.is_connected(_on_boss_health_changed):
		_boss_health_component.health_changed.disconnect(_on_boss_health_changed)
	_boss_health_component = null
	if _boss_bar:
		_boss_bar.queue_free()
		_boss_bar = null
	if _boss_label:
		_boss_label.queue_free()
		_boss_label = null
	if RunManager.current_floor >= RunManager.max_floors:
		_show_banner("DUNGEON CONQUERED!", "", Color(1.0, 0.85, 0.3))
	else:
		_show_banner("FLOOR CLEARED!", "Grab your loot — descending shortly...", Color(0.4, 0.9, 0.5))

func _on_item_picked_up(item_data: Resource) -> void:
	var item: ItemData = item_data as ItemData
	if item == null:
		return
	var notification: Label = Label.new()
	var verb: String = " added to belt!" if item.is_consumable() else " equipped!"
	notification.text = item.display_name + verb
	notification.add_theme_font_size_override("font_size", 7)
	notification.add_theme_color_override("font_color", Color(0.3, 0.85, 0.3))
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.set_anchors_preset(Control.PRESET_CENTER_TOP)
	notification.position.y = 24.0
	add_child(notification)
	var tween: Tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(notification, "modulate:a", 0.0, 0.5)
	tween.tween_callback(notification.queue_free)

func _create_mana_bar(current: int, max_mana: int) -> void:
	_mana_bar = ProgressBar.new()
	_mana_bar.custom_minimum_size = Vector2(60, 4)
	_mana_bar.max_value = max_mana
	_mana_bar.value = current
	_mana_bar.show_percentage = false
	_mana_bar.position = Vector2(4.0, 14.0)
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.3, 0.8)
	_mana_bar.add_theme_stylebox_override("fill", fill_style)
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.2)
	_mana_bar.add_theme_stylebox_override("background", bg_style)
	add_child(_mana_bar)

func _on_mana_changed(current_mana: int, max_mana: int) -> void:
	if _mana_bar:
		_mana_bar.max_value = max_mana
		_mana_bar.value = current_mana
