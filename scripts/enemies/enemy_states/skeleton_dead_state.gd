extends EnemyState

@export var death_delay: float = 0.3
@export var gold_drop_scene: PackedScene

var _death_timer: float = 0.0
var _has_dropped: bool = false

func enter() -> void:
	_death_timer = death_delay
	_has_dropped = false
	enemy.set_collision_layer_value(3, false)
	for child: Node in enemy.hurtbox.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)
	enemy.animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.5)
	EventBus.enemy_killed.emit({"position": enemy.global_position, "type": "skeleton"})

func physics_process_state(delta: float) -> void:
	_death_timer -= delta
	if not _has_dropped and _death_timer <= death_delay * 0.5:
		_has_dropped = true
		_spawn_gold_drop()
	if _death_timer <= 0.0:
		enemy.queue_free()

func _spawn_gold_drop() -> void:
	if gold_drop_scene:
		var gold: Area2D = gold_drop_scene.instantiate() as Area2D
		gold.global_position = enemy.global_position
		enemy.get_parent().add_child(gold)
