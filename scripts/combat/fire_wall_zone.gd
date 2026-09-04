extends Node2D

## A lingering strip of flame that re-damages everything standing in it on a
## fixed interval and leaves BURN behind.

@onready var _particles: GPUParticles2D = $Particles

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
	_fit_particles_to(wall_length, wall_width)

## The flames have to cover exactly the strip that deals damage, otherwise the
## player cannot tell where the wall actually is.
func _fit_particles_to(wall_length: float, wall_width: float) -> void:
	if _particles == null:
		return
	var material: ParticleProcessMaterial = _particles.process_material as ParticleProcessMaterial
	if material == null:
		return
	material = material.duplicate() as ParticleProcessMaterial
	material.emission_box_extents = Vector3(wall_length / 2.0, wall_width / 2.0, 0.0)
	_particles.process_material = material
	_particles.amount = maxi(8, int(wall_length / 3.0))
	_particles.lifetime = 0.6

func _process(delta: float) -> void:
	_lifetime_timer += delta
	if _lifetime_timer >= _duration:
		_fade_out()
		return
	_tick_timer += delta
	if _tick_timer >= _tick_interval:
		_tick_timer -= _tick_interval
		if _hitbox:
			_hitbox.refresh_targets()

## Stop dealing damage immediately, then let the last particles burn down so
## the wall does not vanish mid-flame.
func _fade_out() -> void:
	set_process(false)
	if _hitbox:
		_hitbox.deactivate()
	if _particles:
		_particles.emitting = false
		var timer: SceneTreeTimer = get_tree().create_timer(_particles.lifetime)
		timer.timeout.connect(queue_free)
	else:
		queue_free()
