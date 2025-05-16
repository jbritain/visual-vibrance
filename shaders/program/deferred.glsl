/*
    Copyright (c) 2024 Josh Britain (jbritain)
    All rights reserved

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
    #include "/lib/atmosphere/sky/sky.glsl"
    #include "/lib/atmosphere/clouds.glsl"

    in vec2 texcoord;

    #include "/lib/dh.glsl"

    #if GODRAYS > 0
    /* RENDERTARGETS: 0,4 */
    #else
    /* RENDERTARGETS: 0 */
    #endif
    
    layout(location = 0) out vec4 color;


    #if GODRAYS > 0
    layout(location = 1) out vec3 occlusion;
    #endif

    void main() {
        color = texture(colortex0, texcoord);

        float depth = texture(depthtex0, texcoord).r;
        if(depth == 1.0){
            vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth)); 
            dhOverride(depth, viewPos, false);
            if(dhMask){
                return;
            }

            vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

            // color.rgb = getSky(color.rgb, worldDir, true);
            #ifdef WORLD_OVERWORLD
                vec3 transmittance;

                vec3 scattering = getClouds(vec3(0.0), feetPlayerPos, transmittance, depth);

                color.rgb = color.rgb * transmittance + scattering;

                #if GODRAYS > 0
                    occlusion = pow2(transmittance);
                #endif
            #endif
        }
    }

#endif