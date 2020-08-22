import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property string pixelShader: `

// https://www.shadertoy.com/view/MllGzS
// Credits to mhnewman

//	This shader takes random 2D slices through the 4D Julia set space.

//	The Mandelbrot set and Julia set generative formulas can be generalized as:
//	Z(0) = a + b*i
//	Z(n+1) = Z(n)^2 + c + d*i
//	Starting a and b at zero generates the Mandelbrot set.
//	Forcing c and d to remain constant generates a Julia set.
//	Together, these parameters (a, b, c, d) form a four dimensional space.
//	This shader randomly takes a two dimensional slice through this space.

//	Fractal iteration and supersampling adapted from iq:
//	https://www.shadertoy.com/view/4df3Rn

//	Hash function adapted from David Hoskins:
//	https://www.shadertoy.com/view/4djSRW


//	Supersampling factor
#define AA 3

//	Maximum fractal iteration
#define ITER 256

//	4D Fractal Brownian Motion used for sampling
vec4 fbm41(float p);

//	Specify the 4D sample position as a function of time and screen position
vec4 getPos(vec2 screenPos, float time) {
    
    //	4D center of image
    vec4 center = vec4(0.0, 0.0, -0.75, 0.0) + 0.7 * fbm41(0.3 * time);

    //	4D x and y unit vectors
    vec4 x = normalize(fbm41(0.2 * time));
    vec4 y = fbm41(0.2 * time + 9.33);
    y = normalize(y - x * dot(x, y));

    //	Zoom factor
    screenPos *= 1.2;

    return center + screenPos.x * x + screenPos.y * y;
}

vec4 hash41(float p) {
	vec4 p2 = fract(p * vec4(5.3983, 5.4427, 6.9371, 5.8815));
    p2 += dot(p2.zwxy, p2.xyzw + vec4(21.5351, 14.3137, 15.3219, 19.6285));
	return fract(vec4(p2.x * p2.y * 95.4337, p2.y * p2.z * 97.597, p2.z * p2.w * 93.8365, p2.w * p2.x * 91.7612));
}

vec4 noise41(float p) {
    float i = floor(p);
    float f = fract(p);
	float u = f * f * (3.0 - 2.0 * f);
    return 1.0 - 2.0 * mix(hash41(i), hash41(i + 1.0), u);
}

vec4 fbm41(float p) {
    vec4 f = noise41(p); p *= 2.01;
    f += 0.4 * noise41(p); p *= 2.01;
    f += 0.16 * noise41(p); p *= 2.01;
    f += 0.064 * noise41(p);
    return f / 1.624;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 color = vec3(0.0);
#if AA > 1
    for (int m = 0; m < AA; m++)
    for (int n = 0; n < AA; n++) {
        vec2 p = (-iResolution.xy + 2.0 * (fragCoord.xy + vec2(float(m), float(n)) / float(AA))) / iResolution.y;
        float w = float(AA * m + n);
        float time = iTime + 0.02 * w / float(AA * AA);
#else    
        vec2 p = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
        float time = iTime;
#endif
		vec4 pos = getPos(p, time);

        float outside = 0.0;
        float count = 0.0;
        vec2 z = pos.xy;
        vec2 c = pos.zw;
        for (int i = 0; i < ITER; i++) {
            z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

            if (dot(z, z) > 40.0) {
                outside = 1.0;
                break;
            }
            count += 1.0;
        }

        float grad = count - log2(log2(dot(z, z)));
        color += outside * (0.5 + 0.5 * cos(0.25 * grad + vec3(3.0, 4.0, 5.0)));
#if AA > 1
    }
    color /= float(AA * AA);
#endif
    fragColor = vec4(color, 1.0);
}
`
}