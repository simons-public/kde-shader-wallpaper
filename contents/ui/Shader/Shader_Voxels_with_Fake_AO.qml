import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property Image iChannel0: Image { source: "./Shadertoy_RGBA_Noise_Medium.png" }
    property string pixelShader: `

// https://www.shadertoy.com/view/MsVczV
// Credits to flockaroo

// created by florian berger (flockaroo) - 2018
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// voxels with fake ao
// using dist from actual distance field as a fake ao parameter.

#define SHADOW
//#define ONLY_VOXEL
#define GRID_LINES

#ifdef SHADEROO
#include Include_A.glsl
#endif

#ifdef SHADEROO
float distCar(vec3 pos)
{
    //return length(pos)-.5;
    float sc = 1.;
    vec4 q = vec4(0,0,0,1);
    q=multQuat(q,axAng2Quat(vec3(0,0,1),iTime*.5));
    //q=multQuat(q,axAng2Quat(vec3(1,0,0),iTime*.17));
    vec3 pos2;
    pos=transformVecByQuat(pos,q);

    vec3 tpos=clamp(pos*sc,-.95,.95);
    float d=texture(iChannel1,pos*sc*.5+.5).x/sc;
    //d+=maxcomp(abs(tpos-pos));
    d+=length(tpos-pos*sc)*.5/sc;
    
    return d;
}
#endif

//vec3 light=normalize(vec3(cos(iTime),sin(iTime),sin(iTime*.17)));
vec3 light=normalize(vec3(1,.6,.3));

float torusDist(vec3 pos, float R, float r)
{
    return length(vec2(length(pos.xy)-R,pos.z))-r;
}

#define randSampler iChannel0

// this is a somewhat modified version of iq's noise in shadertoy "volcanic"
vec4 noise3Dv4(vec3 texc)
{
    vec3 x=texc*256.0;
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    vec2 uv;
    uv = (p.xy+vec2(17,7)*p.z) + 0.5 + f.xy;
    vec4 v1 = textureLod( randSampler, uv/256.0, 0.0);
    vec4 v2 = textureLod( randSampler, (uv+vec2(17,7))/256.0, 0.0);
    return mix( v1, v2, f.z );
}

float distTor(vec3 pos)
{
    vec4 q = vec4(0,0,0,1);
    q=multQuat(q,axAng2Quat(vec3(1,0,0),PI2*.125));
    q=multQuat(q,axAng2Quat(vec3(0,0,1),iTime*.5+2.));
    pos=transformVecByQuat(pos,q);
    
    pos+=.100*(noise3Dv4(pos*.015).xyz-.5);
    pos+=.050*(noise3Dv4(pos*.030).xyz-.5);
    pos+=.025*(noise3Dv4(pos*.060).xyz-.5);
    float d=torusDist(pos+vec3(.33,0,0),.66,.25);
    d=min(d,torusDist((pos-vec3(.33,0,0)).xzy,.66,.25));
    return d;
}

#ifdef SHADEROO
float dist(vec3 pos)
{
    return fract(iTime*.1)<.5?distCar(pos):distTor(pos);
}
#else
#define iMouseData vec4(0)
float dist(vec3 pos)
{
    return distTor(pos);
}
#endif

vec3 grad(vec3 pos, float eps)
{
    vec3 d=vec3(eps,0,0);
    return vec3(
        dist(pos+d.xyz)-dist(pos-d.xyz),
        dist(pos+d.zxy)-dist(pos-d.zxy),
        dist(pos+d.yzx)-dist(pos-d.yzx)
        )/eps/2.;
}

bool checkSolid(vec3 pos)
{
    return dist(pos)-.002<.0;
}

bool gridStep(inout vec3 pos, inout vec3 n, vec3 grid, vec3 dir)
{
    float l,lmin=10000.;
    vec3 s = sign(dir);
    // find next nearest cube border (.00001 -> step a tiny bit into next cube)
    vec3 next=floor(pos/grid+s*(.5+.00001)+.5)*grid; // assuming floor(x+1.)==ceil(x)
    l=(next.x-pos.x)/dir.x; if (l>0. && l<lmin) { lmin=l; n=-vec3(1,0,0)*s; }
    l=(next.y-pos.y)/dir.y; if (l>0. && l<lmin) { lmin=l; n=-vec3(0,1,0)*s; }
    l=(next.z-pos.z)/dir.z; if (l>0. && l<lmin) { lmin=l; n=-vec3(0,0,1)*s; }
    
    pos+=dir*lmin;
    return checkSolid((floor((pos-.5*n*grid)/grid)+.5)*grid);
}

void march(inout vec3 pos, vec3 dir, inout float dmin)
{
    float eps=.001;
    float dtot=0.;
    dmin=10000.;
    float dp=dist(pos);
    for(int i=0;i<100;i++)
    {
        float d=dist(pos);
        if(d<dp) dmin=min(d,dmin);
        dp=d;
        d*=.8;
        pos+=d*dir;
        dtot+=d;
        if(d<eps) break;
        if(dtot>4.) { pos-=(dtot-4.)*dir; break; }
    }
}

void march(inout vec3 pos, vec3 dir)
{
    float dmin;
    march(pos,dir,dmin);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ph=iMouse.x/iResolution.x*7.;
    float th=-(iMouse.y/iResolution.y-.5)*3.;
    if(iMouse.x<1.) th=-0.1;
    if(iMouse.y<1.) ph=2.3;
    vec3 fwd = vec3(vec2(cos(ph),sin(ph))*cos(th),sin(th));
    vec3 right=normalize(vec3(fwd.yx*vec2(1,-1),0));
    vec3 up=cross(right,fwd);
    vec3 pos=-fwd*2.5*(1.-iMouseData.z*.001);
    vec2 sc=(fragCoord/iResolution.xy-.5)*2.*vec2(1,iResolution.y/iResolution.x);
    vec3 dir=normalize(fwd*1.6+right*sc.x+up*sc.y);
    vec3 n;
    vec3 grid=vec3(.05);
    //#define MARCH
    float ao=1.;
    float br=1.;
    #ifndef ONLY_VOXEL
    if(fragCoord.x>iResolution.x*.5+(fragCoord.y-iResolution.y*.5)*.4)
    {
        march(pos,dir);
        n=grad(pos,.01)*exp(-dist(pos)*20.);
        ao*=1.-8.*max(.05-dist(pos+n*.1),0.);
        #ifdef SHADOW
        vec3 pos2=pos+light*.01;
        float dmin;
        march(pos2,light,dmin);
        // getting dmin for soft shadow (see http://iquilezles.org/www/articles/rmshadows/rmshadows.htm)
        if(dist(pos2)<.01) ao *=.6 ;
        else
        	ao*=1.-.4*(1.-clamp(dmin/.05,0.,1.));
        #endif
    }
    else
    #endif
    {
        vec3 pos0=pos;
        float bg=1.;
        for(int i=0;i<100;i++)
        {
            if(gridStep(pos,n,grid,dir)) { bg=0.; break; }
            //if(length(pos-pos0)>3.5) break;
        }
        
        vec3 pf=pos/grid-floor(pos/grid);
        vec3 pc=pos/grid-ceil(pos/grid);
        vec3 s=sin(pos/grid*PI2*.5);
        // marking the voxel borders
        #ifdef GRID_LINES
        br*=1.-.15*(dot(exp(-s*s/.05),vec3(1))-1.);
        br*=1.-.075*(dot(exp(-s*s/.5),vec3(1))-1.);
        #endif
        // ao due to dist to actual distfield from voxel pos
        ao*=clamp(.8+.25*(dist(pos)+.03)/grid.x,0.,1.);
        // normal ao like in raymarching
        ao*=1.-3.*max(.1-dist(pos+n*.2),0.);
        if(bg==1.) { br=1.; ao=1.; n=vec3(0,0,1); pos=pos0+4.*dir; }
        
        #ifdef SHADOW
        vec3 pos2=pos+n*.0001,n2;
        for(int i=0;i<100;i++)
        {
            if(gridStep(pos2,n2,grid,light)) { ao*=.6; break; }
        }
        #endif
    }
    float fog=clamp(1.5-.5*length(pos),0.,1.);
    //fog=1.;
    sc=(fragCoord-.5*iResolution.xy)/iResolution.x;
    float vign = 1.-.3*dot(sc,sc);
    vign*=1.-.7*exp(-sin(fragCoord.x/iResolution.x*3.1416)*20.);
    vign*=1.-.7*exp(-sin(fragCoord.y/iResolution.y*3.1416)*10.);
    fragColor=vec4(max(clamp(dot(n,light),-.5,1.)*.3-n*.03+.7,.0)*1.2*vec3(1.,.9,.8)*ao*fog*vign*br,1.);
    //fragColor=vec4(vec3(ao),1.);
}


`
}