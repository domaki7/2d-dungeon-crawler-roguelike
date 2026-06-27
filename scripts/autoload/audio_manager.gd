extends Node

const SFX_POOL_SIZE: int = 8

@export var sfx_volume_db: float = -5.0
@export var music_volume_db: float = -10.0

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _music_player: AudioStreamPlayer
var _sfx_cache: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_sfx_pool()
	_create_music_player()

func play_sfx(sfx_name: StringName) -> void:
	var stream: AudioStream = _load_sfx(sfx_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_pool[_sfx_index]
	player.stream = stream
	player.volume_db = sfx_volume_db
	player.play()
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE

func play_music(music_name: StringName, fade_duration: float = 1.0) -> void:
	var stream: AudioStream = _load_music(music_name)
	if stream == null:
		return
	if _music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -40.0, fade_duration * 0.5)
		await tween.finished
	_music_player.stream = stream
	_music_player.volume_db = -40.0
	_music_player.play()
	var fade_in: Tween = create_tween()
	fade_in.tween_property(_music_player, "volume_db", music_volume_db, fade_duration * 0.5)

func stop_music(fade_duration: float = 0.5) -> void:
	if not _music_player.playing:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
	tween.tween_callback(_music_player.stop)

func _create_sfx_pool() -> void:
	for i: int in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_sfx_pool.append(player)

func _create_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Master"
	_music_player.volume_db = music_volume_db
	add_child(_music_player)

func _load_sfx(sfx_name: StringName) -> AudioStream:
	if _sfx_cache.has(sfx_name):
		return _sfx_cache[sfx_name] as AudioStream
	var path: String = "res://assets/audio/sfx/%s.wav" % sfx_name
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/%s.ogg" % sfx_name
		if not ResourceLoader.exists(path):
			return null
	var stream: AudioStream = load(path) as AudioStream
	_sfx_cache[sfx_name] = stream
	return stream

func _load_music(music_name: StringName) -> AudioStream:
	var path: String = "res://assets/audio/music/%s.ogg" % music_name
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/%s.wav" % music_name
		if not ResourceLoader.exists(path):
			return null
	return load(path) as AudioStream
