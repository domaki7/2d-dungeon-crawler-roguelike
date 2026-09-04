class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 1
@export var knockback_force: float = 200.0
@export var crit_chance: float = 0.0
@export var applied_status_effect: StatusEffectData = null

@export_group("Hit Feedback")
@export var screen_shake_intensity: float = -1.0
@export var screen_shake_duration: float = -1.0
@export var hit_pause_duration: float = -1.0

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

## Clears the hit memory and immediately re-damages everything still inside
## the shape, for zones that deal damage on an interval rather than in one
## swing. Toggling the collision shape off and on across a frame also
## re-triggers `area_entered` (the shape is removed from and re-added to the
## physics server), but this makes the re-tick explicit, lands the damage on
## the caller's own tick instead of the next physics step, and does not
## depend on that side effect.
func refresh_targets() -> void:
	_hit_targets.clear()
	for area: Area2D in get_overlapping_areas():
		var hurtbox: Hurtbox = area as Hurtbox
		if hurtbox == null:
			continue
		register_hit(hurtbox.get_parent())
		hurtbox.receive_hit(self)
		hit_landed.emit(hurtbox)

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
