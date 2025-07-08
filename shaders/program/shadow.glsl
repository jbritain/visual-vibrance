/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under a custom non-commercial license.
    See LICENSE for full terms.

     __   __ __   ______   __  __   ______   __           __   __ __   ______   ______   ______   __   __   ______   ______    
    /\ \ / //\ \ /\  ___\ /\ \/\ \ /\  __ \ /\ \         /\ \ / //\ \ /\  == \ /\  == \ /\  __ \ /\ "-.\ \ /\  ___\ /\  ___\   
    \ \ \'/ \ \ \\ \___  \\ \ \_\ \\ \  __ \\ \ \____    \ \ \'/ \ \ \\ \  __< \ \  __< \ \  __ \\ \ \-.  \\ \ \____\ \  __\   
     \ \__|  \ \_\\/\_____\\ \_____\\ \_\ \_\\ \_____\    \ \__|  \ \_\\ \_____\\ \_\ \_\\ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\ 
      \/_/    \/_/ \/_____/ \/_____/ \/_/\/_/ \/_____/     \/_/    \/_/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/ 
                                                                                                                        
    
    By jbritain
    https://jbritain.net
                                            
*/

// because the chunks fade in dev decided to make having your shader injected opt out
#define CHUNKS_FADE_IN_NO_MOD_INJECT

#include "/lib/common.glsl"
#include "/lib/shadowSpace.glsl"
#include "/lib/water/waterFog.glsl"

#ifdef vsh
layout(r32ui) uniform uimage3D voxelMap;

#include "/lib/sway.glsl"
#include "/lib/voxel/voxelMap.glsl"
#include "/lib/voxel/voxelData.glsl"
#include "/lib/ipbr/blocklightColors.glsl"

in vec2 mc_Entity;
in vec4 at_tangent;
in vec4 at_midBlock;
in vec2 mc_midTexCoord;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
flat out int materialID;
out vec3 feetPlayerPos;
out vec3 shadowViewPos;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;

  materialID = int(mc_Entity.x + 0.5);

  shadowViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;

  #ifdef FLOODFILL
  ivec3 voxelPos = mapVoxelPos(
    feetPlayerPos + vec3(at_midBlock.xyz * rcp(64.0))
  );
  if (
    isWithinVoxelBounds(voxelPos) &&
    gl_VertexID % 4 == 0 &&
    (renderStage == MC_RENDER_STAGE_TERRAIN_SOLID ||
      // renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES ||
      renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT)
  ) {
    VoxelData data;
    vec4 averageTextureData =
      textureLod(gtexture, mc_midTexCoord, 4) * gl_Color;

    data.color = getBlocklightColor(materialID);
    if (data.color == vec3(0.0)) {
      data.color = pow(averageTextureData.rgb, vec3(2.2));
    }
    data.opacity = pow(averageTextureData.a, rcp(3));
    data.emission = pow2(at_midBlock.w / 15.0);
    // data.emission = textureLod(specular, mc_midTexCoord, 4).a;
    // if(data.emission == 1.0){
    //     data.emission = 0.0;
    // }

    if (materialIsWater(materialID)) {
      data.emission = 0.0;
    }

    if (materialIsLightBlock(materialID)) {
      data.emission = 1.0;
      data.color = vec3(1.0);
    }

    if (materialIsTintedGlass(materialID)) {
      data.opacity = 1.0;
    }

    if (materialIsLetsLightThrough(materialID)) {
      data.opacity = 0.0;
    }

    if (materialIsWater(materialID)) {
      data.color = 1.0 - WATER_SCATTERING;
    }

    uint encodedVoxelData = encodeVoxelData(data);
    imageAtomicMax(voxelMap, voxelPos, encodedVoxelData);
  }
  #endif

  #ifdef WAVING_BLOCKS
  feetPlayerPos =
    getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock.xyz) -
    cameraPosition;
  shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
  #endif
  gl_Position = gl_ProjectionMatrix * vec4(shadowViewPos, 1.0);

  gl_Position.xyz = distort(gl_Position.xyz);
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
flat in int materialID;
in vec3 shadowViewPos;
in vec3 feetPlayerPos;

#include "/lib/dh.glsl"
#include "/lib/lighting/shading.glsl"
#include "/lib/water/waterFog.glsl"
#include "/lib/water/waveNormals.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out float waterMask;

void main() {
  vec4 color = texture(gtexture, texcoord) * glcolor;

  if (color.a < alphaTestRef) {
    discard;
  }

  const float avgWaterExtinction = sum3(waterExtinction) / 3.0;

  waterMask = 0.0;

  if (materialIsWater(materialID)) {
    waterMask = 1.0;
  }
}

#endif
