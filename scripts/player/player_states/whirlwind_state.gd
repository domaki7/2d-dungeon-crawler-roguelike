extends AbilityState

var _whirlwind_hitbox: Hitbox = null

func enter() -> void:
	super.enter()
	player.animated_sprite.play(&"whirlwind")
	_create_aoe_hitbox()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	_destroy_aoe_hitbox()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _create_aoe_hitbox() -> void:
	_whirlwind_hitbox = Hitbox.new()
	_whirlwind_hitbox.damage = player.get_ability_damage(_ability_data.damage)
	_whirlwind_hitbox.knockback_force = _ability_data.knockback_force
	_whirlwind_hitbox.collision_layer = 32
	_whirlwind_hitbox.collision_mask = 16
	_whirlwind_hitbox.monitoring = true
	_whirlwind_hitbox.monitorable = false
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = _ability_data.aoe_radius
	shape.shape = circle
	_whirlwind_hitbox.add_child(shape)
	player.add_child(_whirlwind_hitbox)
	_whirlwind_hitbox.position = Vector2.ZERO
	_whirlwind_hitbox.activate()

func _destroy_aoe_hitbox() -> void:
	if is_instance_valid(_whirlwind_hitbox):
		_whirlwind_hitbox.deactivate()
		_whirlwind_hitbox.queue_free()
		_whirlwind_hitbox = null

func _on_animation_finished() -> void:
	_transition_to_idle()
