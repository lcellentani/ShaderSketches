precision mediump float;

uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;

float x;

vec4 line(vec2 uv) {
    float d = abs(uv.x - x / iResolution.x);
    return vec4(0.0, 0.0, 0.0, d < 0.001 ? 1.0 : 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    fragColor = vec4(col, 1.0);
    
    x = iMouse.x;
    vec4 cl = line(uv);

    fragColor = mix(fragColor, cl, cl.a);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}