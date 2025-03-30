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
#include "/lib/util/spheremap.glsl"

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec3 blocklight, vec2 lightmap, vec3 viewPos, float shadowFactor){
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    float scatter;
    vec3 shadow = shadowFactor > 1e-6 ? getShadowing(feetPlayerPos, faceNormal, lightmap, material, scatter) * shadowFactor : vec3(0.0);

    vec3 color = 
        brdf(material, mappedNormal, faceNormal, viewPos, shadow, scatter) * weatherSunlightColor;

    float ambient = AMBIENT_STRENGTH;
    #ifdef WORLD_THE_NETHER
    ambient *= 4.0;
    #endif

    vec3 diffuse = material.albedo * (
        weatherSkylightColor * pow2(lightmap.y) * (material.ao * 0.5 + 0.5) +
        blocklight +
        vec3(ambient) * material.ao
    );

    vec3 fresnel = fresnelRoughness(material, dot(mappedNormal, normalize(-viewPos)));

    // max mip samples the whole sphere
    // therefore max mip minus 1 samples a hemisphere
    // so we blend with that based on roughness
    float mipLevel = log2(1.0 + material.roughness * (maxVec2(textureSize(colortex7, 0)) - 1.0));

    vec3 reflected = reflect(normalize(viewPos), mappedNormal);

    #ifdef ROUGH_SKY_REFLECTIONS
    vec3 specular = textureLod(colortex7, mapSphere(reflected), mipLevel).rgb * clamp01(smoothstep(13.5 / 15.0, 1.0, lightmap.y));
    color += mix(diffuse, specular, fresnel);
    #else
    color += diffuse;
    #endif

    color += material.emission * material.albedo * 32.0;

    return color;
}

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec2 lightmap, vec3 viewPos, float shadowFactor){
    vec3 blocklight = pow(vec3(255, 152, 54), vec3(2.2)) * 1e-8 * max0(exp(-(1.0 - lightmap.x * 10.0)));
    return getShadedColor(material, mappedNormal, faceNormal, blocklight, lightmap, viewPos, shadowFactor);
}

#endif // SHADING_GLSL