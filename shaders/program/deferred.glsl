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

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);

        float depth = texture(depthtex0, texcoord).r;
        if(depth == 1.0){
            vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth)); 

            vec3 worldDir = mat3(gbufferModelViewInverse) * normalize(viewPos);

            color.rgb = getSky(color.rgb, worldDir, true);
            #ifdef WORLD_OVERWORLD
            color.rgb = getClouds(vec3(0.0), color.rgb, worldDir);
            #endif
        }
    }

#endif