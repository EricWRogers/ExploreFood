shader_type spatial;

render_mode unshaded, blend_mix, depth_draw_never;

uniform float transparency : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    ALBEDO = vec3(1.0);
    ALPHA = COLOR.a * transparency;
}
