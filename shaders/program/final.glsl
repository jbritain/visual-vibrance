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
    #include "/lib/post/tonemap.glsl"
    #include "/lib/post/processing.glsl"

    in vec2 texcoord;

    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);

        #ifdef BLOOM
        vec3 bloom = texture(colortex2, texcoord).rgb;
        color.rgb = mix(color.rgb, bloom, 0.01 * BLOOM_STRENGTH);
        #endif

        color.rgb *= 2.0;
        color.rgb = tonemap(color.rgb);

        color = postProcess(color);
    }

#endif