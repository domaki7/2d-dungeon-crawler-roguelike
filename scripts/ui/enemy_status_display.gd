extends Node2D

var _active_effects: Array[int] = []

var _effect_colors: Dictionary = {
	StatusEffectData.Type.STUN: Color(1.0, 1.0, 0.5),
	StatusEffectData.Type.BURN: Color(1.0, 0.6, 0.3),
	StatusEffectData.Type.POISON: Color(0.5, 0.9, 0.3),
	StatusEffectData.Type.FREEZE: Color(0.5, 0.8, 1.0),
	StatusEffectData.Type.SLOW: Color(0.7, 0.5, 0.9),
}

func setup(sec: StatusEffectComponent) -> void:
	sec.effect_applied.connect(_on_effect_applied)
	sec.effect_removed.connect(_on_effect_removed)

func _on_effect_applied(type: int) -> void:
	if not _active_effects.has(type):
		_active_effects.append(type)
	queue_redraw()

func _on_effect_removed(type: int) -> void:
	_active_effects.erase(type)
	queue_redraw()

func _draw() -> void:
	if _active_effects.is_empty():
		return
	var icon_size: float = GameConfig.config.ui_enemy_status_icon_size
	var spacing: float = GameConfig.config.ui_enemy_status_icon_spacing
	var y: float = GameConfig.config.ui_enemy_status_icon_offset_y
	var total_w: float = float(_active_effects.size()) * (icon_size + spacing) - spacing
	var x: float = -total_w / 2.0
	for type: int in _active_effects:
		var color: Color = _effect_colors.get(type, Color.WHITE) as Color
		draw_rect(Rect2(x, y, icon_size, icon_size), color)
		x += icon_size + spacing
