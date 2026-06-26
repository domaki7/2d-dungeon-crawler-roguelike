extends Node

enum GameState { TITLE, RUN, POST_RUN }

var current_state: int = GameState.TITLE

var _title_screen_layer: CanvasLayer = null
var _run_summary_layer: CanvasLayer = null

func _ready() -> void:
	EventBus.run_ended.connect(_on_run_ended)

func show_title_screen() -> void:
	current_state = GameState.TITLE
	RunManager.cleanup_game()
	_clear_ui()
	_title_screen_layer = CanvasLayer.new()
	_title_screen_layer.layer = 50
	get_tree().root.add_child(_title_screen_layer)
	var title_scene: PackedScene = load("res://scenes/ui/title_screen.tscn") as PackedScene
	var title_screen: Control = title_scene.instantiate() as Control
	_title_screen_layer.add_child(title_screen)

func start_run() -> void:
	current_state = GameState.RUN
	_clear_ui()
	RunManager.start_run()

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
	show_run_summary(victory, stats)
