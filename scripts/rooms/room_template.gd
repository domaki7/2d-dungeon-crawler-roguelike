class_name RoomTemplate
extends Node2D

signal room_cleared_signal

@export var room_id: int = 1
@export var is_combat_room: bool = true
@export var auto_lock_doors: bool = true

@export_group("Room Size")
@export var room_pixel_width: int = 384
@export var room_pixel_height: int = 256

@onready var doors_container: Node2D = $Doors
@onready var spawn_points_container: Node2D = $SpawnPoints
@onready var player_spawn: Marker2D = $PlayerSpawn

var _floor_exit_scene: PackedScene = preload("res://scenes/interactables/floor_exit.tscn")
var _enemies_alive: int = 0
var _is_cleared: bool = false

func _ready() -> void:
	_connect_doors()

func activate(already_cleared: bool = false) -> void:
	if already_cleared:
		_is_cleared = true
	else:
		_populate_enemies()
		if is_combat_room and _enemies_alive > 0 and auto_lock_doors:
			_lock_all_doors()
	EventBus.room_entered.emit(room_id)

func get_player_spawn_position() -> Vector2:
	return player_spawn.global_position

func lock_doors() -> void:
	_lock_all_doors()

func unlock_doors() -> void:
	_unlock_all_doors()

func spawn_ambush(count: int, origin: Vector2) -> void:
	var enemy_pool: Array[PackedScene] = DungeonManager.get_enemy_pool()
	if enemy_pool.is_empty():
		return
	lock_doors()
	for i: int in range(count):
		var scene: PackedScene = enemy_pool.pick_random()
		var enemy: Node2D = scene.instantiate() as Node2D
		var angle: float = TAU * float(i) / float(count)
		var spawn_radius: float = GameConfig.config.pressure_plate_ambush_spawn_radius
		enemy.global_position = origin + Vector2(cos(angle), sin(angle)) * spawn_radius
		add_child(enemy)
		if enemy.has_node("HealthComponent"):
			_enemies_alive += 1
			var hc: HealthComponent = enemy.get_node("HealthComponent") as HealthComponent
			hc.died.connect(_on_enemy_died)

func get_door_spawn_position(from_direction: Door.Direction) -> Vector2:
	var opposite: Door.Direction
	match from_direction:
		Door.Direction.NORTH:
			opposite = Door.Direction.SOUTH
		Door.Direction.SOUTH:
			opposite = Door.Direction.NORTH
		Door.Direction.EAST:
			opposite = Door.Direction.WEST
		Door.Direction.WEST:
			opposite = Door.Direction.EAST
	for door_node: Node in doors_container.get_children():
		var door: Door = door_node as Door
		if door and door.direction == opposite:
			var offset: Vector2 = Vector2.ZERO
			match opposite:
				Door.Direction.NORTH:
					offset = Vector2(0, 24)
				Door.Direction.SOUTH:
					offset = Vector2(0, -24)
				Door.Direction.EAST:
					offset = Vector2(-24, 0)
				Door.Direction.WEST:
					offset = Vector2(24, 0)
			return door.global_position + offset
	return player_spawn.global_position

func _connect_doors() -> void:
	for door_node: Node in doors_container.get_children():
		var door: Door = door_node as Door
		if door:
			door.door_entered.connect(_on_door_entered)

func _populate_enemies() -> void:
	var multiplier: float = DungeonManager.get_difficulty_multiplier()
	var speed_mult: float = DungeonManager.get_speed_multiplier()
	var elite_chance: float = DungeonManager.get_elite_chance()
	var gold_mult: float = DungeonManager.get_gold_multiplier()
	var enemy_pool: Array[PackedScene] = DungeonManager.get_enemy_pool()

	for sp_node: Node in spawn_points_container.get_children():
		var sp: SpawnPoint = sp_node as SpawnPoint
		if sp == null:
			continue

		if sp.use_floor_pool and not enemy_pool.is_empty():
			sp.spawn_scene = enemy_pool.pick_random()

		var enemy: Node2D = sp.spawn()
		if enemy:
			add_child(enemy)
			if enemy.has_node("HealthComponent"):
				_enemies_alive += 1
				var hc: HealthComponent = enemy.get_node("HealthComponent") as HealthComponent
				hc.died.connect(_on_enemy_died)
				if multiplier != 1.0:
					hc.max_hp = maxi(1, int(float(hc.max_hp) * multiplier))
					hc.current_hp = hc.max_hp
			if multiplier != 1.0 and enemy.has_node("Hitbox"):
				var hitbox: Hitbox = enemy.get_node("Hitbox") as Hitbox
				if hitbox:
					hitbox.damage = maxi(1, int(float(hitbox.damage) * multiplier))

			if "difficulty_speed_multiplier" in enemy:
				enemy.difficulty_speed_multiplier = speed_mult
			if "gold_multiplier" in enemy:
				enemy.gold_multiplier = gold_mult

			if elite_chance > 0.0 and randf() < elite_chance and sp.spawn_type != SpawnPoint.SpawnType.BOSS:
				EliteModifier.apply(enemy, sp.spawn_type)

func _lock_all_doors() -> void:
	for door_node: Node in doors_container.get_children():
		var door: Door = door_node as Door
		if door:
			door.lock()

func _unlock_all_doors() -> void:
	for door_node: Node in doors_container.get_children():
		var door: Door = door_node as Door
		if door:
			door.unlock()

func _spawn_floor_exit() -> void:
	var exit: FloorExit = _floor_exit_scene.instantiate() as FloorExit
	exit.position = Vector2(room_pixel_width / 2.0, room_pixel_height / 2.0)
	add_child(exit)
	exit.activate()

func _on_enemy_died() -> void:
	_enemies_alive -= 1
	if _enemies_alive <= 0 and not _is_cleared:
		_is_cleared = true
		_unlock_all_doors()
		room_cleared_signal.emit()
		EventBus.room_cleared.emit(room_id)
		EventBus.all_enemies_dead.emit()
		if DungeonManager.is_final_room(room_id):
			_spawn_floor_exit()

func _on_door_entered(_door: Door) -> void:
	pass
