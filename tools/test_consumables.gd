extends Node
## Headless regression check for the potion belt, gold magnet, Fire Wall
## re-ticking and treasure-room choice pedestals.
##
## Run:
##   Godot_v4.7-stable_win64.exe --headless --path . res://tools/test_consumables.tscn --quit-after 900
##
## Prints `_ok=true/false` at the end so a build script can grep for failure.

var _failures: PackedStringArray = PackedStringArray()


func _ready() -> void:
	_run.call_deferred()


func _check(label: String, condition: bool) -> void:
	print("%-46s %s" % [label, "PASS" if condition else "FAIL"])
	if not condition:
		_failures.append(label)


func _run() -> void:
	await _wait(2)

	# --- resources load and are shaped right ---------------------------------
	for id: String in ["health_potion", "greater_health_potion", "rage_potion", "swiftness_potion", "antidote"]:
		var item: ItemData = load("res://resources/items/consumables/%s.tres" % id) as ItemData
		_check("%s loads" % id, item != null)
		if item == null:
			continue
		_check("%s is a consumable" % id, item.is_consumable())
		_check("%s has an icon" % id, item.icon != null)
		_check("%s has an effect" % id, item.consumable_effect != ItemData.ConsumableEffect.NONE)

	var magnet: ItemData = load("res://resources/items/accessories/magnet_charm.tres") as ItemData
	_check("magnet charm loads", magnet != null and magnet.effect_id == &"gold_magnet")

	# --- boot a real run -----------------------------------------------------
	GameManager.start_run(GameManager.PlayerClass.WARRIOR)
	await _wait(120)

	var player: CharacterBody2D = get_tree().get_first_node_in_group(&"player") as CharacterBody2D
	_check("player spawned", player != null)
	if player == null:
		_finish()
		return

	var belt: ConsumableBelt = player.get_node_or_null("ConsumableBelt") as ConsumableBelt
	var health: HealthComponent = player.get_node("HealthComponent") as HealthComponent
	var stats: PlayerStats = player.get_node("PlayerStats") as PlayerStats
	_check("player carries a belt", belt != null)
	if belt == null:
		_finish()
		return

	# --- belt stacking rules -------------------------------------------------
	_check(
		"run starts with a potion in the belt",
		belt.count == GameConfig.config.run_starting_potion_count
			and belt.item == ConsumablePool.HEALTH_POTION
	)
	while not belt.is_empty():
		belt.count -= 1
	belt.item = null
	_check("belt empties for the stacking checks", belt.is_empty())
	var potion: ItemData = ConsumablePool.HEALTH_POTION
	_check("belt accepts a potion", belt.add(potion))
	_check("belt holds one", belt.count == 1)
	_check("belt stacks the same potion", belt.add(potion))
	_check("belt count is two", belt.count == 2)
	_check("belt refuses a different potion", not belt.can_add(ConsumablePool.RAGE_POTION))
	while belt.count < potion.max_stack:
		belt.add(potion)
	_check("belt refuses past its stack cap", not belt.can_add(potion))

	# --- healing ------------------------------------------------------------
	# The starting room spawns live enemies, and a stray hit during boot would
	# race every assertion below (the player arrives already wounded and
	# holding i-frames). Clear the room and reset to a known state first.
	for enemy: Node in get_tree().get_nodes_in_group(&"enemies"):
		enemy.queue_free()
	await _wait(4)
	health.heal(health.max_hp)
	await _wait_until_vulnerable(health)

	_check("player starts at full HP", health.current_hp == health.max_hp)
	_check("full-HP drink is refused", not belt.use_item())
	var before_count: int = belt.count
	health.take_damage(health.max_hp - 1)
	await _wait(2)
	_check("player is hurt", health.current_hp < health.max_hp)
	var hp_before: int = health.current_hp
	_check("wounded drink succeeds", belt.use_item())
	_check("drink consumed one potion", belt.count == before_count - 1)
	_check("drink healed the player", health.current_hp > hp_before)

	# --- buff potions feed the temp-stat pipeline ---------------------------
	var base_damage: int = stats.get_effective_damage()
	var base_speed: float = stats.get_effective_speed()
	while not belt.is_empty():
		belt.use_item()
		health.take_damage(1)
		await _wait(2)
	_check("belt empties out", belt.is_empty())
	belt.add(ConsumablePool.RAGE_POTION)
	_check("rage potion drinks", belt.use_item())
	_check("rage potion raises damage", stats.get_effective_damage() > base_damage)
	belt.add(ConsumablePool.SWIFTNESS_POTION)
	_check("swiftness potion drinks", belt.use_item())
	_check("swiftness potion raises speed", stats.get_effective_speed() > base_speed)
	stats.clear_temp_buffs()
	await _wait(2)
	_check("buffs expire back to base", stats.get_effective_damage() == base_damage)

	# --- gold magnet --------------------------------------------------------
	var gold: Area2D = preload("res://scenes/pickups/gold_pickup.tscn").instantiate() as Area2D
	var world: Node = get_tree().get_first_node_in_group(&"game_world")
	_check("game world exists", world != null)
	if world:
		world.add_child(gold)
		# Just inside the base magnet radius, offset so it has ground to cover.
		var offset: float = GameConfig.config.economy_gold_magnet_base_radius - 4.0
		gold.global_position = player.global_position + Vector2(offset, 0.0)
		var start_distance: float = gold.global_position.distance_to(player.global_position)
		await _wait(6)
		var moved: bool = not is_instance_valid(gold) \
			or gold.global_position.distance_to(player.global_position) < start_distance
		_check("gold drifts toward the player", moved)
		if is_instance_valid(gold):
			gold.queue_free()

	# --- Fire Wall re-ticks instead of hitting once -------------------------
	var wall_scene: PackedScene = preload("res://scenes/effects/fire_wall_zone.tscn")
	var wall: Node2D = wall_scene.instantiate() as Node2D
	if world:
		world.add_child(wall)
		wall.global_position = player.global_position + Vector2(0.0, 200.0)
		wall.setup(1, 0.0, 72.0, 20.0, 5.0, 0.4, null)
		await _wait(2)
		var hitbox: Hitbox = null
		for child: Node in wall.get_children():
			if child is Hitbox:
				hitbox = child as Hitbox
		_check("fire wall builds a hitbox", hitbox != null)
		_check("fire wall exposes refresh_targets", hitbox != null and hitbox.has_method("refresh_targets"))
		var particles: GPUParticles2D = wall.get_node_or_null("Particles") as GPUParticles2D
		var mat: ParticleProcessMaterial = particles.process_material as ParticleProcessMaterial if particles else null
		_check(
			"fire wall flames match the hitbox",
			mat != null and is_equal_approx(mat.emission_box_extents.x, 36.0)
		)
		wall.queue_free()

	# --- does the wall keep hurting what stands in it? -----------------------
	# Guards the re-tick itself: a damage zone that only fires area_entered
	# once would hit each target a single time, on entry, and the Fire Wall
	# would read as a decorative sprite. Verified sensitive: with the re-tick
	# removed entirely this counts exactly 1.
	if world:
		var dummy: Node2D = _make_dummy_target()
		world.add_child(dummy)
		dummy.global_position = player.global_position + Vector2(0.0, 260.0)
		await _wait(2)
		var dummy_hp: HealthComponent = dummy.get_node("HealthComponent") as HealthComponent
		var ticks: Array[int] = [0]
		dummy_hp.damaged.connect(func(_amount: int) -> void: ticks[0] += 1)

		var burner: Node2D = wall_scene.instantiate() as Node2D
		world.add_child(burner)
		burner.global_position = dummy.global_position
		burner.setup(1, 0.0, 72.0, 20.0, 6.0, 0.4, null)
		# Generous frame budget: hit-pause scales delta, so wall-clock and
		# frame count do not line up one to one.
		await _wait(240)
		_check("fire wall damages a target standing in it", ticks[0] >= 1)
		_check("fire wall re-ticks instead of hitting once", ticks[0] >= 3)
		_check("target actually lost health", dummy_hp.current_hp < dummy_hp.max_hp)
		print("    (fire wall landed %d damage ticks)" % ticks[0])
		burner.queue_free()
		dummy.queue_free()

	# --- Fire Wall is worth its mana ----------------------------------------
	var fire_wall: AbilityData = load("res://resources/abilities/fire_wall.tres") as AbilityData
	# Guards the GameConfig overlay itself: it used to mutate resources it did
	# not keep a reference to, so every tuning value was quietly discarded
	# before the scenes loaded their own copy off disk.
	_check(
		"ability tuning overlay reaches resources",
		fire_wall != null
			and fire_wall.damage == GameConfig.config.ability_fire_wall_damage
			and fire_wall.mana_cost == GameConfig.config.ability_fire_wall_mana_cost
			and is_equal_approx(fire_wall.wall_length, GameConfig.config.ability_fire_wall_length)
	)
	_check("fire wall is worth its mana", fire_wall != null and fire_wall.damage >= 4 and fire_wall.mana_cost <= 18)

	# --- HUD, floor pickups and shop stock -----------------------------------
	var belt_slots: int = 0
	for node: Node in _descendants(get_tree().root):
		if node is BeltSlot:
			belt_slots += 1
	_check("HUD shows a belt slot", belt_slots == 1)

	if world:
		while not belt.is_empty():
			belt.count -= 1
		belt.item = null
		var pickup: ItemPickup = preload("res://scenes/pickups/item_pickup.tscn").instantiate() as ItemPickup
		pickup.item_data = ConsumablePool.SWIFTNESS_POTION
		world.add_child(pickup)
		pickup.global_position = player.global_position
		await _wait(6)
		_check("walking over a potion belts it", not belt.is_empty())
		_check("the pickup is consumed", not is_instance_valid(pickup))

	var shop: ShopNPC = preload("res://scenes/interactables/shop_npc.tscn").instantiate() as ShopNPC
	add_child(shop)
	await _wait(2)
	var stocks_potion: bool = false
	for stocked: ItemData in shop.shop_items:
		if stocked != null and stocked.is_consumable():
			stocks_potion = true
	_check("shops stock consumables", stocks_potion)
	shop.queue_free()

	# --- treasure room forces a choice --------------------------------------
	var treasure: Node2D = preload("res://scenes/rooms/treasure_room.tscn").instantiate() as Node2D
	if world:
		world.add_child(treasure)
		await _wait(4)
		var chests: Array[Chest] = []
		for child: Node in treasure.get_children():
			if child is Chest:
				chests.append(child as Chest)
		_check("treasure room has two chests", chests.size() == 2)
		if chests.size() == 2:
			chests[0].opened.emit()
			await _wait(2)
			_check("picking one seals the other", chests[1].is_opened())
		treasure.queue_free()

	# Let the queue_free()d probes actually die before quitting.
	await _wait(4)
	_finish()


func _finish() -> void:
	print("_ok=%s" % ("true" if _failures.is_empty() else "false"))
	if not _failures.is_empty():
		print("failed: %s" % ", ".join(_failures))
	get_tree().quit()


func _wait(frames: int) -> void:
	for i: int in frames:
		await get_tree().process_frame

func _descendants(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in root.get_children():
		out.append(child)
		out.append_array(_descendants(child))
	return out

## Minimal stand-in for an enemy: a hurtbox on the EnemyHurtbox layer (5)
## feeding a HealthComponent, with no AI to wander out of the flames.
func _make_dummy_target() -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = "FireWallDummy"

	var health: HealthComponent = HealthComponent.new()
	health.name = "HealthComponent"
	health.max_hp = 9999
	health.i_frame_duration = 0.2
	root.add_child(health)

	var hurtbox: Hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 0
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(12.0, 12.0)
	shape.shape = rect
	hurtbox.add_child(shape)
	root.add_child(hurtbox)
	return root

## HealthComponent ignores damage during i-frames, so a test that damages
## the player has to wait them out or the hit silently does nothing.
func _wait_until_vulnerable(health: HealthComponent) -> void:
	var guard: int = 0
	while health.is_invincible() and guard < 120:
		guard += 1
		await get_tree().process_frame
