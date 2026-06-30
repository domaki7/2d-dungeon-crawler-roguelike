class_name UnlockData
extends Resource

enum UnlockCategory { WEAPON, ITEM, ABILITY, PASSIVE }

@export var unlock_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 0
@export var category: UnlockCategory = UnlockCategory.WEAPON

@export_group("Granted Content")
@export var granted_item: ItemData
@export var granted_ability: Resource

@export_group("Passive Upgrade")
## For PASSIVE category only. Stat key: "max_hp", "gold_find", "crit_chance", "locked_chest_discount"
@export var passive_stat: StringName = &""
## Per-level bonus value (int amount for max_hp, fraction for percentage stats)
@export var passive_value: float = 0.0
## This upgrade's level within its group (1, 2, 3, ...)
@export var passive_level: int = 1
## unlock_id of the prerequisite upgrade (empty = no prerequisite, always level 1)
@export var requires_unlock_id: StringName = &""
