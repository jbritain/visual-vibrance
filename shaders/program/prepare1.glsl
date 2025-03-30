/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under the MIT license

      _____   __   _                          
     / ___/  / /  (_)  __ _   __ _  ___   ____
    / (_ /  / /  / /  /  ' \ /  ' \/ -_) / __/
    \___/  /_/  /_/  /_/_/_//_/_/_/\__/ /_/   
    
    By jbritain
    https://jbritain.net
                                            
*/

#include "/lib/common.glsl"

#ifdef vsh

    out vec2 texcoord;

    void main() {
        gl_Position = ftransform();
	    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

#ifdef fsh
    in vec2 texcoord;

    #include "/lib/util/spheremap.glsl"
    #include "/lib/atmosphere/sky/sky.glsl"
    #include "/lib/atmosphere/clouds.glsl"

    /* RENDERTARGETS: 7 */
    layout(location = 0) out vec3 color;

    void main(){
        vec3 dir = mat3(gbufferModelViewInverse) * unmapSphere(texcoord);

        color = getSky(vec3(0.0), dir, false);
        vec3 transmittance;
        vec3 scatter = getClouds(vec3(0.0), dir, transmittance);
        color = color * transmittance + scatter;
    }
#endif