class_name StateMachine
extends Node

var current_state: State = null
var states: Dictionary = {}

func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			states[child.name] = child
			child.transition_requested.connect(_on_transition_requested)

func start(initial_state_name: StringName) -> void:
	if states.has(initial_state_name):
		current_state = states[initial_state_name]
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.process_state(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process_state(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(target_state_name: StringName) -> void:
	if not states.has(target_state_name):
		push_warning("StateMachine: state '%s' not found" % target_state_name)
		return
	if current_state:
		current_state.exit()
	current_state = states[target_state_name]
	current_state.enter()

func _on_transition_requested(_from: State, to: StringName) -> void:
	transition_to(to)
