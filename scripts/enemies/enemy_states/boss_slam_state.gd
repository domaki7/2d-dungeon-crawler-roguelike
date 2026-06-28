extends EnemyState

var slam_damage: int:
	get: return GameConfig.config.boss_slam_damage
var slam_radius: float:
	get: return GameConfig.config.boss_slam_radius
var windup_duration: float:
	get: return GameConfig.config.boss_slam_windup
var slam_duration: float:
	get: return GameConfig.config.boss_slam_duration

var _timer: float = 0.0
var _has_slammed: bool = false
var _original_y: float = 0.0

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	_timer = windup_duration
	_has_slammed = false
	_original_y = enemy.animated_sprite.position.y
	var tween: Tween = enemy.create_tween()
	tween.tween_property(enemy.animated_sprite, "position:y", _original_y - 12.0, windup_duration)
	enemy.play_directional_animation("idle")

func exit() -> void:
	enemy.animated_sprite.position.y = _original_y
	enemy.hitbox.deactivate()

func physics_process_state(delta: float) -> void:
	_timer -= delta

	if not _has_slammed and _timer <= 0.0:
		_has_slammed = true
		_timer = slam_duration
		var tween: Tween = enemy.create_tween()
		tween.tween_property(enemy.animated_sprite, "position:y", _original_y, 0.1)
		_do_slam_damage()
		CombatManager.apply_screen_shake(GameConfig.config.boss_slam_shake_intensity, GameConfig.config.boss_slam_shake_duration)
		AudioManager.play_sfx(&"boss_slam")

	if _has_slammed and _timer <= 0.0:
		transition_requested.emit(self, &"ChaseState")

	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

func _do_slam_damage() -> void:
	var player: CharacterBody2D = get_player()
	if player == null:
		return
	var distance: float = enemy.global_position.distance_to(player.global_position)
	if distance <= slam_radius:
		var player_hurtbox: Hurtbox = player.get_node_or_null("Hurtbox") as Hurtbox
		if player_hurtbox:
			enemy.hitbox.damage = slam_damage
			enemy.hitbox.activate()
			enemy.hitbox.position = Vector2.ZERO
			enemy.hitbox._hit_targets.clear()
			player_hurtbox.receive_hit(enemy.hitbox)
			enemy.hitbox.deactivate()
