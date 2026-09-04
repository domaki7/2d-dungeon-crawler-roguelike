extends EnemyState

var summon_count: int:
	get: return GameConfig.config.boss_summon_count
var summon_delay: float:
	get: return GameConfig.config.boss_summon_delay
var spawn_radius: float:
	get: return GameConfig.config.boss_spawn_radius

## Minion scene summoned by this boss; falls back to skeletons when unset
@export var minion_scene: PackedScene

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
	var scene: PackedScene = minion_scene if minion_scene else _skeleton_scene
	for i: int in range(summon_count):
		var angle: float = randf() * TAU
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos: Vector2 = enemy.global_position + offset
		var minion: CharacterBody2D = scene.instantiate() as CharacterBody2D
		minion.global_position = spawn_pos
		enemy.get_parent().add_child(minion)
