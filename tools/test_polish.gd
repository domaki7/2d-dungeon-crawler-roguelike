extends Node
## Headless regression check for the audio/VFX polish pass.
##
## Run:
##   Godot_v4.7-stable_win64.exe --headless --path . res://tools/test_polish.tscn --quit-after 900
##
## Boots a real run and asserts the layered music, ambience bed, heartbeat,
## room motes, drop shadows and decals all come up. Prints `_ok=true/false` at
## the end so a build script can grep for failure.

var _failures: PackedStringArray = PackedStringArray()


func _ready() -> void:
	_run.call_deferred()


func _check(label: String, condition: bool) -> void:
	print("%-46s %s" % [label, "PASS" if condition else "FAIL"])
	if not condition:
		_failures.append(label)


func _run() -> void:
	await _wait(2)

	# --- generated assets exist and loop -------------------------------------
	for track: String in ["theme_halls", "theme_depths", "theme_caverns", "theme_vault", "theme_abyss", "boss"]:
		var base: AudioStreamWAV = load("res://assets/audio/music/%s_base.wav" % track) as AudioStreamWAV
		var layer: AudioStreamWAV = load("res://assets/audio/music/%s_layer.wav" % track) as AudioStreamWAV
		_check("%s stems load" % track, base != null and layer != null)
		if base == null or layer == null:
			continue
		_check("%s stems loop" % track, base.loop_mode != AudioStreamWAV.LOOP_DISABLED and layer.loop_mode != AudioStreamWAV.LOOP_DISABLED)
		# Sample-aligned lengths are what keep the two players in sync forever.
		_check("%s stems same length" % track, absf(base.get_length() - layer.get_length()) < 0.001)

	for sfx: String in ["footstep", "swing", "dodge", "heartbeat", "magic_bolt", "ice_shard", "chain_lightning", "fire_wall", "ogre_charge", "ui_hover", "ui_purchase", "ui_error", "chime"]:
		_check("sfx %s exists" % sfx, ResourceLoader.exists("res://assets/audio/sfx/%s.wav" % sfx))
	var heartbeat: AudioStreamWAV = load("res://assets/audio/sfx/heartbeat.wav") as AudioStreamWAV
	_check("heartbeat loops", heartbeat != null and heartbeat.loop_mode != AudioStreamWAV.LOOP_DISABLED)

	# --- every floor points at a theme that actually exists ------------------
	for i: int in range(1, 8):
		var path: String = "res://resources/floors/floor_%d.tres" % i
		if not ResourceLoader.exists(path):
			continue
		var config: FloorConfig = load(path) as FloorConfig
		_check(
			"floor_%d music_track resolves" % i,
			ResourceLoader.exists("res://assets/audio/music/%s_base.wav" % config.music_track)
		)

	# --- boot a real run -----------------------------------------------------
	GameManager.start_run(GameManager.PlayerClass.WARRIOR)
	await _wait(120)

	_check("run is active", RunManager.run_active)

	var player: Node = get_tree().get_first_node_in_group(&"player")
	_check("player spawned", player != null)
	if player:
		_check("player has drop shadow", player.get_node_or_null("DropShadow") != null)

	_check("music base playing", _player_is_playing("_music_base"))
	_check("ambience bed playing", _player_is_playing("_ambience"))

	# The combat stem must be running from the start — it is faded, never
	# restarted, which is what keeps it sample-aligned with the base stem.
	_check("combat layer stream running", _player_is_playing("_music_layer"))
	# ...but silent until something aggroes.
	_check("combat layer starts idle", not AudioManager.is_combat_intensity_active())
	AudioManager.set_combat_intensity(true)
	_check("combat layer engages", AudioManager.is_combat_intensity_active())
	# No enemy is aggroed, so DungeonManager's poll should settle it back down
	# once the calm delay elapses. Wait longer than that delay plus one poll.
	await _wait(int((GameConfig.config.audio_combat_calm_delay + 0.5) * 60.0))
	_check("combat layer calms down", not AudioManager.is_combat_intensity_active())

	AudioManager.set_heartbeat(true)
	await _wait(4)
	_check("heartbeat starts", _player_is_playing("_heartbeat"))
	AudioManager.set_heartbeat(false)

	var motes: int = 0
	var shadows: int = 0
	for node: Node in _descendants(get_tree().root):
		if node is GPUParticles2D and node.name.begins_with("DustMotes"):
			motes += 1
		elif node is DropShadow:
			shadows += 1
	_check("room ambient motes spawned", motes >= 1)
	_check("entities carry drop shadows", shadows >= 1)

	VFXHelper.spawn_death_decal(Vector2(40.0, 40.0), Color(0.5, 0.1, 0.1, 0.5))
	await _wait(2)
	var decals: int = 0
	for node: Node in _descendants(get_tree().root):
		if node is DeathDecal:
			decals += 1
	_check("death decal spawns", decals >= 1)

	print("_ok=%s" % ("true" if _failures.is_empty() else "false"))
	if not _failures.is_empty():
		print("failed: %s" % ", ".join(_failures))
	get_tree().quit()


func _player_is_playing(field: String) -> bool:
	var stream_player: AudioStreamPlayer = AudioManager.get(field) as AudioStreamPlayer
	return stream_player != null and stream_player.playing


func _descendants(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in root.get_children():
		out.append(child)
		out.append_array(_descendants(child))
	return out


func _wait(frames: int) -> void:
	for i: int in frames:
		await get_tree().process_frame
