class_name BreakableObject
extends StaticBody2D

enum BreakableType { BARREL, CRATE }

@export var breakable_type: BreakableType = BreakableType.BARREL

var _barrel_texture: Texture2D = preload("res://assets/sprites/items/barrel.svg")
var _crate_texture: Texture2D = preload("res://assets/sprites/items/crate.svg")
var _gold_pickup_scene: PackedScene = preload("res://scenes/pickups/gold_pickup.tscn")
var _break_poof_scene: PackedScene = preload("res://scenes/effects/break_poof.tscn")

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _health: HealthComponent = $HealthComponent

var _flash_tween: Tween = null

func _ready() -> void:
	match breakable_type:
		BreakableType.BARREL:
			_sprite.texture = _barrel_texture
			_health.max_hp = GameConfig.config.breakable_barrel_hp
		BreakableType.CRATE:
			_sprite.texture = _crate_texture
			_health.max_hp = GameConfig.config.breakable_crate_hp
	_health.i_frame_duration = GameConfig.config.breakable_i_frame_duration
	_health.current_hp = _health.max_hp
	_health.died.connect(_on_died)
	_health.damaged.connect(_on_damaged)

func _on_damaged(_amount: int) -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)

func _on_died() -> void:
	set_physics_process(false)
	set_process(false)
	for child: Node in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)
	for child: Node in get_children():
		if child is Area2D:
			child.set_deferred("monitorable", false)

	VFXHelper.spawn_particles_at(_break_poof_scene, global_position)
	AudioManager.play_sfx_varied(&"hit")

	if randf() < GameConfig.config.breakable_gold_drop_chance:
		var count: int = randi_range(
			GameConfig.config.breakable_gold_count_min,
			GameConfig.config.breakable_gold_count_max
		)
		var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
		if game_world:
			var scatter: float = GameConfig.config.breakable_gold_scatter_radius
			for i: int in range(count):
				var gold: Area2D = _gold_pickup_scene.instantiate() as Area2D
				var angle: float = TAU * float(i) / float(maxi(count, 1))
				gold.global_position = global_position + Vector2(cos(angle), sin(angle)) * scatter
				game_world.add_child(gold)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
