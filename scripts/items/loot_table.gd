class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []
@export_range(0.0, 1.0) var drop_chance: float = 1.0

func roll() -> ItemData:
	if randf() > drop_chance:
		return null
	return _roll_from_entries()

func roll_guaranteed() -> ItemData:
	return _roll_from_entries()

func roll_with_filter(excluded_rarities: Array[int] = []) -> ItemData:
	if randf() > drop_chance:
		return null
	return _roll_filtered(excluded_rarities)

func roll_for_floor(rare_mult: float = 1.0, legendary_mult: float = 0.0, excluded_rarities: Array[int] = []) -> ItemData:
	if randf() > drop_chance:
		return null
	return _roll_weighted(rare_mult, legendary_mult, excluded_rarities)

func roll_guaranteed_for_floor(rare_mult: float = 1.0, legendary_mult: float = 0.0, excluded_rarities: Array[int] = []) -> ItemData:
	return _roll_weighted(rare_mult, legendary_mult, excluded_rarities)

func _roll_from_entries() -> ItemData:
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

func _roll_filtered(excluded_rarities: Array[int]) -> ItemData:
	if entries.is_empty():
		return null
	var total_weight: float = 0.0
	for entry: LootEntry in entries:
		if entry.item and entry.item.rarity as int in excluded_rarities:
			continue
		total_weight += entry.weight
	if total_weight <= 0.0:
		return null
	var roll_value: float = randf() * total_weight
	var cumulative: float = 0.0
	for entry: LootEntry in entries:
		if entry.item and entry.item.rarity as int in excluded_rarities:
			continue
		cumulative += entry.weight
		if roll_value <= cumulative:
			return entry.item
	return null

func _roll_weighted(rare_mult: float, legendary_mult: float, excluded_rarities: Array[int]) -> ItemData:
	if entries.is_empty():
		return null
	var total_weight: float = 0.0
	for entry: LootEntry in entries:
		if entry.item == null:
			continue
		if entry.item.rarity as int in excluded_rarities:
			continue
		var w: float = entry.weight
		if entry.item.rarity == ItemData.Rarity.RARE:
			w *= rare_mult
		elif entry.item.rarity == ItemData.Rarity.LEGENDARY:
			w *= legendary_mult
		total_weight += w
	if total_weight <= 0.0:
		return null
	var roll_value: float = randf() * total_weight
	var cumulative: float = 0.0
	for entry: LootEntry in entries:
		if entry.item == null:
			continue
		if entry.item.rarity as int in excluded_rarities:
			continue
		var w: float = entry.weight
		if entry.item.rarity == ItemData.Rarity.RARE:
			w *= rare_mult
		elif entry.item.rarity == ItemData.Rarity.LEGENDARY:
			w *= legendary_mult
		cumulative += w
		if roll_value <= cumulative:
			return entry.item
	return null
