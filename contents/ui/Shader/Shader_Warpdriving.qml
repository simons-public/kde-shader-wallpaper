import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property Image iChannel0: Image { source: "./Shadertoy_Gray_Noise_Medium.png" }
    property string pixelShader: `

// https://www.shadertoy.com/view/XllGz4
// Credits to migi0027

const float gSpeed = 1.0;
const float gSpeedMult = 2.0;
const int StarQuality = 70;
const int DustQuality = 50;

float GetTime()
{
    return (iTime+29.) * 60.0 * 3.0 * gSpeed;
}

vec2 WarpUV(vec2 buv, vec2 uv, float f)
{
    return uv; // Comment this line for black hole effect, its not soo good
    float d = distance(buv / iResolution.xy, vec2(0.5, 0.5));
    uv *= 1.0 - pow(0.007, d);
    return uv;
}

vec4 Noise( in ivec2 x )
{
    vec4 noise0 = texture( iChannel0, (vec2(x)+0.5)/256.0, -100.0 );
	return noise0;
}

mat2 GetRotation()
{
    // Reverse the rotation effect
    float time = GetTime();
    time *= -0.005;
    return mat2(cos(time), sin(time), -sin(time), cos(time));
}

vec2 GetUV(vec2 BaseUV)
{
    float time = GetTime();
    vec2 uv = (BaseUV.xy / iResolution.xy) * 2.0 - 1.0;
    uv.x = (uv.x * iResolution.x / iResolution.y) + sin(time*0.005) * 0.5;
    uv *= GetRotation();
    uv = WarpUV(BaseUV, uv, 1.5);
    return uv;
}

vec3 GenStarfield(vec2 BaseUV)
{
    vec3 r = vec3(GetUV(BaseUV), 1.0);
    
    float opac = sin(gSpeed);
    float mspeed = gSpeed * gSpeedMult;
    
    float d = 0.5 * iTime;
    float s2 = mspeed;
    float s = s2 + 0.1; // add a small offset
    
    d += d*gSpeed*gSpeedMult*0.96;
    
    vec3 accum = vec3(0,0,0);
    vec3 spp = r/max(abs(r.x),abs(r.y));
    vec3 p = 2.0 * spp + 0.5;
    
    for (int i = 0; i < StarQuality; i++)
    {
        float z = Noise(ivec2(p.xy)).x;
		z = fract(z-d);
		float d2 = 50.0*z-p.z;
		float w = pow(max(0.0,1.0-8.0*length(fract(p.xy)-.5)),2.0);
		vec3 c = max(vec3(0),vec3(1.0-abs(d2+s2*.5)/s,1.0-abs(d2)/s,1.0-abs(d2-s2*.5)/s));
		accum += 1.5*(1.0-z)*c*w;
		p += spp;
    }
    
    return pow(accum, vec3(1.0/2.2))*opac;
}

vec3 GenDust(vec2 BaseUV)
{
    float time = GetTime();
    
    float s = 0.0;
    float v = 0.0;
    vec2 uv = GetUV(BaseUV);
    vec3 accum = vec3(0);
    vec3 init = vec3(0.25, 0.25 + sin(time * 0.001) * 0.4, floor(time) * 0.0008);
    
    float intensity = mix(1.0, 10.0, 1.0 - float(DustQuality) / 100.0);
	for (int r = 0; r < DustQuality; r++) 
	{
		vec3 p = init + s * vec3(uv, 0.143);
		p.z = mod(p.z, 2.0);
		for (int i=0; i < 10; i++)	p = abs(p * 2.04) / dot(p, p) - 0.75;
		v += length(p * p) * smoothstep(0.0, 0.5, 0.9 - s) * .002;
		accum +=  vec3(v * 0.8, 1.1 - s * 0.5, .7 + v * 0.5) * v * 0.013;
		s += .01;
	}
    
    return accum*intensity;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 BaseUV =fragCoord.xy;
    vec3 dust = GenDust(BaseUV);
	vec3 stars = GenStarfield(BaseUV);
    
    fragColor = vec4(stars + dust, 1);
}
`
}