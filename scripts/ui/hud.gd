extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var gold_label: Label = $GoldLabel

func _ready() -> void:
	EventBus.gold_changed.connect(_on_gold_changed)
	gold_label.text = "0"
	_connect_to_player.call_deferred()

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
