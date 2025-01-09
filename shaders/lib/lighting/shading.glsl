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

#ifndef SHADING_GLSL
#define SHADING_GLSL

#include "/lib/lighting/brdf.glsl"
#include "/lib/lighting/shadows.glsl"

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec2 lightmap, vec3 viewPos){
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    float scatter;
    vec3 shadow = getShadowing(feetPlayerPos, faceNormal, lightmap, material, scatter);

    vec3 color = 
        brdf(material, mappedNormal, faceNormal, viewPos, scatter) * weatherSunlightColor *
        shadow
    ;

    float ambient = 0.05;
    #ifdef WORLD_THE_NETHER
    ambient *= 4.0;
    #endif

    vec3 diffuse = 
        weatherSkylightColor * pow2(lightmap.y) * (material.ao * 0.5 + 0.5) +
        pow(vec3(255, 152, 54), vec3(2.2)) * 1e-8 * max0(exp(-(1.0 - lightmap.x * 10.0))) +
        vec3(ambient) * material.ao

        
    ;

    color += diffuse * material.albedo;

    color += material.emission * material.albedo * 32.0;

    return color;
}

#endif // SHADING_GLSL