extends SceneTree
## Headless generator for the dungeon soundtrack.
##
## Run:
##   Godot_v4.7-stable_win64.exe --headless --path . --script res://tools/generate_music.gd
##
## Every theme is written as TWO stems of identical length and tempo:
##   <name>_base.wav   drones, pads, plucks — the exploration bed
##   <name>_layer.wav  drums, driving bass, lead melody — the combat energy
## AudioManager starts both players on the same frame and crossfades the layer
## in when enemies are aggroed, so the score reacts to the fight without ever
## restarting the track (see AudioManager.set_combat_intensity).
##
## Themes:
##   theme_halls    The Old Halls      D minor,  96 BPM, processional march
##   theme_depths   Damp Depths        A minor,  84 BPM, halftime bells and drips
##   theme_caverns  Ember Caverns      E phrygian, 108 BPM, tribal toms
##   theme_vault    Cold Crypts        C minor,  76 BPM, glassy halftime
##   theme_abyss    The Abyss          F# minor, 120 BPM, tritone doom
##   boss           Boss encounter     D minor, 150 BPM, driving
## Plus ambience_bed.wav — a tuned-out wind/drip/rumble loop for its own bus.

const SAMPLE_RATE: int = 22050
const BARS: int = 8
const VIBRATO_RATE: float = 5.0
const VIBRATO_DEPTH: float = 0.004

# Wave types
const SINE: int = 0
const TRI: int = 1
const SAW: int = 2
const SQUARE: int = 3

var _beat_sec: float = 0.0
var _total_samples: int = 0
var _l: PackedFloat32Array = PackedFloat32Array()
var _r: PackedFloat32Array = PackedFloat32Array()


func _init() -> void:
	for config: Dictionary in _theme_configs():
		_render_stem(config, "base")
		_render_stem(config, "layer")
	_render_ambience()
	print("Music generation complete.")
	quit()


## Tempo, harmony and arrangement style for each theme. `roots` are one bass
## note per bar, `chords` a mid-register triad per bar, `melody` a list of
## [bar, beat, duration_in_beats, midi] events.
func _theme_configs() -> Array[Dictionary]:
	return [
		{
			"name": "theme_halls", "bpm": 96.0, "drums": "march",
			"pad_wave": SAW, "lead_wave": TRI, "bass_wave": SAW,
			"arp": "pluck", "drone": false,
			# Dm Bb F C / Dm Gm A A
			"roots": [38, 34, 41, 36, 38, 43, 45, 45],
			"chords": [
				[50, 53, 57], [46, 50, 53], [53, 57, 60], [48, 52, 55],
				[50, 53, 57], [55, 58, 62], [57, 61, 64], [57, 61, 64],
			],
			"melody": [
				[0, 0.0, 1.0, 74], [0, 1.0, 1.0, 77], [0, 2.0, 1.5, 81], [0, 3.5, 0.5, 79],
				[1, 0.0, 2.0, 77], [1, 2.0, 2.0, 74],
				[2, 0.0, 1.0, 72], [2, 1.0, 1.0, 77], [2, 2.0, 2.0, 81],
				[3, 0.0, 1.5, 79], [3, 1.5, 0.5, 76], [3, 2.0, 2.0, 72],
				[4, 0.0, 1.0, 74], [4, 1.0, 1.0, 77], [4, 2.0, 1.0, 81], [4, 3.0, 1.0, 86],
				[5, 0.0, 2.0, 84], [5, 2.0, 1.0, 82], [5, 3.0, 1.0, 79],
				[6, 0.0, 1.0, 81], [6, 1.0, 1.0, 79], [6, 2.0, 1.0, 76], [6, 3.0, 1.0, 73],
				[7, 0.0, 2.0, 74], [7, 2.0, 2.0, 69],
			],
		},
		{
			"name": "theme_depths", "bpm": 84.0, "drums": "halftime",
			"pad_wave": SAW, "lead_wave": SINE, "bass_wave": SINE,
			"arp": "bell", "drone": false,
			# Am F Dm E / Am C Dm E
			"roots": [33, 29, 38, 40, 33, 36, 38, 40],
			"chords": [
				[57, 60, 64], [53, 57, 60], [50, 53, 57], [52, 56, 59],
				[57, 60, 64], [55, 60, 64], [50, 53, 57], [52, 56, 59],
			],
			"melody": [
				[0, 0.0, 2.0, 69], [0, 2.0, 2.0, 72],
				[1, 0.0, 3.0, 76], [1, 3.0, 1.0, 74],
				[2, 0.0, 2.0, 72], [2, 2.0, 2.0, 69],
				[3, 0.0, 2.0, 71], [3, 2.0, 2.0, 68],
				[4, 0.0, 1.0, 69], [4, 1.0, 1.0, 72], [4, 2.0, 2.0, 76],
				[5, 0.0, 2.0, 79], [5, 2.0, 2.0, 76],
				[6, 0.0, 2.0, 74], [6, 2.0, 1.0, 72], [6, 3.0, 1.0, 69],
				[7, 0.0, 2.0, 68], [7, 2.0, 2.0, 69],
			],
		},
		{
			"name": "theme_caverns", "bpm": 108.0, "drums": "tribal",
			"pad_wave": SAW, "lead_wave": TRI, "bass_wave": SAW,
			"arp": "pluck", "drone": true,
			# E F E G / E F Am G — phrygian menace
			"roots": [40, 41, 40, 43, 40, 41, 45, 43],
			"chords": [
				[52, 55, 59], [53, 57, 60], [52, 55, 59], [55, 59, 62],
				[52, 55, 59], [53, 57, 60], [57, 60, 64], [55, 59, 62],
			],
			"melody": [
				[0, 0.0, 0.5, 76], [0, 0.5, 0.5, 77], [0, 1.0, 1.0, 79], [0, 2.0, 1.0, 76], [0, 3.0, 1.0, 72],
				[1, 0.0, 1.0, 77], [1, 1.0, 1.0, 76], [1, 2.0, 2.0, 72],
				[2, 0.0, 0.5, 76], [2, 0.5, 0.5, 79], [2, 1.0, 1.0, 83], [2, 2.0, 2.0, 79],
				[3, 0.0, 1.0, 81], [3, 1.0, 1.0, 79], [3, 2.0, 1.0, 77], [3, 3.0, 1.0, 76],
				[4, 0.0, 1.0, 76], [4, 1.0, 0.5, 79], [4, 1.5, 0.5, 83], [4, 2.0, 2.0, 84],
				[5, 0.0, 1.0, 83], [5, 1.0, 1.0, 81], [5, 2.0, 2.0, 77],
				[6, 0.0, 1.0, 81], [6, 1.0, 1.0, 84], [6, 2.0, 1.0, 88], [6, 3.0, 1.0, 84],
				[7, 0.0, 2.0, 79], [7, 2.0, 1.0, 77], [7, 3.0, 1.0, 76],
			],
		},
		{
			"name": "theme_vault", "bpm": 76.0, "drums": "halftime",
			"pad_wave": SAW, "lead_wave": SINE, "bass_wave": SINE,
			"arp": "bell", "drone": true,
			# Cm Cm Ab G / Cm Eb Ab G
			"roots": [36, 36, 32, 31, 36, 39, 32, 31],
			"chords": [
				[48, 51, 55], [48, 51, 55], [56, 60, 63], [55, 59, 62],
				[48, 51, 55], [51, 55, 58], [56, 60, 63], [55, 59, 62],
			],
			"melody": [
				[0, 0.0, 2.0, 75], [0, 2.0, 2.0, 72],
				[1, 0.0, 4.0, 70],
				[2, 0.0, 2.0, 75], [2, 2.0, 2.0, 79],
				[3, 0.0, 3.0, 74], [3, 3.0, 1.0, 72],
				[4, 0.0, 2.0, 72], [4, 2.0, 2.0, 75],
				[5, 0.0, 2.0, 79], [5, 2.0, 2.0, 82],
				[6, 0.0, 2.0, 80], [6, 2.0, 2.0, 75],
				[7, 0.0, 3.0, 74], [7, 3.0, 1.0, 72],
			],
		},
		{
			"name": "theme_abyss", "bpm": 120.0, "drums": "doom",
			"pad_wave": SAW, "lead_wave": SINE, "bass_wave": SAW,
			"arp": "none", "drone": true,
			# F#m F#m C F / F#m D C F — the tritone is the point
			"roots": [42, 42, 36, 41, 42, 38, 36, 41],
			"chords": [
				[54, 57, 61], [54, 57, 61], [48, 52, 55], [53, 57, 60],
				[54, 57, 61], [50, 54, 57], [48, 52, 55], [53, 57, 60],
			],
			"melody": [
				[0, 0.0, 1.0, 66], [0, 1.0, 1.0, 69], [0, 2.0, 2.0, 73],
				[1, 0.0, 2.0, 71], [1, 2.0, 2.0, 66],
				[2, 0.0, 1.0, 72], [2, 1.0, 1.0, 67], [2, 2.0, 2.0, 64],
				[3, 0.0, 2.0, 65], [3, 2.0, 2.0, 69],
				[4, 0.0, 1.0, 66], [4, 1.0, 1.0, 73], [4, 2.0, 1.0, 78], [4, 3.0, 1.0, 76],
				[5, 0.0, 2.0, 74], [5, 2.0, 2.0, 78],
				[6, 0.0, 1.0, 79], [6, 1.0, 1.0, 76], [6, 2.0, 2.0, 72],
				[7, 0.0, 2.0, 65], [7, 2.0, 2.0, 66],
			],
		},
		{
			"name": "boss", "bpm": 150.0, "drums": "drive",
			"pad_wave": SAW, "lead_wave": TRI, "bass_wave": SAW,
			"arp": "pluck", "drone": true,
			# Dm Dm Bb A / Dm F Gm A
			"roots": [38, 38, 34, 33, 38, 41, 43, 33],
			"chords": [
				[50, 53, 57], [50, 53, 57], [46, 50, 53], [45, 49, 52],
				[50, 53, 57], [53, 57, 60], [55, 58, 62], [45, 49, 52],
			],
			"melody": [
				[0, 0.0, 0.5, 74], [0, 0.5, 0.5, 77], [0, 1.0, 0.5, 81], [0, 1.5, 0.5, 77], [0, 2.0, 1.0, 74], [0, 3.0, 1.0, 72],
				[1, 0.0, 0.5, 74], [1, 0.5, 0.5, 77], [1, 1.0, 1.0, 81], [1, 2.0, 2.0, 84],
				[2, 0.0, 0.5, 82], [2, 0.5, 0.5, 81], [2, 1.0, 1.0, 77], [2, 2.0, 2.0, 74],
				[3, 0.0, 0.5, 73], [3, 0.5, 0.5, 76], [3, 1.0, 1.0, 81], [3, 2.0, 1.0, 77], [3, 3.0, 1.0, 73],
				[4, 0.0, 1.0, 74], [4, 1.0, 0.5, 77], [4, 1.5, 0.5, 81], [4, 2.0, 1.0, 86], [4, 3.0, 1.0, 84],
				[5, 0.0, 0.5, 81], [5, 0.5, 0.5, 77], [5, 1.0, 1.0, 84], [5, 2.0, 2.0, 81],
				[6, 0.0, 0.5, 79], [6, 0.5, 0.5, 82], [6, 1.0, 1.0, 86], [6, 2.0, 1.0, 82], [6, 3.0, 1.0, 79],
				[7, 0.0, 1.0, 81], [7, 1.0, 1.0, 76], [7, 2.0, 1.0, 73], [7, 3.0, 0.5, 76], [7, 3.5, 0.5, 79],
			],
		},
	]


func _render_stem(config: Dictionary, stem: String) -> void:
	_beat_sec = 60.0 / float(config["bpm"])
	_begin(float(BARS) * 4.0 * _beat_sec)

	if stem == "base":
		# Themes without a headline drone still get a quiet root pedal, or the
		# base stem has no low end at all and the noise wash dominates it.
		_render_drone(config, 1.0 if bool(config["drone"]) else 0.42)
		_render_pad(config, 0.055)
		_render_arp(config)
		_render_base_wash(config)
	else:
		_render_drums(String(config["drums"]))
		_render_bass(config)
		_render_stabs(config)
		_render_lead(config)

	var target: float = 0.72 if stem == "base" else 0.88
	_save("res://assets/audio/music/%s_%s.wav" % [config["name"], stem], target)


func _begin(duration_sec: float) -> void:
	_total_samples = int(round(duration_sec * float(SAMPLE_RATE)))
	_l = PackedFloat32Array()
	_l.resize(_total_samples)
	_r = PackedFloat32Array()
	_r.resize(_total_samples)


func _midi_to_freq(midi: int) -> float:
	return 440.0 * pow(2.0, (float(midi) - 69.0) / 12.0)


func _bar_start(bar: int) -> float:
	return float(bar) * 4.0 * _beat_sec


# ---------------------------------------------------------------- base layers

## Sub-octave root pedal — the room tone of the floor. `gain_scale` drops it to
## a barely-there pedal for themes whose identity isn't the drone.
func _render_drone(config: Dictionary, gain_scale: float = 1.0) -> void:
	var roots: Array = config["roots"]
	for bar: int in BARS:
		var start: float = _bar_start(bar)
		var freq: float = _midi_to_freq(int(roots[bar]) - 12)
		_add_tone(start, _beat_sec * 4.05, freq, 0.13 * gain_scale, SINE, 0.0, 0.0, 0.25, 0.3)
		_add_tone(start, _beat_sec * 4.05, freq * 1.007, 0.07 * gain_scale, SINE, 0.6, 0.0, 0.25, 0.3)
		_add_tone(start, _beat_sec * 4.05, freq * 0.993, 0.07 * gain_scale, SINE, -0.6, 0.0, 0.25, 0.3)


## Wide detuned chord bed with a slow swell, one chord per bar.
func _render_pad(config: Dictionary, gain: float) -> void:
	var chords: Array = config["chords"]
	var wave: int = int(config["pad_wave"])
	for bar: int in BARS:
		var start: float = _bar_start(bar)
		for midi: int in chords[bar]:
			var freq: float = _midi_to_freq(int(midi))
			_add_tone(start, _beat_sec * 3.95, freq * 0.996, gain, wave, -0.7, 0.0, _beat_sec * 0.5, _beat_sec * 0.7)
			_add_tone(start, _beat_sec * 3.95, freq * 1.004, gain, wave, 0.7, 0.0, _beat_sec * 0.5, _beat_sec * 0.7)


## The base stem's only rhythmic content: a soft plucked figure (halls, caverns)
## or sparse struck bells (crypt, vault). Keeps exploration moving without drums.
func _render_arp(config: Dictionary) -> void:
	var style: String = String(config["arp"])
	if style == "none":
		return
	var chords: Array = config["chords"]
	if style == "pluck":
		var pattern: Array[int] = [0, 2, 1, 2, 0, 1, 2, 1]
		for bar: int in BARS:
			var chord: Array = chords[bar]
			for i: int in 8:
				var midi: int = int(chord[pattern[i]]) + 12
				var start: float = _bar_start(bar) + float(i) * 0.5 * _beat_sec
				var pan: float = 0.4 if i % 2 == 0 else -0.4
				_add_tone(start, _beat_sec * 0.45, _midi_to_freq(midi), 0.055, TRI, pan, 0.0, 0.004, _beat_sec * 0.4)
	else:
		# Bells: root on 1, fifth on 3, plus an octave shimmer every other bar.
		for bar: int in BARS:
			var chord: Array = chords[bar]
			var start: float = _bar_start(bar)
			_add_bell(start, _midi_to_freq(int(chord[0]) + 12), 0.085, -0.3)
			_add_bell(start + 2.0 * _beat_sec, _midi_to_freq(int(chord[2]) + 12), 0.065, 0.35)
			if bar % 2 == 1:
				_add_bell(start + 3.0 * _beat_sec, _midi_to_freq(int(chord[1]) + 24), 0.04, 0.0)


## Bell/glass voice: sine fundamental with inharmonic partials and a long tail.
func _add_bell(start: float, freq: float, gain: float, pan: float) -> void:
	_add_tone(start, _beat_sec * 3.0, freq, gain, SINE, pan, 0.0, 0.002, _beat_sec * 2.6)
	_add_tone(start, _beat_sec * 1.8, freq * 2.76, gain * 0.32, SINE, pan, 0.0, 0.002, _beat_sec * 1.6)
	_add_tone(start, _beat_sec * 1.1, freq * 5.4, gain * 0.14, SINE, pan, 0.0, 0.002, _beat_sec * 1.0)


## Breathy noise bed under the base stem — held at constant amplitude so the
## loop point never clicks.
func _render_base_wash(config: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(config["name"])
	var prev: float = 0.0
	var lp: float = 0.0
	for i: int in _total_samples:
		var white: float = rng.randf_range(-1.0, 1.0)
		var hp: float = (white - prev) * 0.5
		prev = white
		lp = lp * 0.985 + hp * 0.015
		# Slow stereo drift so the wash breathes instead of sitting flat.
		var t: float = float(i) / float(SAMPLE_RATE)
		var sway: float = 0.5 + 0.5 * sin(TAU * t / 7.3)
		# Kept deliberately low: this is air behind the music, not a hiss bed.
		_l[i] += lp * 7.0 * (0.7 + 0.3 * sway)
		_r[i] += lp * 7.0 * (1.0 - 0.3 * sway)


# --------------------------------------------------------------- layer stems

func _render_drums(style: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	for bar: int in BARS:
		var bar_start: float = _bar_start(bar)
		match style:
			"march":
				# Steady processional: kick on 1 and 3, snare on 2 and 4.
				for beat: int in 4:
					var start: float = bar_start + float(beat) * _beat_sec
					if beat % 2 == 0:
						_add_kick(start)
					else:
						_add_snare(start, 0.20, rng)
					_add_hat(start + 0.5 * _beat_sec, 0.03, 0.06, rng, 0.3 if beat % 2 == 0 else -0.3)
				if bar % 4 == 3:
					for i: int in 3:
						_add_snare(bar_start + (3.0 + float(i) * 0.33) * _beat_sec, 0.10 + 0.05 * float(i), rng)
			"halftime":
				_add_kick(bar_start)
				_add_snare(bar_start + 2.0 * _beat_sec, 0.19, rng)
				for i: int in 4:
					_add_hat(bar_start + float(i) * _beat_sec, 0.025, 0.045, rng, 0.35 if i % 2 == 1 else -0.35)
				if bar % 2 == 1:
					_add_kick(bar_start + 3.5 * _beat_sec)
			"tribal":
				# Toms carry the groove; the kick just anchors the downbeat.
				_add_kick(bar_start)
				for i: int in 8:
					var start: float = bar_start + float(i) * 0.5 * _beat_sec
					if i == 2 or i == 5 or i == 7:
						_add_tom(start, 130.0 if i == 5 else 98.0, 0.20, rng, 0.35 if i % 2 == 0 else -0.35)
					if i % 2 == 1:
						_add_hat(start, 0.025, 0.05, rng, 0.25)
				_add_snare(bar_start + 2.0 * _beat_sec, 0.17, rng)
			"doom":
				_add_kick(bar_start)
				_add_kick(bar_start + 1.5 * _beat_sec)
				_add_snare(bar_start + 2.0 * _beat_sec, 0.24, rng)
				_add_tom(bar_start + 3.5 * _beat_sec, 82.0, 0.18, rng, 0.0)
				for beat: int in 4:
					_add_hat(bar_start + float(beat) * _beat_sec, 0.04, 0.035, rng, 0.4 if beat % 2 == 1 else -0.4)
			"drive":
				if bar % 4 == 0:
					_add_hat(bar_start, 0.35, 0.16, rng, 0.0)
				for half: int in 8:
					var start: float = bar_start + float(half) * 0.5 * _beat_sec
					_add_hat(start, 0.03, 0.10 if half % 2 == 1 else 0.065, rng, 0.3)
					if half % 2 == 0:
						_add_kick(start)
					if half == 2 or half == 6:
						_add_snare(start, 0.26, rng)
				if bar % 4 == 3:
					for i: int in 4:
						_add_snare(bar_start + (3.0 + float(i) * 0.25) * _beat_sec, 0.12 + 0.05 * float(i), rng)


func _render_bass(config: Dictionary) -> void:
	var roots: Array = config["roots"]
	var wave: int = int(config["bass_wave"])
	var style: String = String(config["drums"])
	var busy: bool = style == "drive" or style == "tribal" or style == "march"
	for bar: int in BARS:
		var root: int = int(roots[bar])
		var bar_start: float = _bar_start(bar)
		if busy:
			for half: int in 8:
				var midi: int = root + (12 if (half == 3 or half == 7) else 0)
				var start: float = bar_start + float(half) * 0.5 * _beat_sec
				_add_tone(start, _beat_sec * 0.42, _midi_to_freq(midi), 0.19, wave)
				if half % 2 == 0:
					# Sine sub under the riff so the low end has real weight.
					_add_tone(start, _beat_sec * 0.42, _midi_to_freq(root), 0.10, SINE)
		else:
			_add_tone(bar_start, _beat_sec * 1.9, _midi_to_freq(root), 0.21, wave)
			_add_tone(bar_start + 2.0 * _beat_sec, _beat_sec * 1.9, _midi_to_freq(root + (12 if bar % 2 == 1 else 0)), 0.18, wave)
			_add_tone(bar_start, _beat_sec * 3.9, _midi_to_freq(root), 0.10, SINE)


## Short offbeat chord hits — rhythm-guitar energy for the driving styles.
func _render_stabs(config: Dictionary) -> void:
	var style: String = String(config["drums"])
	if style != "drive" and style != "march" and style != "tribal":
		return
	var chords: Array = config["chords"]
	for bar: int in BARS:
		var bar_start: float = _bar_start(bar)
		for beat_index: int in 2:
			var beat: float = 1.5 + 2.0 * float(beat_index)
			var pan: float = 0.4 if (bar + beat_index) % 2 == 0 else -0.4
			for midi: int in chords[bar]:
				_add_tone(bar_start + beat * _beat_sec, 0.11, _midi_to_freq(int(midi) + 12), 0.032, SQUARE, pan)


func _render_lead(config: Dictionary) -> void:
	var wave: int = int(config["lead_wave"])
	for note: Array in config["melody"]:
		var bar: int = int(note[0])
		var beat: float = float(note[1])
		var dur: float = float(note[2]) * _beat_sec * 0.92
		var start: float = _bar_start(bar) + beat * _beat_sec
		var freq: float = _midi_to_freq(int(note[3]))
		_add_tone(start, dur, freq, 0.145, wave, 0.0, VIBRATO_DEPTH)
		if wave == SINE:
			_add_tone(start, dur * 0.7, freq * 2.0, 0.045, SINE, 0.0, VIBRATO_DEPTH)
		else:
			_add_tone(start, dur, freq * 1.005, 0.06, wave, 0.0, VIBRATO_DEPTH)
		# Dotted-eighth stereo echo taps put the melody in a space.
		var echo: float = 0.75 * _beat_sec
		_add_tone(start + echo, dur * 0.8, freq, 0.038, wave, 0.6, VIBRATO_DEPTH)
		_add_tone(start + echo * 2.0, dur * 0.6, freq, 0.018, wave, -0.6, VIBRATO_DEPTH)


# ------------------------------------------------------------------ ambience

## Standalone dungeon room tone: low rumble, air, and occasional water drips.
## Every ingredient holds a steady envelope across the loop point.
func _render_ambience() -> void:
	_begin(24.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 90210

	# Low rumble: two slow sines whose periods divide the loop exactly.
	for i: int in _total_samples:
		var t: float = float(i) / float(SAMPLE_RATE)
		var rumble: float = sin(TAU * 41.0 * t) * 0.05 + sin(TAU * 27.5 * t) * 0.035
		var swell: float = 0.75 + 0.25 * sin(TAU * t / 12.0)
		_l[i] += rumble * swell
		_r[i] += rumble * swell * 0.95

	# Air: heavily low-passed noise, constant amplitude so the seam is silent.
	var prev: float = 0.0
	var lp_a: float = 0.0
	var lp_b: float = 0.0
	for i: int in _total_samples:
		var white: float = rng.randf_range(-1.0, 1.0)
		var hp: float = (white - prev) * 0.5
		prev = white
		lp_a = lp_a * 0.99 + hp * 0.01
		lp_b = lp_b * 0.99 + lp_a * 0.01
		var t: float = float(i) / float(SAMPLE_RATE)
		var sway: float = 0.5 + 0.5 * sin(TAU * t / 9.0)
		_l[i] += lp_b * 900.0 * (0.6 + 0.4 * sway)
		_r[i] += lp_b * 900.0 * (1.0 - 0.4 * sway)

	# Drips, kept clear of the loop boundary so none is cut in half.
	var drip_times: Array[float] = [1.7, 4.2, 6.9, 9.1, 12.6, 15.3, 18.0, 21.2]
	for time: float in drip_times:
		var freq: float = rng.randf_range(720.0, 1350.0)
		var pan: float = rng.randf_range(-0.8, 0.8)
		_add_drip(time, freq, rng.randf_range(0.05, 0.11), pan)

	# Distant stone groans give the bed a sense of scale.
	_add_tone(3.0, 3.5, 62.0, 0.05, SINE, -0.5, 0.0, 1.2, 1.6)
	_add_tone(13.5, 4.0, 55.0, 0.05, SINE, 0.5, 0.0, 1.4, 1.8)

	_save("res://assets/audio/music/ambience_bed.wav", 0.55)


## Pitch-falling sine blip with a short tail — a water drop on stone.
func _add_drip(start_sec: float, freq: float, gain: float, pan: float) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(0.28 * float(SAMPLE_RATE))
	var angle: float = (clampf(pan, -1.0, 1.0) + 1.0) * PI / 4.0
	var gain_l: float = gain * cos(angle)
	var gain_r: float = gain * sin(angle)
	var phase: float = 0.0
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var t: float = float(i) / float(SAMPLE_RATE)
		phase += (freq * (1.0 + 0.9 * exp(-t * 45.0))) / float(SAMPLE_RATE)
		var env: float = exp(-t * 16.0)
		var value: float = sin(TAU * phase) * env
		_l[idx] += value * gain_l
		_r[idx] += value * gain_r


# ------------------------------------------------------------- synth helpers

## wave: 0 sine, 1 triangle, 2 saw, 3 square. pan -1 (left) .. 1 (right),
## equal-power. vibrato is a pitch depth fraction applied at VIBRATO_RATE Hz.
func _add_tone(
	start_sec: float,
	dur_sec: float,
	freq: float,
	gain: float,
	wave: int,
	pan: float = 0.0,
	vibrato: float = 0.0,
	attack_sec: float = 0.008,
	release_sec: float = 0.05
) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(dur_sec * float(SAMPLE_RATE))
	if count <= 0:
		return
	var attack: int = clampi(int(attack_sec * float(SAMPLE_RATE)), 1, count)
	var release: int = clampi(int(release_sec * float(SAMPLE_RATE)), 1, count)
	var base_step: float = freq / float(SAMPLE_RATE)
	var phase: float = 0.0
	var angle: float = (clampf(pan, -1.0, 1.0) + 1.0) * PI / 4.0
	var gain_l: float = gain * cos(angle)
	var gain_r: float = gain * sin(angle)
	var vib_step: float = VIBRATO_RATE / float(SAMPLE_RATE)
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var p: float = fposmod(phase, 1.0)
		var value: float
		match wave:
			SINE:
				value = sin(TAU * phase)
			TRI:
				value = 4.0 * absf(p - 0.5) - 1.0
			SAW:
				value = 2.0 * p - 1.0
			_:
				value = 1.0 if p < 0.5 else -1.0
		var env: float = 1.0
		if i < attack:
			env = float(i) / float(attack)
		elif count - i < release:
			env = float(count - i) / float(release)
		_l[idx] += value * gain_l * env
		_r[idx] += value * gain_r * env
		var step: float = base_step
		if vibrato > 0.0:
			step = base_step * (1.0 + vibrato * sin(TAU * vib_step * float(i)))
		phase += step


func _add_kick(start_sec: float) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(0.14 * float(SAMPLE_RATE))
	var phase: float = 0.0
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var t: float = float(i) / float(SAMPLE_RATE)
		phase += (45.0 + 90.0 * exp(-t * 38.0)) / float(SAMPLE_RATE)
		# The fast-decaying high partial is the beater click that lets the kick
		# cut through instead of reading as a dull thump.
		var click: float = sin(TAU * 900.0 * t) * 0.26 * exp(-t * 200.0)
		var value: float = sin(TAU * phase) * 0.42 * exp(-t * 26.0) + click
		_l[idx] += value
		_r[idx] += value


## Noise crack plus a short tonal body — reads as a snare, not as static.
func _add_snare(start_sec: float, gain: float, rng: RandomNumberGenerator) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(0.16 * float(SAMPLE_RATE))
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var env: float = pow(1.0 - float(i) / float(count), 1.6)
		var value: float = rng.randf_range(-1.0, 1.0) * gain * env
		_l[idx] += value
		_r[idx] += value
	_add_tone(start_sec, 0.07, 185.0, gain * 0.5, SINE)


## Pitched membrane hit for the tribal kit.
func _add_tom(start_sec: float, freq: float, gain: float, rng: RandomNumberGenerator, pan: float) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(0.22 * float(SAMPLE_RATE))
	var angle: float = (clampf(pan, -1.0, 1.0) + 1.0) * PI / 4.0
	var gain_l: float = gain * cos(angle)
	var gain_r: float = gain * sin(angle)
	var phase: float = 0.0
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var t: float = float(i) / float(SAMPLE_RATE)
		phase += (freq * (1.0 + 0.35 * exp(-t * 30.0))) / float(SAMPLE_RATE)
		var env: float = exp(-t * 13.0)
		var value: float = (sin(TAU * phase) * 0.85 + rng.randf_range(-1.0, 1.0) * 0.15) * env
		_l[idx] += value * gain_l
		_r[idx] += value * gain_r


## Hi-passed noise burst (first-difference filter) — a crisp hat rather than
## the full-spectrum hiss raw white noise gives.
func _add_hat(start_sec: float, dur_sec: float, gain: float, rng: RandomNumberGenerator, pan: float = 0.0) -> void:
	var start: int = int(start_sec * float(SAMPLE_RATE))
	var count: int = int(dur_sec * float(SAMPLE_RATE))
	var angle: float = (clampf(pan, -1.0, 1.0) + 1.0) * PI / 4.0
	var gain_l: float = gain * cos(angle)
	var gain_r: float = gain * sin(angle)
	var prev: float = 0.0
	for i: int in count:
		var idx: int = start + i
		if idx >= _total_samples:
			break
		var white: float = rng.randf_range(-1.0, 1.0)
		var value: float = (white - prev) * 0.7
		prev = white
		var env: float = 1.0 - float(i) / float(count)
		env = env * env
		_l[idx] += value * gain_l * env
		_r[idx] += value * gain_r * env


func _save(out_path: String, target_peak: float) -> void:
	# Soft-knee limiter, then normalize so every stem lands at a known peak.
	var peak: float = 0.0
	for i: int in _total_samples:
		_l[i] = tanh(_l[i] * 1.25)
		_r[i] = tanh(_r[i] * 1.25)
		peak = maxf(peak, maxf(absf(_l[i]), absf(_r[i])))
	var scale: float = (target_peak / peak) if peak > 0.0 else 1.0

	var bytes := PackedByteArray()
	bytes.resize(_total_samples * 4)
	for i: int in _total_samples:
		bytes.encode_s16(i * 4, int(clampf(_l[i] * scale, -1.0, 1.0) * 32767.0))
		bytes.encode_s16(i * 4 + 2, int(clampf(_r[i] * scale, -1.0, 1.0) * 32767.0))

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = true
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = _total_samples
	wav.data = bytes

	DirAccess.make_dir_recursive_absolute("res://assets/audio/music")
	var err: Error = wav.save_to_wav(out_path)
	print("%s  %.1fs  (%s)" % [out_path, float(_total_samples) / float(SAMPLE_RATE), error_string(err)])
