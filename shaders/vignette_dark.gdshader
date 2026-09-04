shader_type canvas_item;

// Neutral dark edge vignette for constant dungeon atmosphere.
uniform float intensity : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec2 uv = UV;
	float v = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 16.0;
	v = clamp(pow(v, 0.45), 0.0, 1.0);
	COLOR = vec4(0.0, 0.0, 0.02, (1.0 - v) * intensity);
}
