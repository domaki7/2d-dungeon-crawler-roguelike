extends Node2D

var _health_component: HealthComponent = null
var _is_elite: bool = false
var _fade_timer: float = 0.0
var _is_fading: bool = false
var _current_alpha: float = 0.0

func setup(hc: HealthComponent, is_elite: bool) -> void:
	_health_component = hc
	_is_elite = is_elite
	_current_alpha = 1.0 if is_elite else 0.0
	hc.health_changed.connect(_on_health_changed)

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	if not _is_elite:
		_current_alpha = 1.0
		_fade_timer = GameConfig.config.ui_enemy_health_bar_fade_delay
		_is_fading = false
	queue_redraw()

func _process(delta: float) -> void:
	if _is_elite or _current_alpha <= 0.0:
		return
	if _fade_timer > 0.0:
		_fade_timer -= delta
		if _fade_timer <= 0.0:
			_is_fading = true
	if _is_fading:
		_current_alpha = maxf(0.0, _current_alpha - delta / GameConfig.config.ui_enemy_health_bar_fade_duration)
		queue_redraw()

func _draw() -> void:
	if _health_component == null or _current_alpha <= 0.0:
		return
	var w: float = GameConfig.config.ui_enemy_health_bar_width
	var h: float = GameConfig.config.ui_enemy_health_bar_height
	var x: float = -w / 2.0
	var y: float = GameConfig.config.ui_enemy_health_bar_offset_y
	draw_rect(Rect2(x, y, w, h), Color(0.1, 0.1, 0.1, _current_alpha))
	var hp_ratio: float = 0.0
	if _health_component.max_hp > 0:
		hp_ratio = float(_health_component.current_hp) / float(_health_component.max_hp)
	var fill_color: Color = Color(0.8, 0.15, 0.15, _current_alpha) if _is_elite else Color(0.15, 0.7, 0.2, _current_alpha)
	if hp_ratio > 0.0:
		draw_rect(Rect2(x, y, w * hp_ratio, h), fill_color)
