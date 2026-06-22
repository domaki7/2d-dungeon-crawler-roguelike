extends CharacterBody2D

@export var speed: float = 120.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.start(&"IdleState")
