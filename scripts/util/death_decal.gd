class_name DeathDecal
extends Node2D
## Splatter left behind where something died, so a cleared room shows the
## aftermath of the fight instead of resetting to pristine tiles.
##
## Drawn rather than textured: a handful of overlapping circles seeded from the
## spawn position gives every decal a different silhouette for free.

var blot_color: Color = Color(0.28, 0.06, 0.06, 0.55)

## Each entry is (offset_x, offset_y, radius).
var _blots: Array[Vector3] = []

func setup(color: Color, shape_seed: int) -> void:
	blot_color = color
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = shape_seed
	for i: int in 5:
		_blots.append(Vector3(
			rng.randf_range(-4.0, 4.0),
			rng.randf_range(-2.0, 2.0),
			rng.randf_range(1.4, 3.2)
		))
	queue_redraw()

func _ready() -> void:
	# Below entities and pickups, above the floor tiles.
	z_index = -2
	var lifetime: float = GameConfig.config.vfx_decal_lifetime
	var fade: float = GameConfig.config.vfx_decal_fade_duration
	var tween: Tween = create_tween()
	tween.tween_interval(lifetime)
	tween.tween_property(self, "modulate:a", 0.0, fade)
	tween.tween_callback(queue_free)

## Fades and frees early — used when the decal cap is exceeded.
func dismiss() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)

func _draw() -> void:
	for blot: Vector3 in _blots:
		draw_circle(Vector2(blot.x, blot.y), blot.z, blot_color)
