class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []
@export_range(0.0, 1.0) var drop_chance: float = 1.0

func roll() -> ItemData:
	if randf() > drop_chance:
		return null
	if entries.is_empty():
		return null
	var total_weight: float = 0.0
	for entry: LootEntry in entries:
		total_weight += entry.weight
	if total_weight <= 0.0:
		return null
	var roll_value: float = randf() * total_weight
	var cumulative: float = 0.0
	for entry: LootEntry in entries:
		cumulative += entry.weight
		if roll_value <= cumulative:
			return entry.item
	return entries[entries.size() - 1].item
