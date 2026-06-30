class_name SpawnPoint
extends Marker2D

enum SpawnType { SKELETON, SLIME, BAT, BOSS, GOLD, CHEST, LOCKED_CHEST, MIMIC_CHEST, GILDED_CHEST, OGRE }

@export var spawn_type: SpawnType = SpawnType.SKELETON
@export_range(0.0, 1.0) var spawn_chance: float = 1.0
@export var spawn_scene: PackedScene
@export var use_floor_pool: bool = false

func should_spawn() -> bool:
	return randf() <= spawn_chance

func spawn() -> Node2D:
	if not should_spawn():
		return null
	if spawn_scene == null:
		push_warning("SpawnPoint: no spawn_scene assigned at %s" % name)
		return null
	var instance: Node2D = spawn_scene.instantiate() as Node2D
	instance.global_position = global_position
	return instance
