extends EnemyState

var melee_range: float:
	get: return GameConfig.config.ogre_melee_range
var charge_cooldown: float:
	get: return GameConfig.config.ogre_charge_cooldown

var _charge_timer: float = 0.0

func enter() -> void:
	enemy.play_directional_animation("walk")
	if _charge_timer <= 0.0:
		_charge_timer = charge_cooldown * 0.5

func physics_process_state(delta: float) -> void:
	update_last_known_position()
	if not enemy.is_player_detected and not enemy.is_aggroed:
		transition_requested.emit(self, &"SearchState")
		return

	_charge_timer -= delta

	var direction: Vector2 = get_surround_direction(melee_range)
	if direction != Vector2.ZERO:
		if enemy.update_facing(direction):
			enemy.play_directional_animation("walk")
		enemy.velocity = enemy.velocity.move_toward(direction * enemy.speed, enemy.acceleration * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	var distance: float = get_distance_to_player()

	if _charge_timer <= 0.0 and distance > melee_range:
		_charge_timer = charge_cooldown
		transition_requested.emit(self, &"ChargeState")
		return

	if distance <= melee_range:
		transition_requested.emit(self, &"AttackState")
