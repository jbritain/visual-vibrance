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

#ifndef DH_GLSL
#define DH_GLSL

bool dhMask = false;

#ifdef DISTANT_HORIZONS

int convertDHMaterialIDs(int id) {
  switch (id) {
    case DH_BLOCK_WATER:
      return MATERIAL_WATER;

    case DH_BLOCK_LEAVES:
      return MATERIAL_LEAVES;

    case DH_BLOCK_LAVA:
      return MATERIAL_LAVA;
  }

  return 0;
}

void dhOverride(inout float depth, inout vec3 viewPos, bool opaque) {
  dhMask = false;
  if (depth != 1.0) return;

  if (opaque) {
    depth = texture(dhDepthTex1, texcoord).r;
  } else {
    depth = texture(dhDepthTex0, texcoord).r;
  }

  if (depth == 1.0) return;

  dhMask = true;

  vec3 screenPos = vec3(texcoord, depth);

  screenPos *= 2.0;
  screenPos -= 1.0; // ndcPos
  vec4 homPos = dhProjectionInverse * vec4(screenPos, 1.0);
  viewPos = homPos.xyz / homPos.w;
}

#else

void dhOverride(inout float depth, inout vec3 viewPos, bool opaque) {
  return;
}

#endif

#endif // DH_GLSL
