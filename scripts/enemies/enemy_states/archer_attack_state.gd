extends EnemyState

var arrow_damage: int:
	get: return GameConfig.config.archer_arrow_damage
var shoot_delay: float:
	get: return GameConfig.config.archer_shoot_delay

var _arrow_scene: PackedScene = preload("res://scenes/attacks/arrow.tscn")
var _shoot_timer: float = 0.0
var _has_fired: bool = false

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var direction: Vector2 = get_direction_to_player()
	enemy.update_facing(direction)
	enemy.play_directional_animation("attack")
	_shoot_timer = shoot_delay
	_has_fired = false
	enemy.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if enemy.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		enemy.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if not _has_fired:
		_shoot_timer -= delta
		if _shoot_timer <= 0.0:
			_fire_arrow()
			_has_fired = true

func _fire_arrow() -> void:
	var direction: Vector2 = get_direction_to_player()
	var arrow: Area2D = _arrow_scene.instantiate() as Area2D
	arrow.global_position = enemy.global_position
	arrow.setup(direction, arrow_damage)
	enemy.get_parent().add_child(arrow)
	AudioManager.play_sfx(&"arrow_fire")

func _on_animation_finished() -> void:
	if enemy.is_player_detected:
		transition_requested.emit(self, &"ChaseState")
	else:
		transition_requested.emit(self, &"IdleState")
