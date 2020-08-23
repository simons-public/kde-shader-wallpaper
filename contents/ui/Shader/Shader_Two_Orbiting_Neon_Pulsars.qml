import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property string pixelShader: `

// https://www.shadertoy.com/view/Wty3zz
// Credits to izutionix

float DistLine(vec3 ro, vec3 rd, vec3 p) {
	return length(cross(p-ro, rd))/length(rd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    uv -= .5;
    uv.x *= iResolution.x/iResolution.y;

    vec3 ro = vec3(0., .5, -2.);
    vec3 rd = vec3(uv.x, uv.y, 0.)-ro;
    
    float t = iTime*2.;
    vec3 p =.5*vec3(sin(t), 0., .5+cos(t));
    vec3 q =.5*vec3(sin(t+3.1416), 0., .5+cos(t+3.1416));
    float d = DistLine(ro, rd, p);
    float e = DistLine(ro, rd, q);
    
    d = pow(.05/(d+0.), 1.);
    e = pow(.05/(e+0.), 1.);

    fragColor = vec4(d*vec3(1.,0.,1.)+e*vec3(0.,1.,1.),1.);
}
`
}