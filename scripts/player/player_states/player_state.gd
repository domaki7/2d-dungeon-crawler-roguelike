class_name PlayerState
extends State

var player: CharacterBody2D

var _footstep_timer: float = 0.0
var _dust_timer: float = 0.0

func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody2D

func get_input_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

## Call from a run state's `enter()` so the first step lands immediately rather
## than after a full interval of silent sliding.
func reset_footsteps() -> void:
	_footstep_timer = 0.0
	_dust_timer = 0.0

## Ticks the footstep sound and the dust puff at their own intervals. Both are
## driven off actual speed, so a slowed or hasted player's steps keep pace.
func step_footsteps(delta: float) -> void:
	var speed: float = player.velocity.length()
	if speed < 8.0:
		return
	# Faster movement means more ground covered per second, so steps come sooner.
	var pace: float = clampf(speed / maxf(player.speed, 1.0), 0.4, 2.0)

	_footstep_timer -= delta * pace
	if _footstep_timer <= 0.0:
		_footstep_timer = GameConfig.config.audio_footstep_interval
		AudioManager.play_sfx_varied(
			&"footstep",
			GameConfig.config.audio_footstep_pitch_min,
			GameConfig.config.audio_footstep_pitch_max,
			GameConfig.config.audio_footstep_volume_offset_db
		)

	_dust_timer -= delta * pace
	if _dust_timer <= 0.0:
		_dust_timer = GameConfig.config.vfx_footstep_dust_interval
		VFXHelper.spawn_footstep_dust(player.global_position + Vector2(0.0, 6.0))
