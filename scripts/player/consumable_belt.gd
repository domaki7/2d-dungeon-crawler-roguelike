class_name ConsumableBelt
extends Node

## Single-slot potion belt. Holds a stack of one consumable at a time, used
## with the `use_consumable` action. Picking up a different consumable while
## the belt is occupied is refused so the player never silently loses a potion.

var item: ItemData = null
var count: int = 0

var _player: CharacterBody2D = null
var _health_component: HealthComponent = null
var _player_stats: PlayerStats = null
var _status_component: StatusEffectComponent = null

func _ready() -> void:
	await owner.ready
	_player = owner as CharacterBody2D
	_health_component = owner.get_node_or_null("HealthComponent") as HealthComponent
	_player_stats = owner.get_node_or_null("PlayerStats") as PlayerStats
	_status_component = owner.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	_emit_changed()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"use_consumable"):
		return
	if use_item():
		get_viewport().set_input_as_handled()

func is_empty() -> bool:
	return item == null or count <= 0

func get_capacity() -> int:
	return item.max_stack if item else 0

## True when `new_item` would fit — either the belt is empty or it already
## holds that same consumable below its stack cap.
func can_add(new_item: ItemData) -> bool:
	if new_item == null or not new_item.is_consumable():
		return false
	if is_empty():
		return true
	return new_item.item_id == item.item_id and count < item.max_stack

func add(new_item: ItemData) -> bool:
	if not can_add(new_item):
		return false
	if is_empty():
		item = new_item
		count = 1
	else:
		count += 1
	_emit_changed()
	return true

## Returns false (and leaves the stack untouched) when there is nothing to
## drink or the effect would be wasted, so a mistimed keypress costs nothing.
func use_item() -> bool:
	if is_empty() or _player == null:
		return false
	if _health_component == null or _health_component.is_dead():
		return false
	if not _apply_effect(item):
		return false
	count -= 1
	if count <= 0:
		item = null
		count = 0
	AudioManager.play_sfx_varied(&"potion_drink")
	_emit_changed()
	return true

func _apply_effect(consumable: ItemData) -> bool:
	match consumable.consumable_effect:
		ItemData.ConsumableEffect.HEAL:
			return _heal(int(consumable.consumable_value))
		ItemData.ConsumableEffect.HEAL_PERCENT:
			var amount: int = maxi(1, int(_health_component.max_hp * consumable.consumable_value))
			return _heal(amount)
		ItemData.ConsumableEffect.DAMAGE_BUFF:
			_player_stats.apply_temp_buff(
				consumable.item_id, int(consumable.consumable_value), 0.0, consumable.consumable_duration
			)
			_announce_buff(consumable, GameConfig.config.ui_damage_potion_color)
			return true
		ItemData.ConsumableEffect.SPEED_BUFF:
			_player_stats.apply_temp_buff(
				consumable.item_id, 0, consumable.consumable_value, consumable.consumable_duration
			)
			_announce_buff(consumable, GameConfig.config.ui_speed_potion_color)
			return true
		ItemData.ConsumableEffect.CLEANSE:
			if _status_component == null or not _status_component.has_any_effect():
				return false
			_status_component.clear_all()
			return true
	return false

func _heal(amount: int) -> bool:
	if amount <= 0:
		return false
	# Refuse at full HP rather than burning the potion for nothing.
	if _health_component.current_hp >= _health_component.max_hp:
		return false
	_health_component.heal(amount)
	VFXHelper.spawn_heal_burst(_player.global_position)
	return true

func _announce_buff(consumable: ItemData, color: Color) -> void:
	EventBus.player_buff_applied.emit(consumable.display_name, color, consumable.consumable_duration)

func _emit_changed() -> void:
	EventBus.consumable_changed.emit(item, count)
