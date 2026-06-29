class_name ManaComponent
extends Node

signal mana_changed(current_mana: int, max_mana: int)

@export var max_mana: int = 50
@export var regen_rate: float = 5.0

var current_mana: int = 0
var _regen_accumulator: float = 0.0

func _ready() -> void:
	current_mana = max_mana

func _process(delta: float) -> void:
	if current_mana >= max_mana:
		return
	_regen_accumulator += regen_rate * delta
	if _regen_accumulator >= 1.0:
		var gained: int = int(_regen_accumulator)
		_regen_accumulator -= float(gained)
		current_mana = mini(current_mana + gained, max_mana)
		mana_changed.emit(current_mana, max_mana)

func has_mana(amount: int) -> bool:
	return current_mana >= amount

func use_mana(amount: int) -> bool:
	if current_mana < amount:
		return false
	current_mana -= amount
	mana_changed.emit(current_mana, max_mana)
	return true
