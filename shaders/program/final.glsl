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
    #include "/lib/post/tonemap.glsl"

    in vec2 texcoord;

    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);

        vec3 bloom = texture(colortex2, texcoord).rgb;
        color.rgb = mix(color.rgb, bloom, 0.01);

        color.rgb = tonemap(color.rgb);

        

        // color.rgb = skylightColor;
        color.rgb = pow(color.rgb, vec3(rcp(2.2)));
    }

#endif