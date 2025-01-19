#version 430 compatibility
#include "/lib/common.glsl"

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
#define WORLD_OVERWORLD



#include "/lib/shadowSpace.glsl"
#include "/lib/atmosphere/sky/sky.glsl"
#include "/lib/atmosphere/fog.glsl"

in vec2 texcoord;

#include "/lib/dh.glsl"
#include "/lib/util/packing.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);
    float depth = texture(depthtex0, texcoord).r;
    vec4 data1 = texture(colortex1, texcoord);
    vec3 worldNormal = decodeNormal(data1.xy);
    int materialID = int(data1.a * 255 + 0.5) + 1000;
    bool isWater = materialID == MATERIAL_WATER;
    if(isEyeInWater == 1){
        return;
    }

    vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
    dhOverride(depth, viewPos, false);

    bool infiniteOceanMask = false;

    #if defined INFINITE_OCEAN && defined WORLD_OVERWORLD
    if(depth == 1.0 && cameraPosition.y > 63.0){
        vec3 feetPlayerPos;
        if(rayPlaneIntersection(vec3(0.0, 0.0, 0.0), normalize(mat3(gbufferModelViewInverse) * viewPos), 63.0 - cameraPosition.y, feetPlayerPos)){
            viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
            depth = 0.5;
            isWater = true;
            infiniteOceanMask = true;
        }
    }
    #endif

    color.rgb = defaultFog(color.rgb, viewPos);

    #ifdef WORLD_OVERWORLD
    #ifdef ATMOSPHERIC_FOG
    if(depth != 1.0) color.rgb = atmosphericFog(color.rgb, viewPos);
    #endif
    #ifdef CLOUDY_FOG
    color.rgb = cloudyFog(color.rgb, mat3(gbufferModelViewInverse) * viewPos, depth);
    #endif
    #endif
}
