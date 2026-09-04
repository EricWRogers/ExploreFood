shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, cull_disabled, depth_prepass_alpha;

// Basic textures — plug in your own
// filter_linear_mipmap = smooth filtering, good for most foliage textures at a distance.
// Swap to filter_nearest_mipmap if you want crisp/pixel-art style filtering instead —
// this is a compile-time hint, not adjustable at runtime.
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform vec2 uv_scale = vec2(2.1, 2.1);
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float brightness : hint_range(0.0, 4.0) = 1.0;

// Sway controls
uniform float sway_speed : hint_range(0.0, 5.0) = 1.0;
uniform float sway_strength : hint_range(0.0, 1.0) = 0.15;
uniform float sway_direction_rads : hint_range(-3.141, 3.141) = 0.0;
// How much the effect grows with height. Set this to the local-space
// height of your mesh's base (e.g. 0.0 if the trunk base sits at y=0
// in your mesh) so the bottom of the tree stays planted.
uniform float base_height = 0.0;

void vertex() {
	// Height above the base, in local mesh space.
	// Vertices at the base barely move; vertices further up swing more.
	float height_factor = max(VERTEX.y - base_height, 0.0);

	// Wind direction as a flat vector
	vec2 wind_dir = vec2(cos(sway_direction_rads), sin(sway_direction_rads));

	// A simple time-based oscillation. Using VERTEX position in the sine
	// input adds slight variation across the mesh so it doesn't move as
	// one rigid slab.
	float phase = TIME * sway_speed + VERTEX.x * 0.5 + VERTEX.z * 0.5;
	float sway = sin(phase) * sway_strength;

	// Push the vertex sideways, scaled by how high up it is.
	VERTEX.x += wind_dir.x * sway * height_factor;
	VERTEX.z += wind_dir.y * sway * height_factor;
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV * uv_scale);
	ALBEDO = tex.rgb * brightness;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	NORMAL = FRONT_FACING ? NORMAL : -NORMAL;
}