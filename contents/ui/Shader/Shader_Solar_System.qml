import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    property string pixelShader: `

// https://www.shadertoy.com/view/MdsfDl
// Credits to duvengar

#define T iTime

//// COLORS ////
const vec3 ORANGE = vec3(1.0, 0.6, 0.2);
const vec3 BLUE   = vec3(0.0, 0.3, 0.6);
const vec3 PINK   = vec3(1.0, 0.3, 0.2);
const vec3 BLACK  = vec3(0.0, 0.0, 0.0);

///// NOISE /////
float hash(float n) {
    return fract(sin(n)*43758.5453123);   
}

float noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0;
    return mix(mix(hash(n + 0.0), hash(n + 1.0), f.x), mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
}

////// FBM ////// 
// see iq // https://www.shadertoy.com/view/lsfGRr

mat2 m = mat2( 0.6, 0.6, -0.6, 0.8);
float fbm(vec2 p){
 
    float f = 0.0;
    f += 0.5000 * noise(p); p *= m * 2.02;
    f += 0.2500 * noise(p); p *= m * 2.03;
    f += 0.1250 * noise(p); p *= m * 2.01;
    f += 0.0625 * noise(p); p *= m * 2.04;
    f /= 0.9375;
    return f;
}


void mainImage( out vec4 C, in vec2 U ) 
{
    
    // Pixel ratio
    vec2 uv = U.xy / iResolution.xy;
    vec2 p = -1. + 2. * uv;   
    p.x *= iResolution.x / iResolution.y ;
    p *= 8.0;
    
  	/*_______________ CALCULS _______________*/
    
    // rotations angles
    float def = fbm(p*0.4);
    float angle  =  T;
    float angle2 =  T * 2.7;
    float angle3 =  T * 0.9;
    float angle4 =  T * 0.6;
   	
    // Perspective factor
    float fac =  smoothstep(10.0, -4.0, p.y)*2.;
    
    // Positions
    vec2 ctr = vec2(0.00 , 0.00);
    vec2 pos0 = vec2(ctr.x  + 0.50 * cos(angle),  ctr.y  + 0.50 * sin(angle ));
    vec2 pos1 = vec2(pos0.x + 6.00 * cos(angle),  pos0.y + 2.00 * sin(angle ));
    vec2 pos2 = vec2(pos1.x + fac * 0.90 * cos(angle2), pos1.y + fac * 0.30 * sin(angle2));
    vec2 pos3 = vec2(pos0.x + 9.50 * cos(angle3), pos0.y + 3.25 * sin(angle3));
    vec2 pos4 = vec2(pos0.x + 13.5 * cos(angle4), pos0.y + 4.50 * sin(angle4));
	
    // fbm angle
 	float r = sqrt(dot(p+pos0,p+pos0));
    
    float alpha = r * 0.2 + atan(dot(0.5, pow(abs(p.x), p.y)), dot(0.5, pow(abs(p.x),p.y))) - (iTime * 0.1); 
    // Distortion
    alpha +=  1.4 + fbm( 0.6 * p + pos0) ;
    
    
    /*_______________ COLORS _______________*/
 
    //------------------------//
    // COLORFULL CLOUDY COSMOS 
    //------------------------//
    
    float ff = 1.0 - smoothstep(00.0,20.0, length(p)); 
    vec3 color = vec3(ff * 0.05) ;  
     
    ff = smoothstep(0.3, 1.4,fbm(0.3 * p + T * 0.2)); 
  	color += mix(color, ORANGE, ff * 0.2);
    
    ff = smoothstep(0.3,0.9, fbm(0.1 * p + T * 0.4));
    color += mix(color, PINK  , ff * 0.3);
    
    ff = smoothstep(0.3,1.9, fbm(0.1 * p + T * 0.6));
  	color += mix(color, BLUE  , ff * 0.9);
    
    ff = smoothstep(0.3,0.9, fbm( .4 * p + T * 0.8));
  	color += mix(color, BLACK , ff * 0.1);
    
    color += mix(BLUE,color,0.7)*0.3;
    
    float v = smoothstep(0.0,20.0,length(p.y + pos4.y));
    
    //------------------------//
    // B&W SOLAR SYSTEM
    //------------------------//
    
	float col = 1.0 - smoothstep(02.,20.0, length(p));
    float f = smoothstep(0.2,1.9, fbm( 0.5 * p + T * 0.3 )); 
    col = mix(col, 0.0, f*0.9)*0.99;
    
    // Kind of star Field 
    for(float k = 0.10; k < 0.15; k += 0.01){
        if(fbm(vec2(10. * p + T)) < k){
            col += mix(col, 0.0, 0.1 * (k * 50.0));
        }
    }

 
    // Sun
    ff   = smoothstep( 0.00,1.90, length(p + pos0));
    col += mix(col,0.0,ff);   
  	col *= mix(col*2., 0.8, fbm(vec2(f*0.7,alpha)))*0.6;
	
    // Planete 01
    ff   = smoothstep(fac * 0.30,fac * 0.35, length(p + pos1)); 
    col -= mix(col,0.0,ff);
    ff   = smoothstep(fac * 0.20,fac * 0.53, length(p + pos1)); 
    col += mix(col,0.0,ff );
    
    // planete 02 / satelite 
    ff   = smoothstep(fac * 0.05,fac * 0.10, length(p + pos2));
    col -= mix(col,0.0,ff);
    ff   = smoothstep(0.00,fac * 0.20, length(p + pos2));
    col += mix(col,0.0,ff);
    
    // Planete 03
    ff   = smoothstep(fac * 0.45,fac * 0.50, length(p + pos3));
    col -= mix(col,0.0,ff);
    ff   = smoothstep(0.00,fac * 1.10, length(p + pos3)); 
    col += mix(col,0.0,ff);
    
    // Planete 04
    ff   = smoothstep(fac * 0.35 ,fac * 0.40, length(p + pos4));
    col -= mix(col,0.0,ff);
    ff   = smoothstep(fac * 0.20 ,fac * 0.72, length(p + pos4));
    col += mix(col,0.0,ff);
    col -= smoothstep(0.30, 2.1, length(p + pos0));  
    
    
 	//------------------------//
    // postprocessing
    //------------------------//
    
    // Final Color
    vec3 cc = mix(color, vec3(col), 0.55);   
    cc += mix(cc, BLUE,0.35);
    
    // Last sun burn
    ff = smoothstep( 0.00,1.90, length(p + pos0));
    cc += mix(cc,vec3(0.0),ff);
    cc *= 1.12345;
    
 	// Final output
	C = vec4( cc,1.0);
    
    }
`
}