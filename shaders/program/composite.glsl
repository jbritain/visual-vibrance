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

    /* RENDERTARGETS: 6 */
    layout(location = 0) out float depth;

    void main() {
        #ifdef DISTANT_HORIZONS
        depth = texture(depthtex0, texcoord).r;
        if(depth < 1.0){
            depth = screenSpaceToViewSpace(depth);
            depth = viewSpaceToScreenSpace(depth, combinedProjection);
            return;
        }
        depth = texture(dhDepthTex0, texcoord).r;

        if(depth == 1.0){
            return;
        }

        depth = screenSpaceToViewSpace(depth, dhProjectionInverse);
        depth = viewSpaceToScreenSpace(depth, combinedProjection);
        #endif
    }

#endif