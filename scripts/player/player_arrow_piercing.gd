extends "res://scripts/player/player_arrow.gd"

var _original_damage: int = 0
var _hit_count_internal: int = 0

func setup(direction: Vector2, base_damage: int) -> void:
	super.setup(direction, base_damage)
	_original_damage = base_damage
	_hit_count_internal = 0

func _on_area_entered(area: Area2D) -> void:
	var hurtbox: Hurtbox = area as Hurtbox
	if hurtbox == null:
		return
	if has_hit(hurtbox.get_parent()):
		return
	register_hit(hurtbox.get_parent())
	if _hit_count_internal == 0:
		damage = _original_damage
	else:
		damage = int(float(_original_damage) * GameConfig.config.ranger_charged_shot_pierce_damage_falloff)
	hurtbox.receive_hit(self)
	hit_landed.emit(hurtbox)
	VFXHelper.spawn_hit_sparks(global_position)
	_hit_count_internal += 1
	if _hit_count_internal > GameConfig.config.ranger_charged_shot_pierce_count:
		_hit = true
		queue_free()
