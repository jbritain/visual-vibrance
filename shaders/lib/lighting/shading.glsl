#ifndef SHADING_GLSL
#define SHADING_GLSL

#include "/lib/lighting/brdf.glsl"

vec3 getShadedColor(Material material, vec3 mappedNormal, vec3 faceNormal, vec2 lightmap, vec3 viewPos){
    vec3 color = brdf(material, mappedNormal, faceNormal, viewPos) * sunlightColor * smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y);
    color += skylightColor * lightmap.y * material.albedo;

    return color;
}

#endif // SHADING_GLSL