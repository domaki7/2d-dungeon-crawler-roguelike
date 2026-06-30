class_name SpikeTrap
extends Node2D

enum Phase { DISARMED, TELEGRAPH, ARMED }

@export var applied_status_effect: StatusEffectData = null

var _damage: int:
	get: return GameConfig.config.spike_trap_damage
var _knockback_force: float:
	get: return GameConfig.config.spike_trap_knockback_force
var _telegraph_duration: float:
	get: return GameConfig.config.spike_trap_telegraph_duration
var _armed_duration: float:
	get: return GameConfig.config.spike_trap_armed_duration
var _disarmed_duration: float:
	get: return GameConfig.config.spike_trap_disarmed_duration

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _hitbox: Hitbox = $Hitbox

var _phase: Phase = Phase.DISARMED
var _phase_timer: float = 0.0

func _ready() -> void:
	_hitbox.damage = _damage
	_hitbox.knockback_force = _knockback_force
	_hitbox.applied_status_effect = applied_status_effect
	_enter_phase(Phase.DISARMED)

func _process(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer <= 0.0:
		match _phase:
			Phase.DISARMED:
				_enter_phase(Phase.TELEGRAPH)
			Phase.TELEGRAPH:
				_enter_phase(Phase.ARMED)
			Phase.ARMED:
				_enter_phase(Phase.DISARMED)

func _enter_phase(phase: Phase) -> void:
	_phase = phase
	match phase:
		Phase.DISARMED:
			_phase_timer = _disarmed_duration
			_hitbox.deactivate()
			_sprite.modulate = GameConfig.config.spike_trap_disarmed_color
		Phase.TELEGRAPH:
			_phase_timer = _telegraph_duration
			_sprite.modulate = GameConfig.config.spike_trap_telegraph_color
			AudioManager.play_sfx_varied(&"door_lock")
		Phase.ARMED:
			_phase_timer = _armed_duration
			_sprite.modulate = GameConfig.config.spike_trap_armed_color
			_hitbox.activate()
