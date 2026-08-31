// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode cull_disabled;

// --- Textures ---
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);

// --- Flower Settings ---
uniform sampler2D texture_flower : source_color, filter_linear_mipmap;
uniform float flower_density : hint_range(0.0, 1.0) = 0.0; // 0.0 = all leaves, 1.0 = all flowers
uniform float flower_size : hint_range(0.01, 1.0) = 1.0;

// --- Color Gradient ---
// Assign a GradientTexture1D here. 
uniform sampler2D color_gradient : source_color, repeat_disable; 

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

// --- Leaf Sway Uniforms ---
uniform float sway_speed = 1.0;         // How fast the leaves sway
uniform float sway_strength = 0.05;      // Max distance the leaves move (in world units)
uniform float sway_pivot_y = 1.0;       // Y-coordinate of the pivot point in local mesh space
uniform float sway_frequency = 0.5;     // Number of sine waves for variation

// --- Varyings ---
varying float instance_random; 

// Hash function
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Hash for sway
float rand_seed(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
    UV = UV * uv1_scale.xy + uv1_offset.xy;
    
    // Generate a fixed random number (0.0 to 1.0) per instance
    instance_random = hash(float(INSTANCE_ID));

    vec3 original_vertex = VERTEX;
    
    // --- Leaf Sway Logic ---
    float instance_rand_offset = rand_seed(MODEL_MATRIX[3].xz * 0.1);
    float time_offset = TIME * sway_speed + instance_rand_offset * 100.0;
    float wave_mag = sin(time_offset + original_vertex.y * sway_frequency) * sway_strength;
    
    float distance_from_pivot = max(0.0, sway_pivot_y - original_vertex.y);
    float sway_mask = distance_from_pivot / sway_pivot_y;
    
    vec3 displacement = vec3(wave_mag, 0.0, wave_mag * 0.5) * sway_mask;
    VERTEX += displacement;
    
    // Billboard Mode
	NORMAL = vec3(0.0, 1.0, 0.0);
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
            MAIN_CAM_INV_VIEW_MATRIX[0],
            MAIN_CAM_INV_VIEW_MATRIX[1],
            MAIN_CAM_INV_VIEW_MATRIX[2],
            MODEL_MATRIX[3]);
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	if (instance_random < flower_density) {
	    VERTEX.xy *= flower_size;
	}
}

void fragment() {
    if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
    
    vec4 final_color_tex;
	vec2 final_uv = UV; // Start with the base UV (which is 0.0 to 1.0)
	
    // --- Flower vs Leaf Logic ---
    // If our random number is less than the density, we become a flower.
    if (instance_random < flower_density) {
        
        final_color_tex = texture(texture_flower, UV);
        
        // Apply straight texture color (No tinting)
        ALBEDO = final_color_tex.rgb;
    } 
    else {
        // == LEAF MODE ==
        // Sample the leaf texture
        final_color_tex = texture(texture_albedo, UV);
        
        // Re-calculate randomness for gradient so we use the FULL gradient
        // regardless of how many flowers exist.
        float leaf_color_random = fract(instance_random * 123.45);
        
        // Sample gradient
        vec3 random_gradient_color = texture(color_gradient, vec2(leaf_color_random, 0.0)).rgb;
        
        // Apply tint
        ALBEDO = final_color_tex.rgb * random_gradient_color;
    }
    
    // Shared Alpha Logic
    ALPHA = final_color_tex.a; 
    ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
