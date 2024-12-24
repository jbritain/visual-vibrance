#include "/lib/common.glsl"

#ifdef vsh

    in vec2 mc_Entity;
    in vec4 at_tangent;

    out vec2 lmcoord;
    out vec2 texcoord;
    out vec4 glcolor;
    out vec3 viewPos;

    void main() {
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        feetPlayerPos.zy = rotate(feetPlayerPos.zy, 0.3);
        viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;

        gl_Position = gbufferProjection * vec4(viewPos, 1.0);
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/lighting/shading.glsl"
    #include "/lib/util/packing.glsl"
    #include "/lib/lighting/directionalLightmap.glsl"

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    in vec3 viewPos;

    /* RENDERTARGETS: 0,1 */
    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 outData1;

    void main() {

        color = texture(gtexture, texcoord) * glcolor;

        if (color.a < alphaTestRef) {
            discard;
        }

        if(color.b > color.r){ // rain, not snow
            color = vec4(vec3(1.0), 0.1);
        }

        outData1 = vec4(0.0);
    }

#endif