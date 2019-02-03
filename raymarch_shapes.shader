
precision mediump float;

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURFACE_DIST 0.01

uniform vec3 iResolution;
uniform float iTime;

float distSphere(vec3 p, vec3 o, float r) {
    return length(p - o) - r;
}

float distCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 ab = b - a;
    vec3 ap = p - a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0.0, 1.0);
    
    vec3 c = a + (t * ab);
    
    return length(p - c) - r;
}

float distTorus(vec3 p, vec2 r) {
    float x = length(p.xz) - r.x;
    return length(vec2(x, p.y)) - r.y;
}

float distBox(vec3 p, vec3 s) {
    return length(max(abs(p) - s, 0.0));
}

float distCylinger(vec3 p, vec3 a, vec3 b, float r) {
    vec3 ab = b - a;
    vec3 ap = p - a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    //t = clamp(t, 0.0, 1.0);
    
    vec3 c = a + (t * ab);
    
    float x = length(p - c) - r;
    float y = (abs(t - 0.5) - 0.5) * length(ab);
    float e = length(max(vec2(x, y), 0.0));
    float i = min(max(x, y), 0.0);
    return e + i;
}

float GetDist(vec3 p) {
    vec4 s = vec4(0.0, 1.0, 6.0, 1.0);
    
    float planeDist = p.y;
    float sphereDist = distSphere(p, vec3(0.0, 1.0, 6.0), 1.0);// length(p - s.xyz) - s.w;
    float capsuleDist = distCapsule(p, vec3(0.0, 1.0, 6.0), vec3(1.0, 2.0, 6.0), 0.2);
    float torusDist = distTorus(p - vec3(0.0, 0.5, 6.0), vec2(1.5, 0.3));
    float boxDist = distBox(p - vec3(-3.0, 0.75, 6.0), vec3(0.75));
    float cylinderDist = distCylinger(p, vec3(0.0, 0.3, 3.0), vec3(3.0, 0.3, 5.0), 0.3);
    
    //float dist = min(sphereDist, planeDist);
    float dist = min(capsuleDist, planeDist);
    //float dist = min(torusDist, planeDist);
    dist = min(dist, torusDist);
    dist = min(dist, boxDist);
    dist = min(dist, cylinderDist);
    
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
    vec3 col = vec3(0.0, 0.0, 0.0);
    
    vec3 ro = vec3(0.0, 2.0, -4.0);
    vec3 rd = normalize(vec3(uv.x, uv.y - 0.2, 1.0));
    
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