shader_type spatial;

uniform sampler2D albedo_texture : source_color;

uniform bool rim_light = true;
uniform float rim_thickness : hint_range(0.0, 1.0) = 0.5;
uniform float rim_intense : hint_range(0.0, 1.0) = 1.0;
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb;
}

void light() {
	float ndotl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	DIFFUSE_LIGHT += ALBEDO * ndotl * ATTENUATION;

	if (rim_light) {
		float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), mix(8.0, 1.0, rim_thickness));
		DIFFUSE_LIGHT += rim_color.rgb * fresnel * rim_intense * ndotl * ATTENUATION;
	}
}
