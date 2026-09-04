extends Node

enum GameState { TITLE, RUN, POST_RUN }
enum PlayerClass { WARRIOR, RANGER, MAGE }

var current_state: int = GameState.TITLE
var selected_class: int = PlayerClass.WARRIOR

var _title_screen_layer: CanvasLayer = null
var _run_summary_layer: CanvasLayer = null

func _ready() -> void:
	EventBus.run_ended.connect(_on_run_ended)

func show_title_screen() -> void:
	current_state = GameState.TITLE
	RunManager.cleanup_game()
	_clear_ui()
	# The menu gets the first floor's calm stem — familiar the moment you start.
	_silence_run_audio()
	AudioManager.play_layered_music(&"theme_halls")
	_title_screen_layer = CanvasLayer.new()
	_title_screen_layer.layer = 50
	get_tree().root.add_child(_title_screen_layer)
	var title_scene: PackedScene = load("res://scenes/ui/title_screen.tscn") as PackedScene
	var title_screen: Control = title_scene.instantiate() as Control
	_title_screen_layer.add_child(title_screen)

func start_run(player_class: int = PlayerClass.WARRIOR, difficulty: int = 0) -> void:
	selected_class = player_class
	current_state = GameState.RUN
	_clear_ui()
	RunManager.start_run(player_class, difficulty)

func show_run_summary(victory: bool, stats: Dictionary) -> void:
	current_state = GameState.POST_RUN
	_run_summary_layer = CanvasLayer.new()
	_run_summary_layer.layer = 60
	get_tree().root.add_child(_run_summary_layer)
	var summary_scene: PackedScene = load("res://scenes/ui/run_summary_screen.tscn") as PackedScene
	var summary_screen: Control = summary_scene.instantiate() as Control
	_run_summary_layer.add_child(summary_screen)
	summary_screen.setup(victory, stats)

func return_to_title() -> void:
	RunManager.cleanup_game()
	_clear_ui()
	show_title_screen()

func _clear_ui() -> void:
	if _title_screen_layer and is_instance_valid(_title_screen_layer):
		_title_screen_layer.queue_free()
		_title_screen_layer = null
	if _run_summary_layer and is_instance_valid(_run_summary_layer):
		_run_summary_layer.queue_free()
		_run_summary_layer = null

func _on_run_ended(victory: bool, stats: Dictionary) -> void:
	_silence_run_audio()
	show_run_summary(victory, stats)

## Drop everything the run layered on top of the music: the combat stem, the
## dungeon room tone, and the low-HP heartbeat.
func _silence_run_audio() -> void:
	AudioManager.set_combat_intensity(false)
	AudioManager.set_heartbeat(false)
	AudioManager.stop_ambience()
