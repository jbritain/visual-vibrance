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

    #include "/lib/dh.glsl"

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec3 occlusion;

    void main() {
        occlusion = texture(colortex4, texcoord).rgb;
        bool visible = texture(depthtex0, texcoord).r == 1.0;

        #ifdef DISTANT_HORIZONS
        visible = visible && texture(dhDepthTex0, texcoord).r == 1.0;
        #endif

        occlusion *= vec3(visible ? 1.0 : 0.0);
    }

#endif