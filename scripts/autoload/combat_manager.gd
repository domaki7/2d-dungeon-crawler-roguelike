extends Node

var _damage_number_scene: PackedScene = preload("res://scenes/ui/damage_number.tscn")
var _camera: Camera2D = null
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var strength: float = _shake_intensity * (_shake_timer / _shake_duration)
		if _camera:
			_camera.offset = Vector2(
				randf_range(-strength, strength),
				randf_range(-strength, strength)
			)
		if _shake_timer <= 0.0:
			if _camera:
				_camera.offset = Vector2.ZERO

func calculate_damage(base_damage: int, defense: int = 0, crit_chance: float = 0.0) -> int:
	var damage: int = maxi(1, base_damage - defense)
	if crit_chance > 0.0 and randf() < crit_chance:
		damage *= 2
	return damage

func apply_hit_pause(real_duration: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(real_duration * Engine.time_scale, true).timeout
	Engine.time_scale = 1.0

func apply_screen_shake(intensity: float, duration: float) -> void:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group(&"main_camera") as Camera2D
	if _camera == null:
		return
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration

func spawn_damage_number(value: int, global_pos: Vector2, color: Color = Color.WHITE) -> void:
	var number: Label = _damage_number_scene.instantiate() as Label
	number.setup(value, color)
	get_tree().current_scene.add_child(number)
	number.global_position = global_pos
