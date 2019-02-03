
precision mediump float;

uniform vec3 iResolution;
uniform float iTime;

#define PI 3.14159265359

float plot(vec2 uv, float pt) {
    return smoothstep(pt + 0.001, pt, uv.y) - smoothstep(pt, pt - 0.001, uv.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float y = uv.x;
    //float y = pow(uv.x, 5.0);
    //float y = step(0.5, uv.x);
    //float y = smoothstep(0.1, 0.9, uv.x);
    //float y = smoothstep(0.2, 0.5, uv.x) - smoothstep(0.5, 0.8, uv.x);
    //float y = sin(uv.x * PI);
    //float y = cos(uv.x * PI);
    //float y = abs(cos(uv.x * PI));
    vec3 color = vec3(y);
    
    float pt = plot(uv, y);
    color = (1.0 - pt) * color + pt * vec3(0.0, 1.0, 0.0);
    
    fragColor = vec4(color, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}