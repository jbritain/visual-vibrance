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

    in vec2 texcoord;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        float depth = texture(depthtex0, texcoord).r;
        if(depth == 1.0){
            return;
        }

        vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        vec3 viewDir = normalize(viewPos);
        vec3 worldDir = normalize(feetPlayerPos);
        
        color.rgb = mix(color.rgb, getSky(worldDir, false), smoothstep(0.8 * far, far, length(viewPos)));
    }

#endif