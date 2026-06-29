extends Node2D

var _hitbox: Hitbox
var _tick_timer: float = 0.0
var _lifetime_timer: float = 0.0
var _tick_interval: float = 0.5
var _duration: float = 3.0

func setup(dmg: int, knockback: float, wall_length: float, wall_width: float, duration: float, tick_interval: float, burn_effect: StatusEffectData) -> void:
	_duration = duration
	_tick_interval = tick_interval
	_hitbox = Hitbox.new()
	_hitbox.damage = dmg
	_hitbox.knockback_force = knockback
	_hitbox.collision_layer = 32
	_hitbox.collision_mask = 16
	_hitbox.monitoring = true
	_hitbox.monitorable = false
	if burn_effect:
		_hitbox.applied_status_effect = burn_effect
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(wall_length, wall_width)
	shape.shape = rect
	_hitbox.add_child(shape)
	add_child(_hitbox)
	_hitbox.activate()

func _process(delta: float) -> void:
	_lifetime_timer += delta
	if _lifetime_timer >= _duration:
		queue_free()
		return
	_tick_timer += delta
	if _tick_timer >= _tick_interval:
		_tick_timer -= _tick_interval
		if _hitbox:
			_hitbox.deactivate()
			_hitbox.activate()
