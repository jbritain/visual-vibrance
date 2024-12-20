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
      if (renderStage == MC_RENDER_STAGE_STARS) {
        color = glcolor;
      } else {
        color = vec4(0.0);
      }

      color.rgb *= vec3(4.0, 4.0, 5.0);
      color.rgb = pow(color.rgb, vec3(2.2));
    }

#endif