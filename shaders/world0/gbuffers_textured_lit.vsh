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





#include "/lib/sway.glsl"

in vec2 mc_Entity;
in vec4 at_tangent;
in vec4 at_midBlock;
in vec2 mc_midTexCoord;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out mat3 tbnMatrix;
flat out int materialID;
out vec3 viewPos;
out float emission;

#ifdef PARALLAX
    flat out vec2 singleTexSize;
    flat out ivec2 pixelTexSize;
    flat out vec4 textureBounds;
#endif

void main() {
    materialID = int(mc_Entity.x + 0.5);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    emission = at_midBlock.w / 15.0;

    tbnMatrix[0] = normalize(gl_NormalMatrix * at_tangent.xyz);
    tbnMatrix[2] = normalize(gl_NormalMatrix * gl_Normal);
    tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * at_tangent.w);

    viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    #ifdef GBUFFERS_HAND
    gl_Position = ftransform();
    return;
    #endif

    #ifdef WAVING_BLOCKS
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    feetPlayerPos = getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock.xyz) - cameraPosition;
    viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
    #endif

    #ifdef PARALLAX
        vec2 halfSize      = abs(texcoord - mc_midTexCoord);
        textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);

        singleTexSize = halfSize * 2.0;
        pixelTexSize  = ivec2(singleTexSize * atlasSize);
    #endif

    gl_Position = gbufferProjection * vec4(viewPos, 1.0);
}
