extends SceneTree
## Headless generator for the sound effects AudioManager was faking with
## fallbacks, plus the new feedback sounds.
##
## Run:
##   Godot_v4.7-stable_win64.exe --headless --path . --script res://tools/generate_sfx.gd
##
## Before this existed, `_SFX_FALLBACKS` in audio_manager.gd remapped swing,
## dodge and the entire Mage spell set onto hit.wav / arrow_fire.wav, so a
## fireball sounded like an arrow. Each of these is synthesised to match what
## it actually depicts.

const SAMPLE_RATE: int = 22050

var _buf: PackedFloat32Array = PackedFloat32Array()
var _n: int = 0


func _init() -> void:
	_make_swing()
	_make_dodge()
	_make_footstep()
	_make_heartbeat()
	_make_magic_bolt()
	_make_ice_shard()
	_make_chain_lightning()
	_make_fire_wall()
	_make_ogre_charge()
	_make_ui_hover()
	_make_ui_purchase()
	_make_ui_error()
	_make_chime()
	print("SFX generation complete.")
	quit()


# --------------------------------------------------------------------- combat

## Blade cutting air: band of noise whose centre sweeps down as it passes.
func _make_swing() -> void:
	_begin(0.20)
	var rng := _rng(11)
	_noise_sweep(0.0, 0.20, 2600.0, 700.0, 0.40, rng)
	_tone(0.02, 0.10, 320.0, 0.05, 12.0)
	_save("swing")


## Roll: longer, lower whoosh with a cloth-scuff landing.
func _make_dodge() -> void:
	_begin(0.34)
	var rng := _rng(12)
	_noise_sweep(0.0, 0.26, 1500.0, 400.0, 0.34, rng)
	_noise_burst(0.24, 0.10, 0.22, 20.0, rng)
	_tone(0.24, 0.09, 120.0, 0.14, 26.0)
	_save("dodge")


## Boot on stone: a soft body thump with a grit transient on top.
func _make_footstep() -> void:
	_begin(0.11)
	var rng := _rng(13)
	_noise_burst(0.0, 0.05, 0.20, 60.0, rng)
	_tone(0.0, 0.08, 95.0, 0.30, 42.0)
	_tone(0.0, 0.03, 240.0, 0.10, 90.0)
	_save("footstep")


## Lub-dub over a one-second loop — sits right at a resting pulse when played
## back at 1.0, and speeds up naturally if pitched for panic.
func _make_heartbeat() -> void:
	_begin(1.0)
	_thump(0.00, 58.0, 0.55, 13.0)
	_thump(0.26, 48.0, 0.38, 15.0)
	_save("heartbeat")


func _thump(start: float, freq: float, gain: float, decay: float) -> void:
	var s: int = int(start * float(SAMPLE_RATE))
	var count: int = int(0.30 * float(SAMPLE_RATE))
	var phase: float = 0.0
	for i: int in count:
		var idx: int = s + i
		if idx >= _n:
			break
		var t: float = float(i) / float(SAMPLE_RATE)
		phase += (freq * (1.0 + 0.5 * exp(-t * 30.0))) / float(SAMPLE_RATE)
		_buf[idx] += sin(TAU * phase) * gain * exp(-t * decay)


# --------------------------------------------------------------------- spells

## Arcane bolt: a falling tone with an octave shimmer and a short air tail.
func _make_magic_bolt() -> void:
	_begin(0.30)
	var rng := _rng(21)
	_sweep_tone(0.0, 0.26, 900.0, 300.0, 0.28, 0)
	_sweep_tone(0.0, 0.20, 1800.0, 620.0, 0.09, 0)
	_noise_sweep(0.0, 0.16, 4000.0, 1400.0, 0.10, rng)
	_save("magic_bolt")


## Ice: inharmonic glass partials plus a fine crackle.
func _make_ice_shard() -> void:
	_begin(0.42)
	var rng := _rng(22)
	_tone(0.0, 0.40, 1480.0, 0.20, 9.0)
	_tone(0.0, 0.30, 2530.0, 0.11, 13.0)
	_tone(0.0, 0.22, 3970.0, 0.06, 18.0)
	_noise_burst(0.0, 0.09, 0.14, 40.0, rng)
	_save("ice_shard")


## Lightning: gated noise crackle over a bright zap that snaps downward.
func _make_chain_lightning() -> void:
	_begin(0.40)
	var rng := _rng(23)
	_sweep_tone(0.0, 0.10, 3200.0, 900.0, 0.18, 0)
	for i: int in 14:
		var at: float = rng.randf_range(0.0, 0.32)
		_noise_burst(at, rng.randf_range(0.008, 0.03), rng.randf_range(0.08, 0.26), 120.0, rng)
	_noise_sweep(0.0, 0.34, 5200.0, 1800.0, 0.09, rng)
	_save("chain_lightning")


## Flame: a roaring low-passed noise bed with a rising ignition swell.
func _make_fire_wall() -> void:
	_begin(0.95)
	var rng := _rng(24)
	var lp: float = 0.0
	var prev: float = 0.0
	for i: int in _n:
		var t: float = float(i) / float(SAMPLE_RATE)
		var white: float = rng.randf_range(-1.0, 1.0)
		var hp: float = (white - prev) * 0.5
		prev = white
		lp = lp * 0.93 + hp * 0.07
		# Fast swell, long guttering decay.
		var env: float = minf(t / 0.09, 1.0) * exp(-maxf(t - 0.09, 0.0) * 2.6)
		# Slow flutter so it breathes like an actual flame.
		var flutter: float = 0.75 + 0.25 * sin(TAU * 7.0 * t) * sin(TAU * 3.3 * t)
		_buf[i] += lp * 3.6 * env * flutter
	_sweep_tone(0.0, 0.35, 180.0, 70.0, 0.20, 0)
	_save("fire_wall")


## Ogre winding up: a rising growl with a breath layer over it.
func _make_ogre_charge() -> void:
	_begin(0.75)
	var rng := _rng(25)
	_sweep_tone(0.0, 0.70, 62.0, 118.0, 0.34, 2)
	_sweep_tone(0.0, 0.70, 93.0, 176.0, 0.14, 2)
	_noise_sweep(0.05, 0.62, 500.0, 1500.0, 0.14, rng)
	_save("ogre_charge")


# ------------------------------------------------------------------------- UI

func _make_ui_hover() -> void:
	_begin(0.09)
	_tone(0.0, 0.08, 1180.0, 0.16, 46.0)
	_tone(0.0, 0.05, 2360.0, 0.05, 60.0)
	_save("ui_hover")


## Coin ring on top of a rising confirmation interval.
func _make_ui_purchase() -> void:
	_begin(0.45)
	_tone(0.00, 0.16, 660.0, 0.16, 16.0)
	_tone(0.09, 0.30, 990.0, 0.16, 11.0)
	_tone(0.00, 0.35, 2300.0, 0.07, 12.0)
	_tone(0.00, 0.30, 3170.0, 0.04, 15.0)
	_save("ui_purchase")


## Flat, slightly detuned low buzz — reads as "no" without being harsh.
func _make_ui_error() -> void:
	_begin(0.26)
	_sweep_tone(0.0, 0.24, 165.0, 138.0, 0.22, 3)
	_sweep_tone(0.0, 0.24, 167.0, 140.0, 0.12, 3)
	_save("ui_error")


## Bright bell arpeggio for unlocks and floor-exit reveals.
func _make_chime() -> void:
	_begin(1.0)
	var notes: Array[float] = [1046.5, 1318.5, 1568.0, 2093.0]
	for i: int in notes.size():
		var start: float = float(i) * 0.075
		var gain: float = 0.16 - 0.02 * float(i)
		_tone(start, 0.9, notes[i], gain, 4.5)
		_tone(start, 0.5, notes[i] * 2.76, gain * 0.22, 9.0)
	_save("chime")


# ------------------------------------------------------------- synth toolkit

func _begin(duration_sec: float) -> void:
	_n = int(duration_sec * float(SAMPLE_RATE))
	_buf = PackedFloat32Array()
	_buf.resize(_n)


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


## Exponentially decaying tone. wave: 0 sine, 2 saw, 3 square.
func _tone(start: float, dur: float, freq: float, gain: float, decay: float, wave: int = 0) -> void:
	_sweep_tone(start, dur, freq, freq, gain, wave, decay)


## Tone gliding from `from_freq` to `to_freq` over its lifetime.
func _sweep_tone(start: float, dur: float, from_freq: float, to_freq: float, gain: float, wave: int, decay: float = -1.0) -> void:
	var s: int = int(start * float(SAMPLE_RATE))
	var count: int = int(dur * float(SAMPLE_RATE))
	if count <= 0:
		return
	var attack: int = maxi(int(0.003 * float(SAMPLE_RATE)), 1)
	var phase: float = 0.0
	for i: int in count:
		var idx: int = s + i
		if idx >= _n:
			break
		var frac: float = float(i) / float(count)
		var freq: float = lerpf(from_freq, to_freq, frac)
		phase += freq / float(SAMPLE_RATE)
		var p: float = fposmod(phase, 1.0)
		var value: float
		match wave:
			2:
				value = 2.0 * p - 1.0
			3:
				value = 1.0 if p < 0.5 else -1.0
			_:
				value = sin(TAU * phase)
		var env: float
		if decay >= 0.0:
			env = exp(-float(i) / float(SAMPLE_RATE) * decay)
		else:
			env = 1.0 - frac
		if i < attack:
			env *= float(i) / float(attack)
		_buf[idx] += value * gain * env


## Noise pushed through a one-pole low-pass whose cutoff glides — the cheapest
## convincing "whoosh".
func _noise_sweep(start: float, dur: float, from_hz: float, to_hz: float, gain: float, rng: RandomNumberGenerator) -> void:
	var s: int = int(start * float(SAMPLE_RATE))
	var count: int = int(dur * float(SAMPLE_RATE))
	var lp: float = 0.0
	for i: int in count:
		var idx: int = s + i
		if idx >= _n:
			break
		var frac: float = float(i) / float(count)
		var cutoff: float = lerpf(from_hz, to_hz, frac)
		var alpha: float = clampf(cutoff / float(SAMPLE_RATE) * 2.0, 0.0, 1.0)
		lp = lp + alpha * (rng.randf_range(-1.0, 1.0) - lp)
		# Bell-shaped envelope: the blade passes, it does not fade in from zero.
		var env: float = sin(PI * frac)
		_buf[idx] += lp * gain * env


func _noise_burst(start: float, dur: float, gain: float, decay: float, rng: RandomNumberGenerator) -> void:
	var s: int = int(start * float(SAMPLE_RATE))
	var count: int = int(dur * float(SAMPLE_RATE))
	var prev: float = 0.0
	for i: int in count:
		var idx: int = s + i
		if idx >= _n:
			break
		var white: float = rng.randf_range(-1.0, 1.0)
		var value: float = (white - prev) * 0.7
		prev = white
		_buf[idx] += value * gain * exp(-float(i) / float(SAMPLE_RATE) * decay)


func _save(sfx_name: String) -> void:
	var peak: float = 0.0
	for i: int in _n:
		_buf[i] = tanh(_buf[i] * 1.2)
		peak = maxf(peak, absf(_buf[i]))
	var scale: float = (0.85 / peak) if peak > 0.0 else 1.0

	var bytes := PackedByteArray()
	bytes.resize(_n * 2)
	for i: int in _n:
		bytes.encode_s16(i * 2, int(clampf(_buf[i] * scale, -1.0, 1.0) * 32767.0))

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes

	var out_path: String = "res://assets/audio/sfx/%s.wav" % sfx_name
	var err: Error = wav.save_to_wav(out_path)
	print("%s  %.2fs  (%s)" % [out_path, float(_n) / float(SAMPLE_RATE), error_string(err)])
