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
    out vec3 dir;

    void main() {
      gl_Position = ftransform();
      vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
      dir = mat3(gbufferModelViewInverse) * normalize(viewPos);
      texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
      glcolor = gl_Color;
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/atmosphere/sky/sky.glsl"

    in vec2 texcoord;
    in vec4 glcolor;
    in vec3 dir;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
      if (renderStage == MC_RENDER_STAGE_STARS) {
        color = glcolor;
        color.rgb = pow(color.rgb, vec3(2.2));
      } else {
        color.rgb = getSky(dir, false);
      }
    }

#endif