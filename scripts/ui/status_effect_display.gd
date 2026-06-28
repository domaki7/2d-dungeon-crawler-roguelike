extends HBoxContainer

var _icons: Dictionary = {}
var _timers: Dictionary = {}
var _durations: Dictionary = {}

var _effect_colors: Dictionary = {
	StatusEffectData.Type.STUN: Color(1.0, 1.0, 0.5),
	StatusEffectData.Type.BURN: Color(1.0, 0.6, 0.3),
	StatusEffectData.Type.POISON: Color(0.5, 0.9, 0.3),
	StatusEffectData.Type.FREEZE: Color(0.5, 0.8, 1.0),
	StatusEffectData.Type.SLOW: Color(0.7, 0.5, 0.9),
}

func _ready() -> void:
	EventBus.status_effect_applied.connect(_on_effect_applied)
	EventBus.status_effect_removed.connect(_on_effect_removed)

func _process(delta: float) -> void:
	for type: int in _timers:
		_timers[type] = (_timers[type] as float) - delta
		var remaining: float = maxf(_timers[type] as float, 0.0)
		var duration: float = _durations[type] as float
		if duration > 0.0 and _icons.has(type):
			var container: VBoxContainer = _icons[type] as VBoxContainer
			var bar: ProgressBar = container.get_child(1) as ProgressBar
			bar.value = remaining / duration

func _on_effect_applied(type: int, duration: float) -> void:
	if _icons.has(type):
		_timers[type] = duration
		_durations[type] = duration
		var container: VBoxContainer = _icons[type] as VBoxContainer
		var bar: ProgressBar = container.get_child(1) as ProgressBar
		bar.value = 1.0
		return
	var container: VBoxContainer = VBoxContainer.new()
	container.add_theme_constant_override("separation", 0)

	var icon: ColorRect = ColorRect.new()
	icon.custom_minimum_size = Vector2(8, 8)
	icon.color = _effect_colors.get(type, Color.WHITE) as Color
	container.add_child(icon)

	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(8, 2)
	bar.max_value = 1.0
	bar.value = 1.0
	bar.show_percentage = false
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	fill_style.bg_color = _effect_colors.get(type, Color.WHITE) as Color
	bar.add_theme_stylebox_override("fill", fill_style)
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	bar.add_theme_stylebox_override("background", bg_style)
	container.add_child(bar)

	add_child(container)
	_icons[type] = container
	_timers[type] = duration
	_durations[type] = duration

func _on_effect_removed(type: int) -> void:
	if not _icons.has(type):
		return
	var container: VBoxContainer = _icons[type] as VBoxContainer
	container.queue_free()
	_icons.erase(type)
	_timers.erase(type)
	_durations.erase(type)
