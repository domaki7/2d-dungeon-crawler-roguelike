extends EnemyState

var charge_speed: float:
	get: return GameConfig.config.boss_charge_speed
var windup_duration: float:
	get: return GameConfig.config.boss_charge_windup
var charge_duration: float:
	get: return GameConfig.config.boss_charge_duration
var hitbox_offset: float:
	get: return GameConfig.config.boss_charge_hitbox_offset

var _charge_direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0
var _is_charging: bool = false

func enter() -> void:
	_charge_direction = get_direction_to_player()
	enemy.update_facing(_charge_direction)
	enemy.velocity = Vector2.ZERO
	_timer = windup_duration
	_is_charging = false
	enemy.hitbox.deactivate()
	enemy.animated_sprite.modulate = Color(1.5, 1.5, 1.5)
	enemy.play_directional_animation("idle")

func exit() -> void:
	enemy.hitbox.deactivate()
	enemy.animated_sprite.modulate = Color.WHITE

func physics_process_state(delta: float) -> void:
	_timer -= delta

	if not _is_charging and _timer <= 0.0:
		_is_charging = true
		_timer = charge_duration
		enemy.hitbox.activate()
		_position_hitbox()
		enemy.animated_sprite.modulate = Color.WHITE
		enemy.play_directional_animation("walk")
		AudioManager.play_sfx(&"boss_charge")

	if _is_charging:
		enemy.velocity = _charge_direction * charge_speed
		if _timer <= 0.0:
			enemy.hitbox.deactivate()
			transition_requested.emit(self, &"ChaseState")
	else:
		enemy.velocity = Vector2.ZERO

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

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
