class_name EliteAura
extends Node2D
## Ring of motes orbiting an elite enemy.
##
## Elites previously read only as a colour tint, which is invisible against a
## dark dungeon floor. The orbit is drawn as a squashed ellipse and the motes
## brighten as they swing to the front, so the ring sells depth and the elite
## is obvious the moment it enters the screen.

var aura_color: Color = Color(1.0, 0.3, 0.3)

var _time: float = 0.0

static func attach(entity: Node2D, color: Color) -> EliteAura:
	var aura: EliteAura = EliteAura.new()
	aura.name = "EliteAura"
	aura.aura_color = color
	# Behind the sprite, but above the drop shadow.
	aura.z_index = -1
	aura.position.y = -6.0
	entity.add_child(aura)
	return aura

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var count: int = GameConfig.config.vfx_elite_aura_count
	if count <= 0:
		return
	var radius: float = GameConfig.config.vfx_elite_aura_radius
	var period: float = maxf(GameConfig.config.vfx_elite_aura_period, 0.01)
	var spin: float = TAU * _time / period
	for i: int in count:
		var angle: float = TAU * float(i) / float(count) + spin
		# Flattened orbit: motes at the bottom of the ellipse are "in front".
		var offset: Vector2 = Vector2(cos(angle) * radius, sin(angle) * radius * 0.42)
		var depth: float = 0.5 + 0.5 * sin(angle)
		var color: Color = aura_color
		color.a = 0.2 + 0.5 * depth
		draw_circle(offset, 0.7 + 0.8 * depth, color)
