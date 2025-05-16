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
    out vec4 glcolor;

    void main() {
      gl_Position = ftransform();
      texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
      glcolor = gl_Color;
    }

#endif

// ===========================================================================================

#ifdef fsh

    in vec2 texcoord;
    in vec4 glcolor;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(gtexture, texcoord) * glcolor;

        #ifndef CUSTOM_SUN
        if (color.b < 0.3 && color.r > color.b) { // remove bloom
          discard;
        }
        #endif

        if(color.r > color.b) { // sun
          color.rgb *= vec3(10.0, 7.0, 5.0);
        }

        


        color.rgb = pow(color.rgb, vec3(2.2));
    }

#endif