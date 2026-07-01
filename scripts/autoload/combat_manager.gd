extends Node

var _damage_number_scene: PackedScene = preload("res://scenes/ui/damage_number.tscn")
var _camera: Camera2D = null
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _base_time_scale: float = 1.0
var _is_slowmo_active: bool = false
var _flash_overlay: ColorRect = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.room_cleared.connect(_on_room_cleared)

func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var strength: float = _shake_intensity * (_shake_timer / _shake_duration)
		var shake: Vector2 = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		if _shake_timer <= 0.0:
			shake = Vector2.ZERO
		_apply_shake_offset(shake)

func calculate_damage(base_damage: int, defense: int = 0, crit_chance: float = 0.0) -> Dictionary:
	var damage: int = maxi(1, base_damage - defense)
	var is_crit: bool = crit_chance > 0.0 and randf() < crit_chance
	if is_crit:
		damage *= GameConfig.config.combat_crit_multiplier
	return {"damage": damage, "is_crit": is_crit}

func apply_hit_pause(real_duration: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(real_duration * Engine.time_scale, true).timeout
	Engine.time_scale = _base_time_scale

func apply_screen_shake(intensity: float, duration: float) -> void:
	if not SaveManager.get_setting("screen_shake_enabled", true):
		return
	if _find_camera() == null:
		return
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration

func spawn_damage_number(value: int, global_pos: Vector2, color: Color = Color.WHITE) -> void:
	var number: Label = _damage_number_scene.instantiate() as Label
	number.setup(value, color)
	var game_world: Node = get_tree().get_first_node_in_group(&"game_world")
	if game_world == null:
		number.queue_free()
		return
	game_world.add_child(number)
	number.global_position = global_pos

func _find_camera() -> Camera2D:
	if _camera == null or not is_instance_valid(_camera):
		_camera = get_tree().get_first_node_in_group(&"main_camera") as Camera2D
	return _camera

func _apply_shake_offset(shake: Vector2) -> void:
	if _camera == null or not is_instance_valid(_camera):
		return
	var game_camera: GameCamera = _camera as GameCamera
	if game_camera:
		game_camera.shake_offset = shake
	else:
		_camera.offset = shake

func _create_flash_overlay() -> void:
	if _flash_overlay and is_instance_valid(_flash_overlay):
		return
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	canvas_layer.layer = 90
	add_child(canvas_layer)
	_flash_overlay = ColorRect.new()
	_flash_overlay.color = Color.WHITE
	_flash_overlay.size = Vector2(480, 270)
	_flash_overlay.modulate.a = 0.0
	_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(_flash_overlay)

func _set_time_scale(value: float) -> void:
	_base_time_scale = value
	Engine.time_scale = value

func _on_boss_defeated(_boss_id: String) -> void:
	if _is_slowmo_active:
		return
	_is_slowmo_active = true
	_set_time_scale(GameConfig.config.boss_slowmo_time_scale)
	var camera: GameCamera = _find_camera() as GameCamera
	if camera:
		camera.zoom_pulse(
			GameConfig.config.boss_slowmo_zoom_peak,
			GameConfig.config.boss_slowmo_zoom_in_duration,
			GameConfig.config.boss_slowmo_zoom_out_duration
		)
	await get_tree().create_timer(GameConfig.config.boss_slowmo_hold_duration, true, false, true).timeout
	var tween: Tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_method(_set_time_scale, _base_time_scale, 1.0, GameConfig.config.boss_slowmo_recover_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	_set_time_scale(1.0)
	_is_slowmo_active = false

func _on_room_cleared(room_id: int) -> void:
	if DungeonManager.is_final_room(room_id):
		return
	_create_flash_overlay()
	var flash_tween: Tween = create_tween()
	flash_tween.tween_property(_flash_overlay, "modulate:a", GameConfig.config.room_clear_flash_alpha, 0.05)
	flash_tween.tween_property(_flash_overlay, "modulate:a", 0.0, GameConfig.config.room_clear_flash_fade_duration)
	if not SaveManager.get_setting("screen_shake_enabled", true):
		return
	var camera: GameCamera = _find_camera() as GameCamera
	if camera:
		var half_duration: float = GameConfig.config.room_clear_zoom_pulse_duration / 2.0
		camera.zoom_pulse(GameConfig.config.room_clear_zoom_peak, half_duration, half_duration)
