extends HBoxContainer

var _slots: Array[AbilitySlot] = []

func _ready() -> void:
	_build_slots()
	EventBus.ability_cooldown_started.connect(_on_ability_cooldown_started)

func _build_slots() -> void:
	var key_labels: Array[String] = ["Q", "E", "R"]
	for i: int in 3:
		var slot: AbilitySlot = AbilitySlot.new()
		slot.key_label_text = key_labels[i]
		add_child(slot)
		_slots.append(slot)

func _on_ability_cooldown_started(ability_index: int, duration: float) -> void:
	if ability_index >= 0 and ability_index < _slots.size():
		_slots[ability_index].start_cooldown(duration)
