class_name FloorExit
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var _is_active: bool = false

func _ready() -> void:
	collision_layer = 256
	collision_mask = 2
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	visible = false
	set_deferred("monitoring", false)

func activate() -> void:
	_is_active = true
	visible = true
	set_deferred("monitoring", true)

func _on_body_entered(body: Node2D) -> void:
	if _is_active and body.is_in_group(&"player"):
		_is_active = false
		set_deferred("monitoring", false)
		EventBus.floor_completed.emit(DungeonManager.get_current_floor_number())
