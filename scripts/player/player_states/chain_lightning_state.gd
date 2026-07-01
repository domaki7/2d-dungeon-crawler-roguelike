extends AbilityState

var _lightning_scene: PackedScene = preload("res://scenes/effects/chain_lightning_bolt.tscn")

func enter() -> void:
	super.enter()
	player.mana_component.use_mana(_ability_data.mana_cost)
	var direction: Vector2 = player.get_mouse_direction()
	player.update_facing_from_angle(direction)
	player.play_directional_animation("cast")
	_cast_chain_lightning()
	player.animated_sprite.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	super.exit()
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)

func physics_process_state(_delta: float) -> void:
	player.velocity = player.knockback_component.knockback_velocity
	player.move_and_slide()

func _cast_chain_lightning() -> void:
	var dmg: int = player.get_ability_damage(_ability_data.damage)
	var enemies: Array[Node] = player.get_tree().get_nodes_in_group(&"enemies")
	if enemies.is_empty():
		return

	var first_target: Node2D = _find_nearest_enemy(enemies, player.global_position, _ability_data.cast_range, [])
	if first_target == null:
		return

	var hit_targets: Array[Node2D] = []
	var current_pos: Vector2 = player.global_position
	var current_target: Node2D = first_target

	for i: int in range(_ability_data.bounce_count + 1):
		if current_target == null:
			break
		hit_targets.append(current_target)
		_damage_enemy(current_target, dmg, current_pos)
		_spawn_lightning_bolt(current_pos, current_target.global_position)
		current_pos = current_target.global_position
		current_target = _find_nearest_enemy(enemies, current_pos, _ability_data.bounce_range, hit_targets)

	AudioManager.play_sfx_varied(&"chain_lightning")

func _find_nearest_enemy(enemies: Array[Node], from_pos: Vector2, max_range: float, exclude: Array[Node2D]) -> Node2D:
	var nearest: Node2D = null
	var nearest_dist: float = max_range
	for enemy: Node in enemies:
		var e: Node2D = enemy as Node2D
		if e == null or not is_instance_valid(e) or e in exclude:
			continue
		var hc: Node = e.get_node_or_null("HealthComponent")
		if hc == null or (hc as HealthComponent).current_hp <= 0:
			continue
		var dist: float = from_pos.distance_to(e.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = e
	return nearest

func _damage_enemy(target: Node2D, dmg: int, from_pos: Vector2) -> void:
	var hurtbox_node: Node = target.get_node_or_null("Hurtbox")
	if hurtbox_node == null:
		return
	var hurtbox: Hurtbox = hurtbox_node as Hurtbox
	var temp_hitbox: Hitbox = Hitbox.new()
	temp_hitbox.damage = dmg
	temp_hitbox.knockback_force = _ability_data.knockback_force
	temp_hitbox.collision_layer = 32
	temp_hitbox.collision_mask = 16
	var dir: Vector2 = (target.global_position - from_pos).normalized()
	temp_hitbox.global_position = target.global_position - dir * 4.0
	player.get_parent().add_child(temp_hitbox)
	hurtbox.receive_hit(temp_hitbox)
	temp_hitbox.queue_free()

func _spawn_lightning_bolt(from: Vector2, to: Vector2) -> void:
	var bolt: Line2D = _lightning_scene.instantiate() as Line2D
	bolt.clear_points()
	bolt.add_point(Vector2.ZERO)
	var delta_pos: Vector2 = to - from
	var segments: int = maxi(3, int(delta_pos.length() / 10.0))
	for i: int in range(1, segments):
		var t: float = float(i) / float(segments)
		var point: Vector2 = delta_pos * t
		point.x += randf_range(-3.0, 3.0)
		point.y += randf_range(-3.0, 3.0)
		bolt.add_point(point)
	bolt.add_point(delta_pos)
	bolt.global_position = from
	player.get_parent().add_child(bolt)
	var tween: Tween = bolt.create_tween()
	tween.tween_property(bolt, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bolt.queue_free)

func _on_animation_finished() -> void:
	_transition_to_idle()
