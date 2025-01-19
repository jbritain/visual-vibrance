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
    // remove bloom around moon by checking saturation since it's coloured while the moon is greyscale
    color = texture(gtexture, texcoord) * glcolor;
    vec3 color2 = hsv(color.rgb);

    if(color2.g > 0.5){
      discard;
    }

    if (color.a < 0.1) {
      discard;
    }


    color.rgb *= vec3(2.0, 2.0, 3.0);
    color.rgb = pow(color.rgb, vec3(2.2));
}