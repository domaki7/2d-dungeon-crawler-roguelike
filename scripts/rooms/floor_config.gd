class_name FloorConfig
extends Resource

@export_group("Room Count")
@export var room_count_min: int = 4
@export var room_count_max: int = 6

@export_group("Combat Rooms")
@export var combat_room_scenes: Array[PackedScene] = []

@export_group("Special Rooms")
@export var has_shop: bool = true
@export var shop_room_scene: PackedScene
@export var has_treasure: bool = true
@export var treasure_room_scene: PackedScene

@export_group("Boss")
@export var has_boss: bool = false
@export var boss_room_scene: PackedScene

@export_group("Branching")
## Probability that each main-path room spawns a side branch (0.0 to 1.0)
@export var branch_chance: float = 0.4
## Maximum number of rooms deep a branch can extend
@export var max_branch_depth: int = 2

@export_group("Difficulty")
@export var enemy_difficulty_multiplier: float = 1.0
