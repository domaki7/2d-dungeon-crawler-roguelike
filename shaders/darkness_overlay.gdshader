shader_type canvas_item;

uniform vec2 player_screen_pos = vec2(240.0, 135.0);
uniform float light_radius = 80.0;
uniform float edge_softness = 24.0;
uniform vec2 viewport_size = vec2(480.0, 270.0);

void fragment() {
	vec2 pixel_pos = SCREEN_UV * viewport_size;
	float dist = length(pixel_pos - player_screen_pos);
	float alpha = smoothstep(light_radius, light_radius + edge_softness, dist);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
