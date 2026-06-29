extends Hitbox

var speed: float:
	get: return GameConfig.config.mage_ice_shard_speed
var lifetime: float:
	get: return GameConfig.config.mage_ice_shard_lifetime

var _direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0

func setup(direction: Vector2, base_damage: int, slow_effect: StatusEffectData) -> void:
	_direction = direction.normalized()
	damage = base_damage
	rotation = _direction.angle()
	applied_status_effect = slow_effect

func _ready() -> void:
	super._ready()
	activate()

func _physics_process(delta: float) -> void:
	position += _direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var hurtbox: Hurtbox = area as Hurtbox
	if hurtbox == null:
		return
	if has_hit(hurtbox.get_parent()):
		return
	register_hit(hurtbox.get_parent())
	hurtbox.receive_hit(self)
	hit_landed.emit(hurtbox)
	VFXHelper.spawn_hit_sparks(global_position)
