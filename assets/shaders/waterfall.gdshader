shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_disabled;

uniform sampler2D texture_tex : source_color;
uniform sampler2D color_texture : source_color;
uniform sampler2D inv_texture : source_color;

// Scroll controls
uniform vec2 scroll_direction = vec2(0.0, 1.0); // (0,1) = scrolls "down" in UV space
uniform float scroll_speed = 0.5;

// Independent rotation per texture (degrees)
uniform float tex_rotation_degrees = 0.0;
uniform float color_tex_rotation_degrees = 0.0;
uniform float inv_tex_rotation_degrees = 0.0;

// UV scale (manual control — higher = texture tiles/repeats more, lower = zooms in)
uniform vec2 uv_scale = vec2(1.0, 1.0);

// Auto-compensate for mesh scale stretching (keeps texture proportions fixed regardless of node scale)
uniform bool auto_compensate_mesh_scale = false;

// Overall opacity multiplier
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

// Color tint
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

vec2 rotate_uv(vec2 uv, float degrees) {
	vec2 centered = uv - vec2(0.5);
	float rad = radians(degrees);
	mat2 rot = mat2(vec2(cos(rad), sin(rad)), vec2(-sin(rad), cos(rad)));
	centered = rot * centered;
	return centered + vec2(0.5);
}

void fragment() {
	vec2 dir = normalize(scroll_direction);

	// Base UV scaling, centered so it scales from the middle rather than the corner
	vec2 scale = uv_scale;

	if (auto_compensate_mesh_scale) {
		// Extract the mesh's world scale from MODEL_MATRIX basis vectors
		vec2 mesh_scale = vec2(
			length(MODEL_MATRIX[0].xyz),
			length(MODEL_MATRIX[1].xyz)
		);
		scale *= mesh_scale;
	}

	vec2 base_uv = (UV - vec2(0.5)) * scale + vec2(0.5);

	vec2 uv_tex = rotate_uv(base_uv, tex_rotation_degrees);
	uv_tex += dir * TIME * scroll_speed;
	uv_tex = fract(uv_tex);

	vec2 uv_color = rotate_uv(base_uv, color_tex_rotation_degrees);
	vec2 uv_inv = rotate_uv(base_uv, inv_tex_rotation_degrees);

	vec4 tex_color = texture(texture_tex, uv_tex);
	vec4 col_tex = texture(color_texture, uv_color);
	vec4 inv_color = texture(inv_texture, uv_inv);

	vec4 final_color = tex_color * col_tex + inv_color * (1.0 - tex_color.a);

	// Apply tint
	final_color.rgb *= tint_color.rgb;
	final_color.a *= tint_color.a;

	ALBEDO = final_color.rgb;
	ALPHA = final_color.a * alpha_multiplier;
}