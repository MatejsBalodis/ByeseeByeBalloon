shader_type canvas_item;

uniform float previous_transparency_coefficient : hint_range(.0, 1.0) = .0; // Where to start the fade out.
uniform float current_transparency_coefficient : hint_range(.0, 1.0) = .0; // Where to start the fade out.

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV); // For speed and convenience.
	COLOR = vec4(texture_color.rgb, texture_color.a * clamp(clamp(previous_transparency_coefficient, .0, 1.0) + UV.x * (current_transparency_coefficient - previous_transparency_coefficient), .0, 1.0));
}