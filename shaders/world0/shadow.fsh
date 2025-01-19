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
                                            
*/#define WORLD_OVERWORLD



#include "/lib/shadowSpace.glsl"

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in mat3 tbnMatrix;
flat in int materialID;
in vec3 shadowViewPos;
in vec3 feetPlayerPos;

#include "/lib/dh.glsl"
#include "/lib/lighting/shading.glsl"
#include "/lib/water/waterFog.glsl"
#include "/lib/water/waveNormals.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(gtexture, texcoord) * glcolor;

    if (color.a < alphaTestRef) {
        discard;
    }

    const float avgWaterExtinction = sum3(waterExtinction) / 3.0;

    if(materialID == MATERIAL_WATER){
        float opaqueDepth = texture(shadowtex1, gl_FragCoord.xy / shadowMapResolution).r;
        float opaqueDistance = getShadowDistanceZ(opaqueDepth); // how far away from the sun is the opaque fragment shadowed by the water?
        float waterDepth = abs(shadowViewPos.z - opaqueDistance);

        color.rgb = 1.0 - waterExtinction;
        color.a = 1.0 - (exp(-avgWaterExtinction * waterDepth));

        #ifdef CAUSTICS
            vec3 waveNormal = waveNormal(feetPlayerPos.xz + cameraPosition.xz, vec3(0.0, 1.0, 0.0), 1.0);
            vec3 refracted = refract(-worldLightDir, waveNormal, 1.0/1.33);

            vec3 oldPos = feetPlayerPos - worldLightDir * waterDepth;
            vec3 newPos = feetPlayerPos + refracted * waterDepth;

            float oldArea = length(dFdx(oldPos)) * length(dFdy(oldPos));
            float newArea = length(dFdx(newPos)) * length(dFdy(newPos));
            color.a *= (1.0 - oldArea / newArea);
        #endif
        
    }

    color.rgb = pow(color.rgb, vec3(2.2));
}