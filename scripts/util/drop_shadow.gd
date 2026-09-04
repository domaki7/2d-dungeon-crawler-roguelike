class_name DropShadow
extends Node2D
## Soft ellipse drawn beneath a character so it reads as standing on the floor
## instead of floating over the tilemap.
##
## Attached programmatically (see `attach`) rather than authored into every
## entity scene, so one tuning change in GameConfig moves every shadow.

## Multiplies the configured radii — elites are scaled up, minis scaled down.
var radius_scale: float = 1.0
## When set, the shadow holds still at this Y while the sprite bobs above it,
## which is what sells the bat as airborne.
var pinned_y: float = INF

var _owner_sprite: Node2D = null

## Adds a shadow as the first child of `entity` so it draws under everything
## else the entity owns. Returns the shadow for callers that want to tweak it.
static func attach(entity: Node2D, scale_factor: float = 1.0) -> DropShadow:
	var shadow: DropShadow = DropShadow.new()
	shadow.name = "DropShadow"
	shadow.radius_scale = scale_factor
	shadow.z_index = -1
	shadow.position.y = GameConfig.config.vfx_shadow_offset_y
	entity.add_child(shadow)
	entity.move_child(shadow, 0)
	return shadow

func _draw() -> void:
	var rx: float = GameConfig.config.vfx_shadow_radius_x * radius_scale
	var ry: float = GameConfig.config.vfx_shadow_radius_y * radius_scale
	var alpha: float = GameConfig.config.vfx_shadow_alpha
	# Two stacked ellipses fake a soft edge without needing a texture.
	_draw_ellipse(rx, ry, Color(0.0, 0.0, 0.0, alpha * 0.4))
	_draw_ellipse(rx * 0.68, ry * 0.68, Color(0.0, 0.0, 0.0, alpha))

func _draw_ellipse(rx: float, ry: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in 16:
		var angle: float = TAU * float(i) / 16.0
		points.append(Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)
