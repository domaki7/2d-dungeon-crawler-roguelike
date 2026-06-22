extends Label

@export var float_speed: float = 30.0
@export var duration: float = 0.6
@export var spread: float = 8.0

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
