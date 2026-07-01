extends PlayerState

var active_frame: int:
	get: return GameConfig.config.player_attack_active_frame
var cancel_frame: int:
	get: return GameConfig.config.player_attack_cancel_frame
var hitbox_offset: float:
	get: return GameConfig.config.player_hitbox_offset
var hitbox_size: Vector2:
	get: return GameConfig.config.player_hitbox_size

var _attack_direction: Vector2 = Vector2.ZERO
var _original_hitbox_size: Vector2 = Vector2.ZERO
var _hitbox_activated: bool = false

var _combo_count: int = 1
var _chaining: bool = false
var _chain_requested: bool = false

func enter() -> void:
	if not _chaining:
		_combo_count = 1
	_chaining = false
	_chain_requested = false
	player.velocity = Vector2.ZERO
	_hitbox_activated = false
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.play_directional_animation("attack")
	_capture_original_hitbox_size()
	_position_hitbox()
	_resize_hitbox()
	var swing_scale: float = 1.0
	match _combo_count:
		2: swing_scale = GameConfig.config.player_combo_2_swing_scale
		3: swing_scale = GameConfig.config.player_combo_3_swing_scale
	VFXHelper.spawn_melee_swing(
		player.global_position + _attack_direction * hitbox_offset,
		_attack_direction.angle(),
		swing_scale
	)
	AudioManager.play_sfx_varied(&"swing")
	var base_damage: int = player.get_ability_damage(player.player_stats.get_effective_damage())
	player.hitbox.damage = int(float(base_damage) * _get_combo_damage_multiplier())
	if player.riposte_timer > 0.0:
		player.hitbox.crit_chance = 1.0
		player.riposte_timer = 0.0
	player.animated_sprite.frame_changed.connect(_on_frame_changed)
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if _hitbox_activated:
		player.hitbox.deactivate()
		_hitbox_activated = false
	player.hitbox.position = Vector2.ZERO
	_restore_hitbox_size()
	player.hitbox.damage = player.player_stats.get_effective_damage()
	player.hitbox.crit_chance = player.player_stats.get_effective_crit_chance()
	if player.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		player.animated_sprite.frame_changed.disconnect(_on_frame_changed)
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		_chain_requested = true
	elif event.is_action_pressed(&"dodge"):
		if player.animated_sprite.frame >= cancel_frame and player.ability_manager.is_ability_ready(3):
			transition_requested.emit(self, &"DodgeRollState")

func _position_hitbox() -> void:
	player.hitbox.position = _attack_direction * hitbox_offset

func _capture_original_hitbox_size() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			_original_hitbox_size = rect.size

func _resize_hitbox() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			rect.size = _get_combo_hitbox_size()

func _restore_hitbox_size() -> void:
	if _original_hitbox_size != Vector2.ZERO:
		var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
		if shape_node:
			var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
			if rect:
				rect.size = _original_hitbox_size

func _get_combo_damage_multiplier() -> float:
	match _combo_count:
		2: return GameConfig.config.player_combo_2_damage_multiplier
		3: return GameConfig.config.player_combo_3_damage_multiplier
	return 1.0

func _get_combo_hitbox_size() -> Vector2:
	match _combo_count:
		2: return GameConfig.config.player_combo_2_hitbox_size
		3: return GameConfig.config.player_combo_3_hitbox_size
	return hitbox_size

func _on_frame_changed() -> void:
	var current_frame: int = player.animated_sprite.frame
	if current_frame == active_frame and not _hitbox_activated:
		player.hitbox.activate()
		_hitbox_activated = true
		AudioManager.play_sfx_varied(&"hit")
	elif current_frame > active_frame and _hitbox_activated:
		player.hitbox.deactivate()
		_hitbox_activated = false

func _on_animation_finished() -> void:
	if _chain_requested and _combo_count < 3:
		_chaining = true
		_combo_count += 1
		_chain_requested = false
		transition_requested.emit(self, &"AttackState")
	elif Input.is_action_pressed(&"attack"):
		_chaining = false
		transition_requested.emit(self, &"HeavyAttackState")
	else:
		_chaining = false
		_chain_requested = false
		transition_requested.emit(self, &"IdleState")
