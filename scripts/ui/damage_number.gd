extends Label

var float_speed: float:
	get: return GameConfig.config.ui_damage_float_speed
var duration: float:
	get: return GameConfig.config.ui_damage_duration
var spread: float:
	get: return GameConfig.config.ui_damage_spread

var _direction: Vector2
var _timer: float = 0.0

func setup(value: int, color: Color) -> void:
	text = str(value)
	modulate = color

func _ready() -> void:
	_direction = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()
	_timer = duration
	position.x += randf_range(-spread, spread)

func _process(delta: float) -> void:
	position += _direction * float_speed * delta
	_timer -= delta
	modulate.a = maxf(0.0, _timer / duration)
	if _timer <= 0.0:
		queue_free()
