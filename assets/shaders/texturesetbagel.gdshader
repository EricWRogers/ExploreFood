shader_type spatial;
render_mode unshaded;

uniform sampler2D mesh_texture : source_color;

void fragment() {
    ALBEDO = texture(mesh_texture, UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
