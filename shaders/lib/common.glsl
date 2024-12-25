#ifndef COMMON_GLSL
#define COMMON_GLSL

#include "/lib/common/settings.glsl"

#include "/lib/common/syntax.glsl"
#include "/lib/common/material.glsl"
#include "/lib/common/uniforms.glsl"
#include "/lib/common/util.glsl"
#include "/lib/common/spaceConversions.glsl"
#include "/lib/common/materialIDs.glsl"



vec3 sunDir = normalize(sunPosition);
vec3 worldSunDir = mat3(gbufferModelViewInverse) * sunDir;

vec3 lightDir = normalize(shadowLightPosition);
vec3 worldLightDir = mat3(gbufferModelViewInverse) * lightDir;

layout(std430, binding = 0) buffer lightColors {
    vec3 sunlightColor;
    vec3 skylightColor;
};

layout(std430, binding = 1) buffer smoothedData {
    float sunVisibilitySmooth;
};

#define weatherSunlightColor mix(sunlightColor, sunlightColor * 0.005, wetness)
#define weatherSkylightColor mix(skylightColor, sunlightColor * 0.02, wetness)

const bool colortex3Clear = false;

// BUFFER FORMATS
/*
    const int colortex0Format = RGB16F;
*/

#ifdef BLOOM
/*
    const int colortex2Format = RGB16F;
*/
#endif

#ifdef TEMPORAL_FILTER
/*
    const int colortex3Format = RGB16F;
*/
#endif

#endif // COMMON_GLSL