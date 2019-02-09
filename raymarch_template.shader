
precision mediump float;

uniform vec3 iResolution;
uniform float iTime;

#define PI 3.1415926535898
#define eps 0.005 
#define maxIterations 128
#define stepScale 0.5
#define stopThreshold 0.005 

float sphere(in vec3 p, in vec3 centerPos, float radius) {
    return length(p - centerPos) - radius;
}

float sinusoidBumps(in vec3 p){
    return sin(p.x*16.+iTime*0.57)*cos(p.y*16.+iTime*2.17)*sin(p.z*16.-iTime*1.31) + 0.5*sin(p.x*32.+iTime*0.07)*cos(p.y*32.+iTime*2.11)*sin(p.z*32.-iTime*1.23);
}

float scene(in vec3 p) {
    return sphere(p, vec3(0., 0. , 2.), 1.) + 0.04 * sinusoidBumps(p);
}

float rayMarching(vec3 origin, vec3 dir, float start, float end) {
    float sceneDist = 1e4;
    float rayDepth = start;
    for (int i = 0; i < maxIterations; i++) {
        sceneDist = scene(origin + dir * rayDepth);
        if ((sceneDist < stopThreshold) || (rayDepth >= end)) {
            break;
        }
        rayDepth += sceneDist * stepScale;
    }
    if (sceneDist >= stopThreshold) rayDepth = end;
	else rayDepth += sceneDist;
    
    return rayDepth;
}

vec3 getNormal(in vec3 p) {
    return normalize(vec3(
        scene(vec3(p.x + eps,p.y, p.z)) - scene(vec3(p.x - eps, p.y, p.z)),
        scene(vec3(p.x,p.y + eps, p.z)) - scene(vec3(p.x, p.y - eps, p.z)),
        scene(vec3(p.x, p.y, p.z + eps)) - scene(vec3(p.x, p.y, p.z - eps))
	));

    // Shorthand version of the above. The fewer characters used almost gives the impression that it involves fewer calculations. Almost.
	//vec2 e = vec2(eps, 0.);
	//return normalize(vec3(scene(p+e.xyy)-scene(p-e.xyy), scene(p+e.yxy)-scene(p-e.yxy), scene(p+e.yyx)-scene(p-e.yyx) ));
    
    // If speed is an issue, here's a slightly-less-accurate, 4-tap version. If fact, visually speaking, it's virtually the same, so on a
    // lot of occasions, this is the one I'll use. However, if speed is really an issue, you could take away the "normalization" step, then 
    // divide by "eps," but I'll usually avoid doing that.
    /*float ref = scene(p);
	return normalize(vec3(
		scene(vec3(p.x+eps,p.y,p.z))-ref,
		scene(vec3(p.x,p.y+eps,p.z))-ref,
		scene(vec3(p.x,p.y,p.z+eps))-ref
	));*/
	
	// The tetrahedral version, which does involve fewer calculations, but doesn't seem as accurate on some surfaces... I could be wrong,
	// but that's the impression I get.
	//vec2 e = vec2(-0.5*eps,0.5*eps);   
	//return normalize(e.yxx*scene(p+e.yxx)+e.xxy*scene(p+e.xxy)+e.xyx*scene(p+e.xyx)+e.yyy*scene(p+e.yyy)); 
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
	vec2 screenCoords = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec3 lookAt = vec3(0.0, 0.0, 0.0);
	vec3 camPos = vec3(0.0, 0.0, -5.0);
    
    vec3 forward = normalize(lookAt - camPos);
    vec3 right = normalize(vec3(forward.z, 0., -forward.x));
    vec3 up = normalize(cross(forward, right));
    
    float FOV = 0.5;
    vec3 ro = camPos; 
    vec3 rd = normalize(forward + FOV * screenCoords.x * right + FOV * screenCoords.y * up);
    
    vec3 bgcolor = vec3(1.0, 0.97, 0.92) * 0.15;
    float bgshade = (1.0 - length(vec2(screenCoords.x / aspect.x, screenCoords.y)));
	bgcolor *= bgshade;
    
    const float clipNear = 0.0;
	const float clipFar = 10.0;
	float dist = rayMarching(ro, rd, clipNear, clipFar);
	if (dist >= clipFar) {
	    fragColor = vec4(bgcolor, 1.0);
	    return;
	}
    
    vec3 sp = ro + rd * dist;
    vec3 surfNormal = getNormal(sp);
    
    vec3 lp = vec3(1.5 * sin(iTime * 0.5), 0.75 + 0.25 * cos(iTime * 0.5), -1.0);
    vec3 ld = lp - sp;
    vec3 lcolor = vec3(1.0, 0.97, 0.92);
    float len = length(ld);
	ld /= len;
	float lightAtten = min(1.0 / (0.25 * len * len), 1.0 );
    
    vec3 ref = reflect(-ld, surfNormal); 
    
    vec3 sceneColor = vec3(0.0);
    
	vec3 objColor = vec3(0.7, 1.0, 0.3);
	float bumps = sinusoidBumps(sp);
    objColor = clamp(objColor * 0.8 - vec3(0.4, 0.2, 0.1) * bumps, 0.0, 1.0);
	
	float ambient = 0.1;
	float specularPower = 16.0;
	float diffuse = max(0.0, dot(surfNormal, ld));
	float specular = max(0.0, dot(ref, normalize(camPos - sp))); 
	specular = pow(specular, specularPower);
    
	sceneColor += (objColor * (diffuse *0.8 + ambient) + specular * 0.5) * lcolor * lightAtten;

	fragColor = vec4(clamp(sceneColor, 0.0, 1.0), 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}