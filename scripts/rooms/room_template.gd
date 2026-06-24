class_name RoomTemplate
extends Node2D

signal room_cleared_signal

@export var room_id: int = 1
@export var is_combat_room: bool = true
@export var auto_lock_doors: bool = true

@onready var doors_container: Node2D = $Doors
@onready var spawn_points_container: Node2D = $SpawnPoints
@onready var player_spawn: Marker2D = $PlayerSpawn

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
	for sp_node: Node in spawn_points_container.get_children():
		var sp: SpawnPoint = sp_node as SpawnPoint
		if sp == null:
			continue
		var enemy: Node2D = sp.spawn()
		if enemy:
			add_child(enemy)
			_enemies_alive += 1
			if enemy.has_node("HealthComponent"):
				var hc: HealthComponent = enemy.get_node("HealthComponent") as HealthComponent
				hc.died.connect(_on_enemy_died)

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

func _on_enemy_died() -> void:
	_enemies_alive -= 1
	if _enemies_alive <= 0 and not _is_cleared:
		_is_cleared = true
		_unlock_all_doors()
		room_cleared_signal.emit()
		EventBus.room_cleared.emit(room_id)
		EventBus.all_enemies_dead.emit()

func _on_door_entered(_door: Door) -> void:
	pass
