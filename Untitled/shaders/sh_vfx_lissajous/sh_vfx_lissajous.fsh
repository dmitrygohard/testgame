// sh_vfx_lissajous.fsh
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform vec2 u_resolution;
uniform float u_progress;
uniform float u_seed;
uniform vec3 u_paletteA;
uniform vec3 u_paletteB;
uniform vec3 u_paletteC;
uniform vec3 u_paletteD;
uniform float u_brightness;
uniform float u_contrast;

void main() {
    vec2 uv = (v_vTexcoord - 0.5) * 2.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    // Lissajous curve parameters modulated by progress
    float a = 3.0 + 2.0 * sin(u_time * 0.3);
    float b = 2.0 + 2.0 * cos(u_time * 0.4);
    float delta = u_time * 2.0;
    
    // Calculate Lissajous position
    float t = u_time;
    vec2 lissajous = vec2(sin(a * t + delta), sin(b * t));
    
    // Distance to Lissajous curve with multiple time offsets for trail effect
    float dist = 0.0;
    for (float i = 0.0; i < 3.0; i++) {
        float time_offset = i * 0.3;
        vec2 trail_pos = vec2(
            sin(a * (t - time_offset) + delta),
            sin(b * (t - time_offset))
        );
        dist += 1.0 / (length(uv - trail_pos) * 20.0 + 1.0);
    }
    
    // Modulate with progress
    dist *= (0.5 + 0.5 * u_progress);
    
    // Color based on position and time
    vec3 color;
    float color_index = fract(dot(uv, vec2(0.1618, 0.3141)) + u_seed * 0.01);
    
    if (color_index < 0.25) color = u_paletteA;
    else if (color_index < 0.5) color = u_paletteB;
    else if (color_index < 0.75) color = u_paletteC;
    else color = u_paletteD;
    
    color *= dist;
    
    gl_FragColor = vec4(color * u_brightness, 1.0);
}