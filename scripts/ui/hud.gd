extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var gold_label: Label = $GoldLabel
@onready var death_screen: Control = $DeathScreen

func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	gold_label.text = "0"
	_create_ability_bar()
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
