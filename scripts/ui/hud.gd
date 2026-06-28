extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var gold_label: Label = $GoldLabel
@onready var death_screen: Control = $DeathScreen

var _floor_label: Label
var _boss_bar: ProgressBar = null
var _boss_label: Label = null
var _boss_health_component: HealthComponent = null

func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.floor_started.connect(_on_floor_started)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	gold_label.text = "0"
	_create_ability_bar()
	_create_floor_label()
	_create_minimap()
	_create_status_display()
	_connect_to_player.call_deferred()

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

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = str(new_amount)

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
	if _floor_label:
		_floor_label.text = "Floor %d" % floor_number

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

func _on_item_picked_up(item_data: Resource) -> void:
	var item: ItemData = item_data as ItemData
	if item == null:
		return
	var notification: Label = Label.new()
	notification.text = item.display_name + " equipped!"
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
