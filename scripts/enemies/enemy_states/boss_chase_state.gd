extends EnemyState

@export var melee_range: float = 22.0
@export var charge_cooldown: float = 5.0
@export var slam_cooldown: float = 7.0
@export var summon_cooldown: float = 10.0

var _charge_timer: float = 0.0
var _slam_timer: float = 0.0
var _summon_timer: float = 0.0

func enter() -> void:
	enemy.play_directional_animation("walk")
	if _charge_timer <= 0.0:
		_charge_timer = charge_cooldown * 0.5
	if _slam_timer <= 0.0:
		_slam_timer = slam_cooldown * 0.5
	if _summon_timer <= 0.0:
		_summon_timer = summon_cooldown * 0.5

func physics_process_state(delta: float) -> void:
	_charge_timer -= delta
	_slam_timer -= delta
	_summon_timer -= delta

	var direction: Vector2 = get_direction_to_player()
	var distance: float = get_distance_to_player()

	if direction != Vector2.ZERO:
		if enemy.update_facing(direction):
			enemy.play_directional_animation("walk")
		enemy.velocity = enemy.velocity.move_toward(direction * enemy.speed, enemy.acceleration * delta)

	enemy.velocity += enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if enemy.current_phase >= 3 and _summon_timer <= 0.0:
		_summon_timer = summon_cooldown
		transition_requested.emit(self, &"SummonState")
		return

	if enemy.current_phase >= 2 and _slam_timer <= 0.0 and distance <= 50.0:
		_slam_timer = slam_cooldown
		transition_requested.emit(self, &"SlamState")
		return

	if _charge_timer <= 0.0 and distance > 40.0:
		_charge_timer = charge_cooldown
		transition_requested.emit(self, &"ChargeState")
		return

	if distance <= melee_range:
		transition_requested.emit(self, &"MeleeAttackState")
