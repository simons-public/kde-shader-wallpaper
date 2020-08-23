import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property Image iChannel0: Image { source: "./Shadertoy_Stars.jpg" }
    property string pixelShader: `

// https://www.shadertoy.com/view/tsBBzG
// Credits to NuSan

// Shader coded live during Outline Online 2020 in ~2h
// There is two scenes that you can switch by changing SCENE from 0 to 1

#define SCENE 0

float time = 0.;

#define repeat(a,b) (fract((a)/(b)+.5)-.5)*(b)
#define repid(a,b) floor((a)/(b)+.5)

float fft(vec2 t) {
  return texture(iChannel0, vec2((fract(t.x*10.)+fract(t.y))*.1)).x*50.;
}


vec2 rnd(vec2 p){
  
  return fract(sin(p*425.522+p.yx*847.554)*352.742);
}

float rnd(float a) {
  return fract(sin(a*254.574)*652.512);
}

float curve(float t, float d) {
  t/=d;
  return mix(rnd(floor(t)), rnd(floor(t)+1.), pow(smoothstep(0.,1.,fract(t)), 10.));
}

float tick(float t, float d) {
  t/=d;
  return (floor(t) + pow(smoothstep(0.,1.,fract(t)), 10.)) * d;
}



float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float at=0.;
float at2=0.;
#if SCENE==0
float map(vec3 p){
  
  //p.xy *= rot(sin(-length(p.xy)*.02 + time*2)*1+time);
  //p.yz *= rot(sin(-length(p.yz)*.03 + time*4)*1);
  p.xz *= rot(sin(-length(p.xz)*.07 + time*1.)*1.);
  
  
  p.y += pow(smoothstep(0.,1.,sin(-pow(length(p.xz),2.)*.001 + time*4.)),3.)*4.;
  
  float d=-p.y;
  
  for(float i=0.; i<4.; ++i) {
    vec3 p2 = p;
    p2.xz *= rot(i+.7);
    p2.xz -= 7.;
    float id=fft(rnd(repid(p2.xz, 10.)));
    p2.xz = repeat(p2.xz, 10.);
    
    d=min(d, box(p2, vec3(1,0.3*id,1)));
    //d=max(d, -box(p2, vec3(4,id*130,4)));
    
  }
  
  vec3 p3 = p;
  float t3 = time*.13;
  p3.xz *= rot(t3);
  p3.xy *= rot(t3*1.3);
  p3=repeat(p3, 5.);
  float d2 = box(p3, vec3(1.7));
  //d = max(d, -d2*1.3);
  d = min(d, d-d2*0.1);//*curve(time, .3));
  
  //d = min(d, -p.y);
  
  vec3 p4 = p;
  float t4 = time*1.33;
  p4.xz=repeat(p4.xz, 200.);
  p4.yz *= rot(t4);
  p4.xz *= rot(t4*1.3);
  
  at += 0.04/(1.2+abs(length(p4.xz)-17.));
  
  vec3 p5 = p;
  float t5 = time*1.23;
  p5.xz=repeat(p5.xz, 200.);
  p5.yz *= rot(t5*.7);
  p5.xy *= rot(t5);
  
  at2 += 0.04/(1.2+abs(box(p5,vec3(37))));
  
  //d -= sin(time);
  
  return d*.7;
}
#endif

float grid2(vec3 p) {
  float v=0.0;
  p *= 0.004;
  for(float i=0.; i<3.; ++i) {
    p *= 1.7;
    p.xz *= rot(0.3+i);
    p.xy *= rot(0.4+i*1.3);
    p += vec3(0.1,0.3,-.13)*(i+1.);
    vec3 g=abs(fract(p)-.5)*2.0;
    //v-=g.x*g.y*g.z*.7;
    v-=min(g.x,min(g.y,g.z))*.7;
  }
  return v;
}

#if SCENE==1
float map(vec3 p){
  
  //p.x += smoothstep(0,1,sin(p.y*.01 + time))*100*curve(time, .5);
  
  float ppy=p.y;
  
  p.y = repeat(p.y,300.);
  //p.x = repeat(p.x,500);
  
  p.xz *= rot(sin(-length(p.xz)*.0007 + time*.5 + ppy*.005)*1.);
  
  //p.xz *= rot(sin(-length(p.xz)*.07 + time*1 + p.y*.05)*1);
  
  vec3 p4=p;
  float t4=0.;
  p4.yz *= rot(t4);
  p4.xz *= rot(t4*1.3);
  
  float d = box(p4, vec3(20));
  float ss = 10.;
  d = max(d, -box(p4, vec3(ss,ss,100)));
  d = max(d, -box(p4, vec3(ss,100,ss)));
  d = max(d, -box(p4, vec3(100,ss,ss)));
  
  vec3 p3 = p;
  p3.xz *= rot(sin(time*3. + p.y*.01)*.3);
  p3.xz = abs(p3.xz)-30.;
  p3.xz = abs(p3.xz)-10.*(sin(time+p.y*.05)*.5+.5);
  d = min(d, length(p3.xz)-5.);
  
  
  float g = grid2(p);
  float d2 = d-5.-g*12.7;// * smoothstep(-1,1,sin(tick(time, 1)+p.y*.1));
  d = min(d+4.3, d2);
  
  vec3 p6 = p;
  float t6 = time*1.33;
  p6.xz=repeat(p6.xz, 40.);
  p6.yz *= rot(t6);
  p6.xz *= rot(t6*1.3);
  
  at += 0.04/(1.2+abs(length(p6.xz)-17.));
  
  vec3 p5 = p;
  float t5 = time*1.23;
  //p5.xz=repeat(p5.xz, 200);
  p5.yz *= rot(t5*.7);
  p5.xy *= rot(t5);
  
  at2 += 0.04/(0.7+abs(box(p5,vec3(37))));
  
  
  vec3 p7 = p;
  float t3 = time*.13;
  p7.xz *= rot(t3);
  p7.xy *= rot(t3*1.3);
  p7=repeat(p7, 5.);
  float d7 = box(p7, vec3(1.7));
  //d = max(d, -d7*1.3);
  d = min(d, d*.7-d7*0.7);//*curve(time, .3));
  
  return d*.7;
}
#endif

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
  uv -= 0.5;
  uv /= vec2(iResolution.y / iResolution.x, 1);
    
  time = mod(iTime*1., 300.);
  
  float si = 30.;// + 50 * curve(time, .1);
  vec2 grid=abs(fract(uv*si)-.5)*2.;
  //uv=floor(uv*si+.5)/si;
  
  

  vec3 s=vec3(0,0,-50);
  s.xz += (curve(time, 1.6)-.5)*30.;
  vec3 t=vec3(0);
  
  // SWITCH NIGHT MOOD
  float part = smoothstep(-0.1,.1,sin(time));
  
  float adv = time*.1;//tick(time, .5)*2;
  s.yz *= rot(sin(adv*.3)*.3+0.5);
  s.xz *= rot(adv);
 
#if SCENE==1  
  s.y -= 100.;
  s.x += 100.;
  
 
  float push=tick(time, .5) * 100.;
  s.y += push;
  t.y += push;
#endif
  
  
  vec3 cz=normalize(t-s);
  vec3 cx=normalize(cross(vec3(0,1,0), cz));
  vec3 cy=normalize(cross(cx, cz));
  float fov = 0.4;// + curve(time, 0.5)*1.3;
  vec3 r=normalize(uv.x*cx + uv.y*cy + fov*cz);
  
  vec3 col=vec3(0);
  
  vec3 p=s;
  for(int i=0; i<100; ++i) {
    float d=abs(map(p));
    if(d<0.01) {
      d=0.1;
      break;
    }
    if(d>300.) break;
    p+=r*d;
    //col += 0.001/(0.1+abs(d));
  }
  col += at * vec3(.3,.4,1) * (1.+curve(time, .3));
  col += at2 * vec3(1.0,.4,.6) * (1.+curve(time, .4));
  
  col *= part;
  
  
  //*
  float fog = 1.-clamp(length(p-s)/300.,0.,1.);
  
  vec2 off=vec2(0.01,0);
  vec3 n=normalize(map(p)-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
  vec3 l=normalize(-vec3(1,1.3,2));
  vec3 h=normalize(l-r);
  
  float sss=0.;
  for(float i=1.; i<20.; ++i){
    float dist = i*5.2;
    sss += smoothstep(0.,1.,map(p+l*dist)/dist);
    
  }
  vec3 col2 = vec3(0);
  col2 += sss * vec3(1,.3,.8) * .15 * fog ;
  
  float ao=smoothstep(0.,1.,map(p+n));
  
  vec3 sky = mix(vec3(1,.6,.7)*0.1/(.1+abs(r.y)), vec3(1,.9,.3)*10., pow(max(0.,dot(r,l)), 20.));
  
  col2 += max(0., dot(n,l)) * (pow(max(0.,dot(h,n)),10.))*fog*ao;
  
  col2 += pow(1.-fog,2.) * sky;
  col += col2*(1.-part);
  //*/
  
  /*
  float t3 = time*.1;
  col.xz *= rot(t3 + r.x*.17);
  col.yz *= rot(t3*1.2 + r.y*.13);
  col=abs(col);
  //*/
  
  col *= 1.2-length(uv);
  
  float lum = clamp(col.x,0.,1.);
  float factor = step(+1.-1.+0.7*lum,min(grid.x, grid.y))+.7;
  
  //col *= factor;
  
  col += max(col.yzx-1.,0.);
  col += max(col.zxy-1.,0.);
  
  col=smoothstep(0.,1.,col);
  col=pow(col, vec3(0.4545));
  
  fragColor = vec4(col, 1);
}
`
}