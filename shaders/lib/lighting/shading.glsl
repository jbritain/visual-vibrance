#ifndef SHADING_GLSL
#define SHADING_GLSL

#include "/lib/lighting/brdf.glsl"
#include "/lib/lighting/shadows.glsl"

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec2 lightmap, vec3 viewPos){
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    vec3 color = 
        brdf(material, mappedNormal, faceNormal, viewPos) * sunlightColor *
        getShadowing(feetPlayerPos, faceNormal, lightmap)
        
    ;
    vec3 diffuse = 
        skylightColor * lightmap.y +
        vec3(255, 152, 54) / 255.0 * lightmap.x
        
    ;

    color += diffuse * material.albedo;

    return color;
}

#endif // SHADING_GLSL