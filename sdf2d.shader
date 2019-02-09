precision mediump float;

uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform vec4 iMouse;

vec3 palette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d) {
    t = clamp(t, 0.0, 1.0);
    return a + b * cos(6.28318 * (c * t + d));
}

vec2 screenToWorld(vec2 screen) {
    vec2 result = 2.0 * (screen / iResolution.xy - 0.5);
    result.x *= iResolution.x / iResolution.y;
    return result;
}

float sdf(vec2 p) {
    return p.y;
}

vec3 shade(float sd) {
    //float maxDist = 2.0;
    //vec3 cc = palette(sd, vec3(0.5,0.0,0.0),vec3(0.5,0.0,0.0),vec3(1.0,0.0,0.0),vec3(0.5,0.0,0.0));
    vec3 cc = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), smoothstep(-0.5, 0.5, sd));
    vec3 col = cc;
    
    col = mix(col, col * 1.0 - exp(-10.0*abs(sd)), 0.4);
    col *= 0.8 * cos(150.0 * sd);
    return mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, abs(sd)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = screenToWorld(fragCoord);

    float sd = sdf(p);
    
    //float t = step(0.0, sd);// * 0.5 + 0.5;
    //vec3 col = t == 1.0 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);// shade(sd);
    //vec3 col = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), t);
    vec3 col = shade(sd);
    fragColor = vec4(col, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}