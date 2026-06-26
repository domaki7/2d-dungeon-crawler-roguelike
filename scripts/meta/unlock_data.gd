class_name UnlockData
extends Resource

enum UnlockCategory { WEAPON, ITEM, ABILITY }

@export var unlock_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 0
@export var category: UnlockCategory = UnlockCategory.WEAPON

@export_group("Granted Content")
@export var granted_item: ItemData
@export var granted_ability: Resource
