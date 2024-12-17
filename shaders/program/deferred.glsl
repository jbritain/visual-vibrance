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
    in vec2 texcoord;

    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);

        float depth = texture(depthtex0, texcoord).r;
        if(depth == 1.0){
            color.rgb = vec3(0.0);    
        }
    }

#endif