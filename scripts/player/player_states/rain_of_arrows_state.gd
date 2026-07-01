extends AbilityState

var _rain_position: Vector2 = Vector2.ZERO
var _rain_timer: float = 0.0
var _has_rained: bool = false
var _rain_hitbox: Hitbox = null

func enter() -> void:
	super.enter()
	_rain_position = player.get_global_mouse_position()
	_rain_timer = _ability_data.rain_delay
	_has_rained = false
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.animated_sprite.play(&"rain_of_arrows")
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	super.exit()
	_destroy_rain_hitbox()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()
	if not _has_rained:
		_rain_timer -= delta
		if _rain_timer <= 0.0:
			_create_rain_zone()
			_has_rained = true

func _create_rain_zone() -> void:
	_rain_hitbox = Hitbox.new()
	_rain_hitbox.damage = player.get_ability_damage(_ability_data.damage)
	_rain_hitbox.knockback_force = _ability_data.knockback_force
	_rain_hitbox.collision_layer = 32
	_rain_hitbox.collision_mask = 16
	_rain_hitbox.monitoring = true
	_rain_hitbox.monitorable = false
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = _ability_data.aoe_radius
	shape.shape = circle
	_rain_hitbox.add_child(shape)
	_rain_hitbox.global_position = _rain_position
	player.get_parent().add_child(_rain_hitbox)
	_rain_hitbox.activate()
	var timer: SceneTreeTimer = player.get_tree().create_timer(_ability_data.rain_duration)
	timer.timeout.connect(_destroy_rain_hitbox)

func _destroy_rain_hitbox() -> void:
	if is_instance_valid(_rain_hitbox):
		_rain_hitbox.deactivate()
		_rain_hitbox.queue_free()
		_rain_hitbox = null

func _on_animation_finished() -> void:
	_transition_to_idle()
