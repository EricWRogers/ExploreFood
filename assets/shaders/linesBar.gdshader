shader_type canvas_item;


uniform vec4  line_color    : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float spacing       = 12.0;   // now in PIXELS, not UV units
uniform float thickness     = 2.0;    // pixels
uniform float hatch_angle   = 45.0;
uniform float jitter_freq   = 0.15;   // tune down since input is now pixel-scale
uniform float jitter_amp    = 1.5;    // pixels
uniform vec2  node_size     = vec2(100.0, 100.0);

// --- internals ---

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i),                 hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)),     u.x),
        u.y);
}

void fragment() {
    float a    = radians(hatch_angle);
    float cosA = cos(a), sinA = sin(a);
    vec2 px = UV * node_size;   // <-- convert to pixel space first
    vec2 pr = vec2(cosA * px.x + sinA * px.y,
                  -sinA * px.x + cosA * px.y);
    float idx    = floor(pr.y / spacing);
    float localY = pr.y - (idx + 0.5) * spacing;
    float j = (noise(vec2(pr.x * jitter_freq, idx)) - 0.5) * jitter_amp;
    float dist = abs(localY + j) - thickness;
    float mask = smoothstep(0.0, fwidth(dist), -dist);
    COLOR = vec4(line_color.rgb, line_color.a * mask);
}
