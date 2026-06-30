extends PlayerState

enum Phase { CHARGING, FIRING }

var charge_duration: float:
	get: return GameConfig.config.ranger_charged_shot_duration
var move_fraction: float:
	get: return GameConfig.config.ranger_quickdraw_move_fraction
var chain_window: float:
	get: return GameConfig.config.ranger_chain_shot_window
var max_chain: int:
	get: return GameConfig.config.ranger_chain_shot_max_count
var speed_bonus_per_step: float:
	get: return GameConfig.config.ranger_chain_shot_speed_bonus_per_step

var _phase: int = Phase.CHARGING
var _charge_timer: float = 0.0
var _attack_direction: Vector2 = Vector2.ZERO
var _original_modulate: Color = Color.WHITE
var _current_chain: int = 0

func enter() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if player.chain_shot_count > 0 and now < player.chain_shot_deadline:
		_current_chain = mini(player.chain_shot_count, max_chain)
	else:
		_current_chain = 0
		player.chain_shot_count = 0

	_phase = Phase.CHARGING
	_charge_timer = 0.0
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.play_directional_animation("shoot")
	player.animated_sprite.pause()
	_original_modulate = player.animated_sprite.modulate

	var chain_speed_scale: float = 1.0 + speed_bonus_per_step * float(_current_chain)
	player.animated_sprite.speed_scale = chain_speed_scale

func exit() -> void:
	player.animated_sprite.modulate = _original_modulate
	player.animated_sprite.speed_scale = 1.0
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func process_state(delta: float) -> void:
	if _phase != Phase.CHARGING:
		return
	_charge_timer += delta
	var ratio: float = minf(_charge_timer / charge_duration, 1.0)
	player.animated_sprite.modulate = Color.WHITE.lerp(
		GameConfig.config.ranger_charged_shot_glow_color, ratio
	)
	if _charge_timer >= charge_duration:
		_fire_charged_shot()

func physics_process_state(delta: float) -> void:
	if _phase == Phase.FIRING:
		var direction: Vector2 = get_input_direction()
		if direction != Vector2.ZERO:
			player.velocity = player.velocity.move_toward(
				direction * player.speed * move_fraction,
				player.acceleration * delta
			)
		else:
			player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * delta)
		player.velocity += player.knockback_component.knockback_velocity
	else:
		player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if _phase == Phase.CHARGING and event.is_action_released(&"attack"):
		_fire_quick_shot()

func _fire_quick_shot() -> void:
	player.animated_sprite.modulate = _original_modulate
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.fire_arrow(_attack_direction)

	var now: float = Time.get_ticks_msec() / 1000.0
	player.chain_shot_count = mini(_current_chain + 1, max_chain)
	player.chain_shot_deadline = now + chain_window

	_phase = Phase.FIRING
	player.animated_sprite.play()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func _fire_charged_shot() -> void:
	player.animated_sprite.modulate = _original_modulate
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.fire_piercing_arrow(_attack_direction)

	player.chain_shot_count = 0
	player.chain_shot_deadline = 0.0

	_phase = Phase.FIRING
	player.animated_sprite.play()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
