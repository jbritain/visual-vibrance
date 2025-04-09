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