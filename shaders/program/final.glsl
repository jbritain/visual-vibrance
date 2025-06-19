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
#include "/lib/post/tonemap.glsl"
#include "/lib/post/processing.glsl"

in vec2 texcoord;

uniform sampler2D debugtex;

layout(location = 0) out vec4 color;

void main() {
  color = texture(colortex0, texcoord);

  #ifdef BLOOM

  #if BLOOM_PIXELATION > 0
  const bool colortex2MipmapEnabled = true;

  vec3 bloom = texelFetch(
    colortex2,
    ivec2(texcoord * textureSize(colortex2, BLOOM_PIXELATION)),
    BLOOM_PIXELATION
  ).rgb;
  #else
  vec3 bloom = texture(colortex2, texcoord).rgb;
  #endif

  float rain = texture(colortex5, texcoord).r;
  color.rgb = mix(
    color.rgb,
    bloom,
    clamp01(0.01 * BLOOM_STRENGTH + rain * 0.1 + wetness * 0.05 + blindness)
  );

  color.rgb *= 1.0 - 0.8 * blindness;
  #endif

  color.rgb *= 1.0 - 0.95 * blindness;

  color.rgb *= 4.0;
  color.rgb = tonemap(color.rgb);

  color = postProcess(color);

  #ifdef DEBUG_ENABLE
  color = texture(debugtex, texcoord);
  #endif
}

#endif
