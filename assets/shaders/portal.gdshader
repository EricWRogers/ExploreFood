shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic;

// --- Texture transform (scale/rotate/offset the base image before the portal effect) ---
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform float uv_rotation_degrees : hint_range(0.0, 360.0) = 0.0;
uniform bool distort_on_rotate = false;

// --- Mesh opacity ---
uniform float mesh_opacity : hint_range(0.0, 1.0) = 1.0;

// --- Ripple (vertex-based water bulge) ---
uniform float ripple_strength : hint_range(0.0, 1.0) = 0.0;
uniform float ripple_speed = 1.5;
uniform float ripple_frequency = 8.0;
uniform float ripple_amplitude = 0.05;

// --- Portal vortex/twist ---
uniform vec4 portal_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float mesh_aspect_ratio = 1.0; // width / height of the mesh face, for a non-square plane
uniform float vortex_effect_radius : hint_range(0.01, 1.0, 0.01) = 0.5;
uniform float twist_strength : hint_range(0.0, 30.0, 0.1) = 8.0;
uniform float pulsation_speed : hint_range(0.0, 5.0, 0.01) = 0.7;
uniform float breath_magnitude : hint_range(-0.3, 0.3, 0.005) = 0.05;
uniform float overall_rotation_speed : hint_range(-2.0, 2.0, 0.01) = 0.25;
uniform float texture_scroll_speed_x : hint_range(-1.0, 1.0, 0.01) = 0.08;
uniform float texture_scroll_speed_y : hint_range(-1.0, 1.0, 0.01) = 0.03;
uniform float edge_softness : hint_range(0.01, 0.5, 0.005) = 0.1;

varying vec2 base_uv;

mat2 rotate(float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return mat2(vec2(c, -s), vec2(s, c));
}

void vertex() {
	vec2 centered_uv = UV - 0.5;

	float rad = radians(uv_rotation_degrees);
	mat2 base_rot = rotate(rad);

	if (distort_on_rotate) {
		centered_uv = base_rot * (centered_uv / uv_scale);
	} else {
		centered_uv = (base_rot * centered_uv) / uv_scale;
	}

	base_uv = centered_uv + 0.5 + uv_offset;
	UV = base_uv;

	// Ripple: vertex-space water bulge along the normal
	float t = TIME * ripple_speed;
	vec2 p = VERTEX.xy;
	float wave =
		sin(p.x * ripple_frequency + t) * 0.5 +
		sin(p.y * ripple_frequency * 1.3 - t * 1.2) * 0.3 +
		sin((p.x + p.y) * ripple_frequency * 0.7 + t * 0.8) * 0.2;

	VERTEX += NORMAL * wave * ripple_amplitude * ripple_strength;
}

void fragment() {
	vec2 uv = base_uv - 0.5;

	// Aspect correction so the vortex stays circular on non-square planes
	if (mesh_aspect_ratio > 1.0) {
		uv.x *= mesh_aspect_ratio;
	} else if (mesh_aspect_ratio < 1.0) {
		uv.y /= mesh_aspect_ratio;
	}

	float time_progress = sin(TIME * pulsation_speed);

	// Overall constant rotation of the whole portal
	if (overall_rotation_speed != 0.0) {
		uv = rotate(TIME * overall_rotation_speed) * uv;
	}

	float distance_from_center = length(uv);

	// Vortex/twist: rotation amount falls off with radius and pulses over time
	float twist_spatial_factor = smoothstep(0.0, vortex_effect_radius, vortex_effect_radius - distance_from_center);
	float current_animated_twist = twist_strength * time_progress;
	float twist_angle = twist_spatial_factor * current_animated_twist;

	if (distance_from_center < vortex_effect_radius) {
		uv = rotate(twist_angle) * uv;
	}

	// Breathing: pulsating shrink/expand
	float breath_value = breath_magnitude * time_progress;
	if (distance_from_center > 0.0001) {
		float new_radial_distance = max(0.0, distance_from_center + breath_value);
		uv *= (new_radial_distance / distance_from_center);
	}

	// Scroll the texture underneath the distortion
	vec2 texture_scroll_speed = vec2(texture_scroll_speed_x, texture_scroll_speed_y);
	vec2 final_uv = uv + TIME * texture_scroll_speed;

	// Revert aspect correction, then de-center back to 0-1 UV space
	if (mesh_aspect_ratio > 1.0) {
		final_uv.x /= mesh_aspect_ratio;
	} else if (mesh_aspect_ratio < 1.0) {
		final_uv.y *= mesh_aspect_ratio;
	}
	final_uv += 0.5;

	// Soft-edged portal falloff
	float alpha = smoothstep(vortex_effect_radius, vortex_effect_radius - edge_softness, distance_from_center);

	vec4 tex = texture(albedo_texture, fract(final_uv));

	ALBEDO = tex.rgb * portal_tint.rgb;
	ALPHA = tex.a * portal_tint.a * alpha * mesh_opacity;

	if (base_uv.x < 0.0 || base_uv.x > 1.0 || base_uv.y < 0.0 || base_uv.y > 1.0) {
		ALPHA = 0.0;
	}
}