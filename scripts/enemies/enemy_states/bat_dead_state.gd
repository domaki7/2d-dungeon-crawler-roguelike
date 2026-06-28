extends EnemyState

var death_delay: float:
	get: return GameConfig.config.bat_death_delay
var tween_duration: float:
	get: return GameConfig.config.vfx_death_tween_duration
var tween_end_scale: float:
	get: return GameConfig.config.vfx_death_tween_end_scale
@export var gold_drop_scene: PackedScene
@export var loot_table: LootTable
@export var item_pickup_scene: PackedScene

func enter() -> void:
	enemy.set_collision_layer_value(3, false)
	for child: Node in enemy.hurtbox.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)
	EventBus.enemy_killed.emit({"position": enemy.global_position, "type": "bat"})
	AudioManager.play_sfx_varied(&"enemy_die")
	VFXHelper.apply_hit_flash(enemy.animated_sprite)
	VFXHelper.spawn_death_poof(enemy.global_position)
	var tween: Tween = enemy.create_tween()
	tween.set_parallel(true)
	tween.tween_property(enemy.animated_sprite, "scale", Vector2(tween_end_scale, tween_end_scale), tween_duration)
	tween.tween_property(enemy.animated_sprite, "modulate:a", 0.0, tween_duration)
	tween.set_parallel(false)
	tween.tween_callback(_spawn_drops)
	tween.tween_callback(enemy.queue_free)

func _spawn_drops() -> void:
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
