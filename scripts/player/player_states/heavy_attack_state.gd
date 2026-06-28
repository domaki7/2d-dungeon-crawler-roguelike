extends PlayerState

enum Phase { CHARGING, SWINGING }

var charge_duration: float:
	get: return GameConfig.config.player_heavy_charge_duration
var damage_multiplier: float:
	get: return GameConfig.config.player_heavy_damage_multiplier
var knockback_multiplier: float:
	get: return GameConfig.config.player_heavy_knockback_multiplier
var heavy_hitbox_size: Vector2:
	get: return GameConfig.config.player_heavy_hitbox_size
var shake_intensity: float:
	get: return GameConfig.config.player_heavy_shake_intensity
var hitbox_offset: float:
	get: return GameConfig.config.player_hitbox_offset
var active_frame: int:
	get: return GameConfig.config.player_attack_active_frame

var _phase: int = Phase.CHARGING
var _charge_timer: float = 0.0
var _attack_direction: Vector2 = Vector2.ZERO
var _original_hitbox_size: Vector2 = Vector2.ZERO
var _original_sprite_offset: Vector2 = Vector2.ZERO
var _hitbox_activated: bool = false

func enter() -> void:
	player.velocity = Vector2.ZERO
	_phase = Phase.CHARGING
	_charge_timer = 0.0
	_hitbox_activated = false
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	_original_sprite_offset = player.animated_sprite.offset
	_capture_original_hitbox_size()
	player.play_directional_animation("heavy_attack")
	player.animated_sprite.pause()

func exit() -> void:
	if _hitbox_activated:
		player.hitbox.deactivate()
		_hitbox_activated = false
	player.hitbox.position = Vector2.ZERO
	_restore_hitbox_size()
	player.hitbox.damage = player.player_stats.get_effective_damage()
	player.hitbox.knockback_force = player.player_stats.get_effective_knockback_force()
	player.animated_sprite.offset = _original_sprite_offset
	if player.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		player.animated_sprite.frame_changed.disconnect(_on_frame_changed)
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func process_state(delta: float) -> void:
	if _phase != Phase.CHARGING:
		return
	_charge_timer += delta
	var charge_ratio: float = minf(_charge_timer / charge_duration, 1.0)
	var shake_freq: float = 10.0 + charge_ratio * 30.0
	var shake_amp: float = shake_intensity * charge_ratio
	player.animated_sprite.offset = _original_sprite_offset + Vector2(
		sin(Time.get_ticks_msec() * shake_freq * 0.01) * shake_amp, 0.0
	)
	if _charge_timer >= charge_duration:
		_execute_heavy_swing()

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if _phase == Phase.CHARGING:
		if event.is_action_released(&"attack"):
			transition_requested.emit(self, &"IdleState")
		elif event.is_action_pressed(&"dodge"):
			if player.ability_manager.is_ability_ready(3):
				transition_requested.emit(self, &"DodgeRollState")

func _execute_heavy_swing() -> void:
	_phase = Phase.SWINGING
	player.animated_sprite.offset = _original_sprite_offset
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.play_directional_animation("heavy_attack")

	_position_hitbox()
	_resize_hitbox_heavy()

	var base_damage: int = player.get_ability_damage(player.player_stats.get_effective_damage())
	player.hitbox.damage = int(float(base_damage) * damage_multiplier)
	player.hitbox.knockback_force = player.player_stats.get_effective_knockback_force() * knockback_multiplier

	VFXHelper.spawn_melee_swing(
		player.global_position + _attack_direction * hitbox_offset,
		_attack_direction.angle()
	)

	player.animated_sprite.frame_changed.connect(_on_frame_changed)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)
	AudioManager.play_sfx_varied(&"attack")

func _position_hitbox() -> void:
	player.hitbox.position = _attack_direction * hitbox_offset

func _capture_original_hitbox_size() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			_original_hitbox_size = rect.size

func _resize_hitbox_heavy() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			rect.size = heavy_hitbox_size

func _restore_hitbox_size() -> void:
	if _original_hitbox_size != Vector2.ZERO:
		var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
		if shape_node:
			var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
			if rect:
				rect.size = _original_hitbox_size

func _on_frame_changed() -> void:
	var current_frame: int = player.animated_sprite.frame
	if current_frame == active_frame and not _hitbox_activated:
		player.hitbox.activate()
		_hitbox_activated = true
	elif current_frame > active_frame and _hitbox_activated:
		player.hitbox.deactivate()
		_hitbox_activated = false

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
