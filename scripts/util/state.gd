class_name State
extends Node

signal transition_requested(from: State, to: StringName)

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_state(delta: float) -> void:
	pass

func physics_process_state(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
