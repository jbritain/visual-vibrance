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

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    const bool colortex0MipmapEnabled = true;

    #include "/lib/post/FXAA.glsl"

    void main() {
      // color = texture(colortex0, texcoord);
      // return;
      color.rgb = FXAA311(texture(colortex0, texcoord).rgb);
      color.a = 1.0;
    }

#endif