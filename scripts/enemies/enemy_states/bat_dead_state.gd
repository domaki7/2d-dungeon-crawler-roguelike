extends EnemyState

var death_delay: float:
	get: return GameConfig.config.bat_death_delay
@export var gold_drop_scene: PackedScene
@export var loot_table: LootTable
@export var item_pickup_scene: PackedScene

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
	EventBus.enemy_killed.emit({"position": enemy.global_position, "type": "bat"})
	AudioManager.play_sfx(&"enemy_die")

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
	if loot_table and item_pickup_scene:
		var item: ItemData = loot_table.roll()
		if item:
			var pickup: Node2D = item_pickup_scene.instantiate() as Node2D
			pickup.item_data = item
			pickup.global_position = enemy.global_position + Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
			enemy.get_parent().add_child(pickup)
