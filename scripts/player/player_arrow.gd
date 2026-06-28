extends Hitbox

var speed: float:
	get: return GameConfig.config.player_arrow_speed
var lifetime: float:
	get: return GameConfig.config.player_arrow_lifetime

var _direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0
var _hit: bool = false

func setup(direction: Vector2, base_damage: int) -> void:
	_direction = direction.normalized()
	damage = base_damage
	rotation = _direction.angle()

func _ready() -> void:
	super._ready()
	activate()

func _physics_process(delta: float) -> void:
	if _hit:
		return
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
	_hit = true
	VFXHelper.spawn_hit_sparks(global_position)
	queue_free()
