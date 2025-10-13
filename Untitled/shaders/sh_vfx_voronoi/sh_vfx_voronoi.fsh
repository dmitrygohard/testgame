// sh_vfx_voronoi.fsh
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

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    vec2 uv = v_vTexcoord * u_resolution / u_resolution.y;
    uv *= 4.0 + 2.0 * u_progress;
    
    vec2 i_uv = floor(uv);
    vec2 f_uv = fract(uv);
    
    float min_dist = 1.0;
    vec2 min_point;
    
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(i_uv + neighbor);
            point = 0.5 + 0.5 * sin(u_time * 0.5 + 6.2831 * point);
            
            vec2 diff = neighbor + point - f_uv;
            float dist = length(diff);
            
            if (dist < min_dist) {
                min_dist = dist;
                min_point = point;
            }
        }
    }
    
    // Smooth Voronoi
    min_dist = min_dist * min_dist;
    
    // Animate with progress
    float animated_dist = sin(min_dist * 10.0 + u_time * 3.0) * 0.5 + 0.5;
    animated_dist = pow(animated_dist, 1.0 + u_progress);
    
    // Color based on cell and distance
    vec3 color;
    float cell_hash = dot(min_point, vec2(1.0, 57.0));
    
    if (cell_hash < 0.25) color = u_paletteA;
    else if (cell_hash < 0.5) color = u_paletteB;
    else if (cell_hash < 0.75) color = u_paletteC;
    else color = u_paletteD;
    
    color = mix(color, color * animated_dist, 0.7);
    
    gl_FragColor = vec4(color * u_brightness, 1.0);
}