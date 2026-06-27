extends PlayerState

@export var hitbox_offset: float = 18.0
@export var hitbox_size: Vector2 = Vector2(18, 15)

var _attack_direction: Vector2 = Vector2.ZERO
var _original_hitbox_size: Vector2 = Vector2.ZERO

func enter() -> void:
	player.velocity = Vector2.ZERO
	_attack_direction = player.get_mouse_direction()
	player.update_facing_from_angle(_attack_direction)
	player.play_directional_animation("attack")
	_capture_original_hitbox_size()
	_position_hitbox()
	_resize_hitbox()
	player.hitbox.damage = player.get_ability_damage(player.player_stats.get_effective_damage())
	player.hitbox.activate()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	player.hitbox.deactivate()
	player.hitbox.position = Vector2.ZERO
	_restore_hitbox_size()
	player.hitbox.damage = player.player_stats.get_effective_damage()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _position_hitbox() -> void:
	player.hitbox.position = _attack_direction * hitbox_offset

func _capture_original_hitbox_size() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			_original_hitbox_size = rect.size

func _resize_hitbox() -> void:
	var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
	if shape_node:
		var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
		if rect:
			rect.size = hitbox_size

func _restore_hitbox_size() -> void:
	if _original_hitbox_size != Vector2.ZERO:
		var shape_node: CollisionShape2D = player.hitbox.get_child(0) as CollisionShape2D
		if shape_node:
			var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
			if rect:
				rect.size = _original_hitbox_size

func _on_animation_finished() -> void:
	transition_requested.emit(self, &"IdleState")
