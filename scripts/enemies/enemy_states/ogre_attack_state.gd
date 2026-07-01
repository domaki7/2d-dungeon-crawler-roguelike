extends EnemyState

var hitbox_offset: float:
	get: return GameConfig.config.ogre_hitbox_offset
var telegraph_duration: float:
	get: return GameConfig.config.ogre_telegraph_duration
var flash_min_interval: float:
	get: return GameConfig.config.telegraph_min_flash_interval
var flash_max_interval: float:
	get: return GameConfig.config.telegraph_max_flash_interval
var flash_pulse_duration: float:
	get: return GameConfig.config.telegraph_flash_duration

var _windup_timer: float = 0.0
var _flash_timer: float = 0.0
var _is_winding_up: bool = true

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var direction: Vector2 = get_direction_to_player()
	enemy.update_facing(direction)
	_is_winding_up = true
	_windup_timer = telegraph_duration
	_flash_timer = 0.0
	enemy.play_directional_animation("idle")

func exit() -> void:
	enemy.hitbox.deactivate()
	if enemy.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		enemy.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	if _is_winding_up:
		_windup_timer -= delta
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			var progress: float = 1.0 - (_windup_timer / telegraph_duration)
			_flash_timer = lerpf(flash_max_interval, flash_min_interval, progress)
			VFXHelper.apply_hit_flash(enemy.animated_sprite, flash_pulse_duration)
		if _windup_timer <= 0.0:
			_start_attack()
		return
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

func _start_attack() -> void:
	_is_winding_up = false
	enemy.play_directional_animation("attack")
	_position_hitbox()
	enemy.hitbox.activate()
	enemy.animated_sprite.animation_finished.connect(_on_animation_finished)

func _position_hitbox() -> void:
	var offset: Vector2 = Vector2.ZERO
	match enemy.facing_direction:
		enemy.FacingDirection.DOWN:
			offset = Vector2(0, hitbox_offset)
		enemy.FacingDirection.UP:
			offset = Vector2(0, -hitbox_offset)
		enemy.FacingDirection.LEFT:
			offset = Vector2(-hitbox_offset, 0)
		enemy.FacingDirection.RIGHT:
			offset = Vector2(hitbox_offset, 0)
	enemy.hitbox.position = offset

func is_in_parry_window() -> bool:
	return _is_winding_up and _windup_timer <= telegraph_duration * GameConfig.config.player_parry_window_fraction

func _on_animation_finished() -> void:
	if enemy.is_player_detected and get_distance_to_player() <= 24.0:
		transition_requested.emit(self, &"ChaseState")
	else:
		transition_requested.emit(self, &"IdleState")
