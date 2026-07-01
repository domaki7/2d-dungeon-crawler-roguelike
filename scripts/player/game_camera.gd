class_name GameCamera
extends Camera2D

var lookahead_max_distance: float:
	get: return GameConfig.config.camera_lookahead_max_distance
var lookahead_mouse_range: float:
	get: return GameConfig.config.camera_lookahead_mouse_range
var lookahead_smoothing: float:
	get: return GameConfig.config.camera_lookahead_smoothing

var shake_offset: Vector2 = Vector2.ZERO

var _lookahead_offset: Vector2 = Vector2.ZERO
var _zoom_tween: Tween = null

func _process(delta: float) -> void:
	var mouse_delta: Vector2 = get_global_mouse_position() - get_parent().global_position
	var target: Vector2 = mouse_delta / lookahead_mouse_range * lookahead_max_distance
	target = target.limit_length(lookahead_max_distance)
	_lookahead_offset = _lookahead_offset.lerp(target, minf(lookahead_smoothing * delta, 1.0))
	offset = _lookahead_offset + shake_offset

func zoom_pulse(peak: float, in_duration: float, out_duration: float) -> void:
	if _zoom_tween and _zoom_tween.is_valid():
		_zoom_tween.kill()
	_zoom_tween = create_tween()
	_zoom_tween.set_ignore_time_scale(true)
	_zoom_tween.tween_property(self, "zoom", Vector2(peak, peak), in_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE, out_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
