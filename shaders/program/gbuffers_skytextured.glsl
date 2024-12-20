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

#endif