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




in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  if (renderStage == MC_RENDER_STAGE_STARS) {
    color = glcolor;
  } else {
    color = vec4(0.0);
  }

  color.rgb *= vec3(4.0, 4.0, 5.0);
  color.rgb = pow(color.rgb, vec3(2.2));
}