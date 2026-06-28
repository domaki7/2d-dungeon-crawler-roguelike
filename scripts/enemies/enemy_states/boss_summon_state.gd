extends EnemyState

var summon_count: int:
	get: return GameConfig.config.boss_summon_count
var summon_delay: float:
	get: return GameConfig.config.boss_summon_delay
var spawn_radius: float:
	get: return GameConfig.config.boss_spawn_radius

var _skeleton_scene: PackedScene = preload("res://scenes/enemies/skeleton.tscn")
var _timer: float = 0.0

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	_timer = summon_delay
	enemy.play_directional_animation("idle")
	enemy.animated_sprite.modulate = Color(0.8, 0.5, 0.8)

func exit() -> void:
	enemy.animated_sprite.modulate = Color.WHITE

func physics_process_state(delta: float) -> void:
	_timer -= delta
	enemy.velocity = enemy.knockback_component.knockback_velocity
	enemy.move_and_slide()

	if _timer <= 0.0:
		_spawn_minions()
		transition_requested.emit(self, &"ChaseState")

func _spawn_minions() -> void:
	for i: int in range(summon_count):
		var angle: float = randf() * TAU
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos: Vector2 = enemy.global_position + offset
		var skeleton: CharacterBody2D = _skeleton_scene.instantiate() as CharacterBody2D
		skeleton.global_position = spawn_pos
		enemy.get_parent().add_child(skeleton)
