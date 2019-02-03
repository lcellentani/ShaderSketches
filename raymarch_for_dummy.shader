
precision mediump float;

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURFACE_DIST 0.01

uniform vec3 iResolution;
uniform float iTime;

float GetDist(vec3 p) {
    vec4 s = vec4(0.0, 1.0, 6.0, 1.0);
    
    float sphereDist = length(p - s.xyz) - s.w;
    float planeDist = p.y;
    
    float dist = min(sphereDist, planeDist);
    return dist;
}

float RayMarch(vec3 ro, vec3 rd) {
    float distOrigin = 0.0;
    
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * distOrigin;
        float dist = GetDist(p);
        distOrigin += dist;
        if (distOrigin > MAX_DIST || dist < SURFACE_DIST) break;
    }
    
    return distOrigin;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p - e.xyy),
        GetDist(p - e.yxy),
        GetDist(p - e.yyx)
    );
    
    return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0.0, 5.0, 6.0);
    lightPos.xz += vec2(sin(iTime), cos(iTime)) * 2.0;
    vec3 l = normalize(lightPos - p);
    vec3 n = GetNormal(p);
    
    float NdotL = dot(n, l);
    float diff = clamp(NdotL, 0.0, 1.0);
    
    float dist = RayMarch(p + n * SURFACE_DIST * 2.0, l);
    if (dist < length(lightPos - p)) {
        diff *= 0.1;
    }
    
    return diff;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0, 1, 0);
    
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.0));
    
    float dist = RayMarch(ro, rd);
    
    vec3 p = ro + rd * dist;
    
    float diff = GetLight(p);
    
    col = vec3(diff);

    fragColor = vec4(col, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}