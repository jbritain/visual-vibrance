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

#include "/lib/common.glsl"

#ifdef vsh
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
#endif

// ===========================================================================================

#ifdef fsh
in vec2 texcoord;

#include "/lib/post/bloom.glsl"

/* RENDERTARGETS: 2 */
layout(location = 0) out vec4 bloomColor;

void main() {
  BloomTile tile = tiles[TILE_INDEX];
  BloomTile previousTile = tiles[max(0, TILE_INDEX - 1)];

  vec2 tileCoord = scaleToBloomTile(texcoord, tile); // scale up to encompass whole texture

  if (clamp01(tileCoord) != tileCoord) {
    #if TILE_INDEX == 0
    bloomColor = vec4(0.0); // write black to remove whatever from the buffer
    return;
    #else
    bloomColor = texture(colortex2, texcoord);
    return;
    #endif
  }

  #if TILE_INDEX > 0
  tileCoord = scaleFromBloomTile(tileCoord, previousTile); // scale down to encompass the tile we are downscaling
  bloomColor = vec4(downSample(colortex2, tileCoord, false), 1.0);
  #else
  bloomColor = vec4(downSample(colortex0, tileCoord, true), 1.0);
  #endif

}
#endif
