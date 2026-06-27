extends AbilityState

@export var hitbox_offset: float = 8.0

var _dash_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	_dash_timer = _ability_data.dash_duration
	_dash_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_dash_direction)
	player.play_directional_animation("shield_bash")
	_setup_hitbox()
	player.hitbox.activate()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	player.hitbox.deactivate()
	player.hitbox.position = Vector2.ZERO
	player.hitbox.stun_duration = 0.0
	player.hitbox.damage = player.player_stats.get_effective_damage()
	player.hitbox.knockback_force = player.player_stats.get_effective_knockback_force()
	player.velocity = Vector2.ZERO
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	if _dash_timer > 0.0:
		player.velocity = _dash_direction * _ability_data.dash_speed
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			player.velocity = Vector2.ZERO
			player.hitbox.deactivate()
	else:
		player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _setup_hitbox() -> void:
	player.hitbox.damage = player.get_ability_damage(_ability_data.damage)
	player.hitbox.knockback_force = _ability_data.knockback_force
	player.hitbox.stun_duration = _ability_data.stun_duration
	player.hitbox.position = _dash_direction * hitbox_offset

func _on_animation_finished() -> void:
	_transition_to_idle()
