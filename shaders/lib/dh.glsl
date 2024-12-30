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

#ifndef DH_GLSL
#define DH_GLSL

bool DH_MASK = false;

#ifdef DISTANT_HORIZONS

int convertDHMaterialIDs(int id){
    switch(id) {
        case DH_BLOCK_WATER:
            return MATERIAL_WATER;

        case DH_BLOCK_LEAVES:
            return MATERIAL_LEAVES;
    }

    return 0;
}

void dhOverride(inout float depth, inout vec3 viewPos, bool opaque){
    if(depth != 1.0) return;


    if(opaque){
        depth = texture(dhDepthTex1, texcoord).r;
    } else {
        depth = texture(dhDepthTex0, texcoord).r;
    }

    if(depth == 1.0) return;

    DH_MASK = true;

    vec3 screenPos = vec3(texcoord, depth);

    screenPos *= 2.0; screenPos -= 1.0; // ndcPos
    vec4 homPos = dhProjectionInverse * vec4(screenPos, 1.0);
    viewPos = homPos.xyz / homPos.w;
}

#else

void dhOverride(inout float depth, inout vec3 viewPos, bool opaque){
  return;
}

#endif

#endif // DH_GLSL