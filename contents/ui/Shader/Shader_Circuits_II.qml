import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property string pixelShader: `

// https://www.shadertoy.com/view/wlBcDK
// Credits to Kali

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat2 rot(float a) {
	float s=sin(a), c=cos(a);
    return mat2(c,s,-s,c);
}

vec3 fractal(vec2 p) 
{
   	p=vec2(p.x/p.y,1./p.y);
	p.y+=iTime*sign(p.y);
    p.x+=sin(iTime*.1)*sign(p.y)*4.;
    p.y=fract(p.y*.05);
    float ot1=1000., ot2=ot1, it=0.;
	for (float i=0.; i<10.; i++) {
    	p=abs(p);
        p=p/clamp(p.x*p.y,0.15,5.)-vec2(1.5,1.);
        float m=abs(p.x);
        if (m<ot1) {
        	ot1=m+step(fract(iTime*.2+float(i)*.05),.5*abs(p.y));
            it=i;
        }
        ot2=min(ot2,length(p));
    }
    
    ot1=exp(-30.*ot1);
    ot2=exp(-30.*ot2);
    return hsv2rgb(vec3(it*.1+.5,.7,1.))*ot1+ot2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy-.5;
    uv.x*=iResolution.x/iResolution.y;
    float aa=6.;
    uv*=rot(sin(iTime*.1)*.3);
    vec2 sc=1./iResolution.xy/(aa*2.);
    vec3 c=vec3(0.);
    for (float i=-aa; i<aa; i++) {
        for (float j=-aa; j<aa; j++) {
		    vec2 p=uv+vec2(i,j)*sc;
        	c+=fractal(p);
        }
    }
    fragColor = vec4(c/(aa*aa*4.)*(1.-exp(-20.*uv.y*uv.y)),1.);
}
`
}