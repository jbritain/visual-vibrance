



#include "/lib/post/tonemap.glsl"
#include "/lib/post/processing.glsl"

in vec2 texcoord;

uniform sampler2D debugtex;

layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    #ifdef BLOOM
    vec3 bloom = texture(colortex2, texcoord).rgb;
    color.rgb = mix(color.rgb, bloom, 0.01 * BLOOM_STRENGTH);
    #endif

    color.rgb *= 2.0;
    color.rgb = tonemap(color.rgb);

    color = postProcess(color);

    #ifdef DEBUG_ENABLE
    color = texture(debugtex, texcoord);
    #endif
}