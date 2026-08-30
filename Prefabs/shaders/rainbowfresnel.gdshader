shader_type spatial;
render_mode cull_front, unshaded, depth_draw_always;

uniform float outline_width : hint_range(0.0, 0.05) = 0.01;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 rim_light_color : source_color = vec4(1.0, 0.95, 0.8, 1.0);
uniform vec3 light_direction = vec3(1.0, 1.0, 0.0); // points toward the "sun"
uniform float rim_sharpness : hint_range(1.0, 64.0) = 8.0;
uniform float rim_intensity : hint_range(0.0, 5.0) = 2.0;

varying vec3 world_normal;

void vertex() {
	VERTEX += NORMAL * outline_width;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 light_dir = normalize(light_direction);
	float rim = pow(max(dot(world_normal, light_dir), 0.0), rim_sharpness);

	ALBEDO = mix(outline_color.rgb, rim_light_color.rgb, rim);
	EMISSION = rim_light_color.rgb * rim * rim_intensity;
}