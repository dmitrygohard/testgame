uniform float u_time;
uniform vec2 u_resolution;
uniform float u_progress;
uniform int u_palette;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv *= 10.0;
    
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    
    float min_dist = 1.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(iuv + neighbor);
            point = 0.5 + 0.5 * sin(u_time + 6.2831 * point);
            vec2 diff = neighbor + point - fuv;
            float dist = length(diff);
            min_dist = min(min_dist, dist);
        }
    }
    
    vec3 color;
    if (u_palette == 0) {
        color = vec3(0.0, min_dist * u_progress, 0.5);
    } else {
        color = vec3(min_dist * u_progress, 0.0, 0.3);
    }
    
    gl_FragColor = vec4(color, 0.7);
}
