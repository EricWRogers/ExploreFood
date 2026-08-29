shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_sharpness : hint_range(1.0, 10.0) = 4.0;

void vertex() {
	// Left empty intentionally, but keeps Godot happy
}

void fragment() {
	// Calculate the angle between the camera view and the surface normal
	float fresnel = dot(NORMAL, VIEW);
	
	// Invert it so the edges are 1.0 and the center is 0.0
	fresnel = 1.0 - clamp(fresnel, 0.0, 1.0);
	
	// Sharpen the edge transition so it looks like a clean line
	float edge = pow(fresnel, outline_sharpness);
	
	// Apply the outline
	ALBEDO = outline_color.rgb;
	ALPHA = edge * outline_color.a;
}