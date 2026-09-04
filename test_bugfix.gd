extends Node

var _failures: Array[String] = []
var _died_count: int = 0
var _damaged_count: int = 0

func _ready() -> void:
	_test_projectile_scenes()
	_test_health_dead_guard()
	_test_state_machine_dead_lock()
	_test_ogre_scene_loads()
	_test_entity_scenes_instantiate()
	if _failures.is_empty():
		print("BUGFIX TEST: ALL PASS")
	else:
		for failure: String in _failures:
			print("BUGFIX TEST FAIL: ", failure)
	get_tree().quit(0 if _failures.is_empty() else 1)

func _test_projectile_scenes() -> void:
	var expected_masks: Dictionary = {
		"res://scenes/attacks/arrow.tscn": 9,
		"res://scenes/attacks/player_arrow.tscn": 17,
		"res://scenes/attacks/player_arrow_piercing.tscn": 17,
		"res://scenes/attacks/magic_bolt.tscn": 17,
		"res://scenes/attacks/ice_shard.tscn": 17,
	}
	for path: String in expected_masks:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			_failures.append("failed to load " + path)
			continue
		var projectile: Area2D = packed.instantiate() as Area2D
		add_child(projectile)
		if projectile.collision_mask != int(expected_masks[path]):
			_failures.append("%s collision_mask = %d, expected %d" % [path, projectile.collision_mask, expected_masks[path]])
		if not projectile.body_entered.is_connected(Callable(projectile, "_on_body_entered")):
			_failures.append(path + " body_entered not connected")
		projectile.queue_free()

func _test_health_dead_guard() -> void:
	var hc: HealthComponent = HealthComponent.new()
	hc.max_hp = 10
	hc.i_frame_duration = 0.0
	add_child(hc)
	hc.died.connect(func() -> void: _died_count += 1)
	hc.damaged.connect(func(_amount: int) -> void: _damaged_count += 1)
	hc.take_damage(100)
	if hc.current_hp != 0 or _died_count != 1:
		_failures.append("killing blow: hp=%d died=%d" % [hc.current_hp, _died_count])
	if not hc.is_dead():
		_failures.append("is_dead() false after killing blow")
	hc.take_damage(5)
	if _damaged_count != 1 or _died_count != 1:
		_failures.append("corpse still takes damage: damaged=%d died=%d" % [_damaged_count, _died_count])
	hc.queue_free()

func _test_ogre_scene_loads() -> void:
	var packed: PackedScene = load("res://scenes/enemies/ogre.tscn") as PackedScene
	if packed == null:
		_failures.append("ogre.tscn failed to load")
		return
	var ogre: CharacterBody2D = packed.instantiate() as CharacterBody2D
	if ogre == null:
		_failures.append("ogre.tscn failed to instantiate")
		return
	add_child(ogre)
	var sprite: AnimatedSprite2D = ogre.get_node("AnimatedSprite2D") as AnimatedSprite2D
	for anim: StringName in ["idle_down", "idle_up", "idle_side", "walk_down", "walk_up", "walk_side", "attack_down", "attack_up", "attack_side"]:
		if not sprite.sprite_frames.has_animation(anim):
			_failures.append("ogre missing animation " + anim)
			continue
		for i: int in range(sprite.sprite_frames.get_frame_count(anim)):
			if sprite.sprite_frames.get_frame_texture(anim, i) == null:
				_failures.append("ogre %s frame %d texture null" % [anim, i])
	ogre.queue_free()

func _test_entity_scenes_instantiate() -> void:
	var dir: DirAccess = DirAccess.open("res://scenes/enemies")
	var paths: Array[String] = []
	for file_name: String in dir.get_files():
		if file_name.ends_with(".tscn"):
			paths.append("res://scenes/enemies/" + file_name)
	paths.append("res://scenes/player/player.tscn")
	paths.append("res://scenes/player/player_ranger.tscn")
	paths.append("res://scenes/player/player_mage.tscn")
	for path: String in paths:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			_failures.append("failed to load " + path)
			continue
		var inst: Node = packed.instantiate()
		if inst == null:
			_failures.append("failed to instantiate " + path)
			continue
		add_child(inst)
		inst.queue_free()

func _test_state_machine_dead_lock() -> void:
	var sm: StateMachine = StateMachine.new()
	var dead: State = State.new()
	dead.name = "DeadState"
	var idle: State = State.new()
	idle.name = "IdleState"
	sm.add_child(dead)
	sm.add_child(idle)
	add_child(sm)
	sm.start(&"DeadState")
	sm.transition_to(&"IdleState")
	if sm.current_state == null or sm.current_state.name != &"DeadState":
		_failures.append("StateMachine allowed transition out of DeadState")
	sm.queue_free()
