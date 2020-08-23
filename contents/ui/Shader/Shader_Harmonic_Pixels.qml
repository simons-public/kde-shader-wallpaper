import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property string pixelShader: `

// https://www.shadertoy.com/view/ldSGDm
// Credits to rafacacique

#ifdef GL_ES
precision mediump float;
#endif

const float PI = 3.141592654;
const float N_ITERATIONS = 50.0;

float usin(float t) {
	return sin(t) * 0.5 + 0.5;
}

float orb(float x0, float freqMul, float amp, float aspect, vec3 pos, float glow, float ampFreq) {
	float c = 0.0;
	float s = sin(iTime*ampFreq);
	for (float i = 0.0; i < N_ITERATIONS; i++) {
		float freq = freqMul*(i+1.0)/N_ITERATIONS;
		float x = x0+i/N_ITERATIONS;
		float y = 0.5 + s*sin(freq*iTime)*amp;
		
		vec3 circPos = vec3(x*aspect, y, 1.0);
		float f = 0.17;
	
		float sinTime = 1.0-usin(iTime)*0.3;
		float dx = pos.x - circPos.x;
		float dy = pos.y - circPos.y;
		float d = glow*(dx*dx + dy*dy);		
		c += f/(d*50.*sinTime);
	}
	
	return c;
}

vec4 bgColor(vec3 pos, vec2 fragCoord) {
	float f = fragCoord.y;
	f = float(mod(f/1.0, 3.0));
	
	float t = usin(iTime);
	vec4 c0 = vec4(1.0, 1.0, 1.0, 1.0);
	vec4 c1 = vec4(0.5, 0.5, 0.0, 1.0);
	vec4 c = mix(c0, c1, t);
	//c = vec4(1.0, 1.0, 1.0, 1.0);
	return c*f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float aspect = iResolution.x / iResolution.y;
	vec3 pos = vec3(fragCoord.xy / iResolution.xy, 1.0);// * 2.0 - vec2(1.0);
	pos.x *= aspect;
	
	const float amp = 0.3;
	const float x0 = 0.5/N_ITERATIONS;
	
	float r = orb(x0, 0.3, amp, aspect, pos, 2.5, 0.5);
	float g = orb(x0, 0.6, amp, aspect, pos, 4.5, 0.75);
	float b = orb(x0, 0.9, amp, aspect, pos, 6.5, 0.5);	
	
	float p = usin(iTime*1.2)*0.5+0.5;
	float q = 1.5 - p;
	vec4 color = vec4(r, q*g, p*b, 1.0);
	vec4 bg = bgColor(pos, fragCoord);
	color *= bg;
	color *= 1.0 - usin(2.0*iTime)*0.1;
	
	fragColor = color;
}

`
}