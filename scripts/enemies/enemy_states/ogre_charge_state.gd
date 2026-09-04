extends EnemyState

var charge_speed: float:
	get: return GameConfig.config.ogre_charge_speed
var windup_duration: float:
	get: return GameConfig.config.ogre_charge_windup
var charge_duration: float:
	get: return GameConfig.config.ogre_charge_duration
var hitbox_offset: float:
	get: return GameConfig.config.ogre_charge_hitbox_offset
var wall_stun_duration: float:
	get: return GameConfig.config.ogre_wall_stun_duration

var _charge_direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0
var _is_charging: bool = false
var _has_hit_player: bool = false

func enter() -> void:
	_charge_direction = get_direction_to_player()
	enemy.update_facing(_charge_direction)
	enemy.velocity = Vector2.ZERO
	_timer = windup_duration
	_is_charging = false
	_has_hit_player = false
	enemy.hitbox.deactivate()
	enemy.hitbox.hit_landed.connect(_on_hit_landed)
	enemy.animated_sprite.modulate = Color(1.5, 1.5, 1.5)
	enemy.play_directional_animation("idle")

func exit() -> void:
	enemy.hitbox.deactivate()
	if enemy.hitbox.hit_landed.is_connected(_on_hit_landed):
		enemy.hitbox.hit_landed.disconnect(_on_hit_landed)
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
		AudioManager.play_sfx_varied(&"ogre_charge")

	if _is_charging:
		enemy.velocity = _charge_direction * charge_speed
		if _timer <= 0.0:
			enemy.hitbox.deactivate()
			transition_requested.emit(self, &"ChaseState")
	else:
		enemy.velocity = Vector2.ZERO

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if _is_charging:
		for i: int in range(enemy.get_slide_collision_count()):
			var collider: Object = enemy.get_slide_collision(i).get_collider()
			if collider is CharacterBody2D:
				continue
			enemy.hitbox.deactivate()
			if _has_hit_player:
				transition_requested.emit(self, &"ChaseState")
			else:
				_apply_wall_stun()
			return

func _apply_wall_stun() -> void:
	var stun: StatusEffectData = StatusEffectData.new()
	stun.type = StatusEffectData.Type.STUN
	stun.duration = wall_stun_duration
	enemy.status_effect_component.apply_effect(stun)
	CombatManager.apply_screen_shake(GameConfig.config.combat_screen_shake_intensity, GameConfig.config.combat_screen_shake_duration)
	VFXHelper.spawn_hit_sparks(enemy.global_position + _charge_direction * hitbox_offset)
	AudioManager.play_sfx_varied(&"hit")
	transition_requested.emit(self, &"StunnedState")

func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	_has_hit_player = true

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
