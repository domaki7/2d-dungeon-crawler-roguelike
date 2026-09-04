extends Node
## Pooled SFX playback plus a vertically-layered music system.
##
## Each floor theme ships as two stems of identical length and tempo:
## `<track>_base` (drones, pads, plucks) and `<track>_layer` (drums, bass,
## lead). Both players start on the same frame and never restart, so fading
## the layer in and out follows the fight without ever cutting the music.
## A separate ambience bed and a low-HP heartbeat sit under all of it.

const SFX_POOL_SIZE: int = 8
## Effectively silent, but still a real volume so tweens interpolate smoothly.
const SILENT_DB: float = -60.0

## Names with no file of their own, remapped onto a sound that fits.
const _SFX_FALLBACKS: Dictionary = {
	&"attack": &"swing",
	&"cave_ambience": &"door_lock",
	&"parry": &"shield_bash",
	&"ui_unlock": &"chime",
	&"potion_drink": &"chime",
}

var sfx_volume_db: float:
	get: return GameConfig.config.audio_sfx_volume_db
var music_volume_db: float:
	get: return GameConfig.config.audio_music_volume_db
var sfx_pitch_min: float:
	get: return GameConfig.config.audio_sfx_pitch_min
var sfx_pitch_max: float:
	get: return GameConfig.config.audio_sfx_pitch_max

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _music_base: AudioStreamPlayer
var _music_layer: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _heartbeat: AudioStreamPlayer
var _sfx_cache: Dictionary = {}
var _music_cache: Dictionary = {}
var _music_volume_offset_db: float = 0.0
var _current_track: StringName = &""
var _has_layer: bool = false
var _combat_intensity: bool = false
var _base_tween: Tween = null
var _layer_tween: Tween = null
var _ambience_tween: Tween = null
var _heartbeat_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_sfx_pool()
	_create_music_players()

# ------------------------------------------------------------------------ SFX

func play_sfx(sfx_name: StringName) -> void:
	var stream: AudioStream = _load_sfx(sfx_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_pool[_sfx_index]
	player.stream = stream
	player.volume_db = sfx_volume_db
	player.pitch_scale = 1.0
	player.play()
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE

func play_sfx_varied(
	sfx_name: StringName,
	pitch_min: float = -1.0,
	pitch_max: float = -1.0,
	volume_offset_db: float = 0.0
) -> void:
	if pitch_min < 0.0:
		pitch_min = sfx_pitch_min
	if pitch_max < 0.0:
		pitch_max = sfx_pitch_max
	var stream: AudioStream = _load_sfx(sfx_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_pool[_sfx_index]
	player.stream = stream
	player.volume_db = sfx_volume_db + volume_offset_db
	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.play()
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE

# ---------------------------------------------------------------------- music

## Start a two-stem theme. Falls back to single-stream playback when no
## `<track>_base` file exists, so legacy track names still work.
func play_layered_music(track: StringName, fade_duration: float = 1.5) -> void:
	if track == _current_track and _music_base.playing:
		return
	var base_stream: AudioStream = _load_music(StringName("%s_base" % track))
	if base_stream == null:
		play_music(track, fade_duration)
		return

	_current_track = track
	var layer_stream: AudioStream = _load_music(StringName("%s_layer" % track))
	_has_layer = layer_stream != null

	_kill_music_tweens()
	if _music_base.playing or _music_layer.playing:
		var out: Tween = create_tween().set_parallel()
		out.tween_property(_music_base, "volume_db", SILENT_DB, fade_duration * 0.4)
		out.tween_property(_music_layer, "volume_db", SILENT_DB, fade_duration * 0.4)
		await out.finished
		# A newer request may have landed while we were fading out.
		if _current_track != track:
			return

	_music_base.stream = base_stream
	_music_base.pitch_scale = 1.0
	_music_base.volume_db = SILENT_DB
	_music_layer.stream = layer_stream
	_music_layer.pitch_scale = 1.0
	_music_layer.volume_db = SILENT_DB
	# Both start in the same frame so the stems stay sample-aligned forever.
	_music_base.play()
	if _has_layer:
		_music_layer.play()
	else:
		_music_layer.stop()
	_music_volume_offset_db = 0.0
	_apply_music_targets(fade_duration * 0.6)

## Crossfade the combat stem in or out. Cheap to call repeatedly — a request
## matching the current state is a no-op.
func set_combat_intensity(active: bool) -> void:
	if active == _combat_intensity:
		return
	_combat_intensity = active
	if not _has_layer:
		return
	var duration: float = (
		GameConfig.config.audio_combat_layer_fade_in
		if active
		else GameConfig.config.audio_combat_layer_fade_out
	)
	if _layer_tween:
		_layer_tween.kill()
	_layer_tween = create_tween()
	_layer_tween.tween_property(_music_layer, "volume_db", _layer_target_db(), duration)

func is_combat_intensity_active() -> bool:
	return _combat_intensity

## Single-stream playback, kept for the title screen and legacy track names.
func play_music(music_name: StringName, fade_duration: float = 1.0, pitch_scale: float = 1.0, volume_offset_db: float = 0.0) -> void:
	var stream: AudioStream = _load_music(music_name)
	if stream == null:
		return
	_current_track = music_name
	_has_layer = false
	_combat_intensity = false
	_kill_music_tweens()
	if _music_layer.playing:
		_music_layer.stop()
	if _music_base.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_music_base, "volume_db", SILENT_DB, fade_duration * 0.5)
		await tween.finished
		if _current_track != music_name:
			return
	_music_volume_offset_db = volume_offset_db
	_music_base.stream = stream
	_music_base.volume_db = SILENT_DB
	_music_base.pitch_scale = pitch_scale
	_music_base.play()
	_apply_music_targets(fade_duration * 0.5)

func stop_music(fade_duration: float = 0.5) -> void:
	_current_track = &""
	_combat_intensity = false
	_kill_music_tweens()
	for player: AudioStreamPlayer in [_music_base, _music_layer]:
		if not player.playing:
			continue
		var tween: Tween = create_tween()
		tween.tween_property(player, "volume_db", SILENT_DB, fade_duration)
		tween.tween_callback(player.stop)

# ------------------------------------------------------------------- ambience

## Quiet looping room tone that sits under the music for the whole run.
func start_ambience(fade_duration: float = 2.0) -> void:
	if _ambience.playing:
		return
	var stream: AudioStream = _load_music(&"ambience_bed")
	if stream == null:
		return
	_ambience.stream = stream
	_ambience.volume_db = SILENT_DB
	_ambience.play()
	if _ambience_tween:
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience, "volume_db", _ambience_target_db(), fade_duration)

func stop_ambience(fade_duration: float = 1.0) -> void:
	if not _ambience.playing:
		return
	if _ambience_tween:
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.tween_property(_ambience, "volume_db", SILENT_DB, fade_duration)
	_ambience_tween.tween_callback(_ambience.stop)

# ------------------------------------------------------------------ heartbeat

## Looping pulse for the low-HP warning state. `rate` scales playback speed,
## so a more urgent threshold can beat faster.
func set_heartbeat(active: bool, rate: float = 1.0) -> void:
	if active:
		var stream: AudioStream = _load_sfx(&"heartbeat")
		if stream == null:
			return
		_heartbeat.pitch_scale = rate
		if not _heartbeat.playing:
			_heartbeat.stream = stream
			_heartbeat.volume_db = SILENT_DB
			_heartbeat.play()
		if _heartbeat_tween:
			_heartbeat_tween.kill()
		_heartbeat_tween = create_tween()
		_heartbeat_tween.tween_property(_heartbeat, "volume_db", _heartbeat_target_db(), 0.6)
	else:
		if not _heartbeat.playing:
			return
		if _heartbeat_tween:
			_heartbeat_tween.kill()
		_heartbeat_tween = create_tween()
		_heartbeat_tween.tween_property(_heartbeat, "volume_db", SILENT_DB, 0.5)
		_heartbeat_tween.tween_callback(_heartbeat.stop)

# -------------------------------------------------------------------- volumes

func set_sfx_volume(db: float) -> void:
	GameConfig.config.audio_sfx_volume_db = db

func set_music_volume(db: float) -> void:
	GameConfig.config.audio_music_volume_db = db
	_apply_music_targets(0.0)
	if _ambience.playing:
		_ambience.volume_db = _ambience_target_db()
	if _heartbeat.playing:
		_heartbeat.volume_db = _heartbeat_target_db()

# ------------------------------------------------------------------- internal

func _base_target_db() -> float:
	return music_volume_db + _music_volume_offset_db

func _layer_target_db() -> float:
	if not _combat_intensity:
		return SILENT_DB
	return music_volume_db + GameConfig.config.audio_combat_layer_volume_offset_db

func _ambience_target_db() -> float:
	return music_volume_db + GameConfig.config.audio_ambience_volume_offset_db

func _heartbeat_target_db() -> float:
	return sfx_volume_db + GameConfig.config.audio_heartbeat_volume_offset_db

## Move both music players toward their current targets. A zero duration snaps,
## which is what the volume slider wants.
func _apply_music_targets(duration: float) -> void:
	_kill_music_tweens()
	if duration <= 0.0:
		if _music_base.playing:
			_music_base.volume_db = _base_target_db()
		if _music_layer.playing:
			_music_layer.volume_db = _layer_target_db()
		return
	if _music_base.playing:
		_base_tween = create_tween()
		_base_tween.tween_property(_music_base, "volume_db", _base_target_db(), duration)
	if _music_layer.playing:
		_layer_tween = create_tween()
		_layer_tween.tween_property(_music_layer, "volume_db", _layer_target_db(), duration)

func _kill_music_tweens() -> void:
	if _base_tween:
		_base_tween.kill()
		_base_tween = null
	if _layer_tween:
		_layer_tween.kill()
		_layer_tween = null

func _create_sfx_pool() -> void:
	for i: int in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_sfx_pool.append(player)

func _create_music_players() -> void:
	_music_base = _make_stream_player(music_volume_db)
	_music_layer = _make_stream_player(SILENT_DB)
	_ambience = _make_stream_player(SILENT_DB)
	_heartbeat = _make_stream_player(SILENT_DB)

func _make_stream_player(volume_db: float) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = &"Master"
	player.volume_db = volume_db
	add_child(player)
	return player

func _load_sfx(sfx_name: StringName) -> AudioStream:
	if _sfx_cache.has(sfx_name):
		return _sfx_cache[sfx_name] as AudioStream
	var path: String = "res://assets/audio/sfx/%s.wav" % sfx_name
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/%s.ogg" % sfx_name
		if not ResourceLoader.exists(path):
			if _SFX_FALLBACKS.has(sfx_name):
				return _load_sfx(_SFX_FALLBACKS[sfx_name] as StringName)
			return null
	var stream: AudioStream = load(path) as AudioStream
	_sfx_cache[sfx_name] = stream
	return stream

func _load_music(music_name: StringName) -> AudioStream:
	if _music_cache.has(music_name):
		return _music_cache[music_name] as AudioStream
	var path: String = "res://assets/audio/music/%s.ogg" % music_name
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/%s.wav" % music_name
		if not ResourceLoader.exists(path):
			return null
	var stream: AudioStream = load(path) as AudioStream
	_music_cache[music_name] = stream
	return stream
