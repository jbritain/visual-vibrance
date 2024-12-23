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
    #include "/lib/atmosphere/fog.glsl"

    in vec2 texcoord;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        float depth = texture(depthtex0, texcoord).r;
        if(depth == 1.0 || isEyeInWater == 1){
            return;
        }

        vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

        color.rgb = atmosphericFog(color.rgb, viewPos);
        
        
    }

#endif