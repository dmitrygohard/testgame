uniform float u_time;
uniform vec2 u_resolution;
uniform float u_progress;
uniform int u_palette;

void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;
    float r = length(uv);
    float a = atan(uv.y, uv.x);
    
    float f = cos(a * 5.0 + u_time * 2.0) * u_progress;
    f = abs(f);
    
    vec3 color;
    if (u_palette == 0) {
        color = vec3(0.2, 0.5 + f, 0.8);
    } else {
        color = vec3(0.8, 0.3, 0.1 + f);
    }
    
    gl_FragColor = vec4(color * (1.0 - r), 0.6);
}