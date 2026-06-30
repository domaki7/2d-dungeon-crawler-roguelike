shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	float v = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * 16.0;
	v = clamp(v, 0.0, 1.0);
	COLOR = vec4(0.5, 0.0, 0.0, 1.0 - v);
}
