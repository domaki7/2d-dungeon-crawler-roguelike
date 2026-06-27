class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 1
@export var knockback_force: float = 200.0
@export var crit_chance: float = 0.0
@export var stun_duration: float = 0.0

var _hit_targets: Array[Node] = []

func _ready() -> void:
	monitoring = true
	monitorable = false
	for child: Node in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = true
	area_entered.connect(_on_area_entered)

func activate() -> void:
	_hit_targets.clear()
	for child: Node in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = false

func deactivate() -> void:
	for child: Node in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = true
	_hit_targets.clear()

func has_hit(target: Node) -> bool:
	return target in _hit_targets

func register_hit(target: Node) -> void:
	_hit_targets.append(target)

func _on_area_entered(area: Area2D) -> void:
	var hurtbox: Hurtbox = area as Hurtbox
	if hurtbox == null:
		return
	if has_hit(hurtbox.get_parent()):
		return
	register_hit(hurtbox.get_parent())
	hurtbox.receive_hit(self)
	hit_landed.emit(hurtbox)
