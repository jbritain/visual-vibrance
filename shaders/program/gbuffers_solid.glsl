#include "/lib/common.glsl"

#ifdef vsh

    out vec2 lmcoord;
    out vec2 texcoord;
    out vec4 glcolor;

    void main() {
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;
    }

#endif

// ===========================================================================================

#ifdef fsh

    uniform float alphaTestRef = 0.1;

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {

        vec2 lightmap = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);

        vec4 albedo = texture(gtexture, texcoord) * glcolor;

        if (albedo.a < alphaTestRef) {
            discard;
        }

        albedo.rgb = pow(albedo.rgb, vec3(2.2));

        color = albedo;
    }

#endif