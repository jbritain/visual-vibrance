#ifndef SHADING_GLSL
#define SHADING_GLSL

#include "/lib/lighting/brdf.glsl"
#include "/lib/lighting/shadows.glsl"

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec2 lightmap, vec3 viewPos){
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    float scatter;
    vec3 shadow = getShadowing(feetPlayerPos, faceNormal, lightmap, material, scatter);

    vec3 color = 
        brdf(material, mappedNormal, faceNormal, viewPos, scatter) * sunlightColor *
        shadow
    ;
    vec3 diffuse = 
        skylightColor * pow2(lightmap.y) +
        vec3(255, 152, 54) * 1e-5 * max0(exp(-(1.0 - lightmap.x * 10.0))) +
        vec3(0.01)

        
    ;

    color += diffuse * material.albedo;

    color += material.emission * material.albedo * 16.0;

    return color;
}

#endif // SHADING_GLSL