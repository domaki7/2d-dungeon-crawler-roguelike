class_name HealthComponent
extends Node

signal damaged(amount: int)
signal healed(amount: int)
signal died()
signal health_changed(current_hp: int, max_hp: int)

@export var max_hp: int = 10
@export var i_frame_duration: float = 0.5

var current_hp: int
var _i_frame_timer: float = 0.0

func _ready() -> void:
	current_hp = max_hp

func _process(delta: float) -> void:
	if _i_frame_timer > 0.0:
		_i_frame_timer -= delta
		if _i_frame_timer < 0.0:
			_i_frame_timer = 0.0

func is_invincible() -> bool:
	return _i_frame_timer > 0.0

func take_damage(amount: int) -> void:
	if is_invincible():
		return
	current_hp = maxi(0, current_hp - amount)
	_i_frame_timer = i_frame_duration
	damaged.emit(amount)
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		var effect_handler: ItemEffectHandler = get_parent().get_node_or_null("ItemEffectHandler") as ItemEffectHandler
		if effect_handler and effect_handler.has_revive():
			var revive_hp: int = effect_handler.consume_revive()
			current_hp = revive_hp
			_i_frame_timer = 1.0
			healed.emit(revive_hp)
			health_changed.emit(current_hp, max_hp)
			return
		died.emit()

func set_max_hp(new_max: int) -> void:
	var delta: int = new_max - max_hp
	max_hp = new_max
	if delta > 0:
		current_hp = mini(current_hp + delta, max_hp)
	else:
		current_hp = mini(current_hp, max_hp)
	health_changed.emit(current_hp, max_hp)

func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	healed.emit(amount)
	health_changed.emit(current_hp, max_hp)
