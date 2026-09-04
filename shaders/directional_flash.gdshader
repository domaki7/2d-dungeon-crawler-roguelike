shader_type canvas_item;

// Screen-edge flash weighted toward the direction a hit came from, so damage
// direction is readable mid-fight without turning the camera.

uniform vec2 flash_dir = vec2(0.0, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(0.8, 0.05, 0.05, 1.0);
// Fraction of the screen half-extent that lights up, measured from the edge.
uniform float band_width : hint_range(0.01, 1.0) = 0.22;

void fragment() {
	// Centre-relative coords: -1 at one edge, +1 at the other.
	vec2 p = UV * 2.0 - 1.0;

	// Only the outer band glows; the middle of the screen stays clear.
	float edge = smoothstep(1.0 - band_width, 1.0, max(abs(p.x), abs(p.y)));

	// Fade the band around the screen so only the struck side lights up.
	vec2 dir = normalize(flash_dir + vec2(0.0001, 0.0));
	float toward = dot(normalize(p + vec2(0.0001, 0.0)), dir);
	float side = smoothstep(0.05, 0.85, toward);

	COLOR = vec4(flash_color.rgb, edge * side * strength);
}
