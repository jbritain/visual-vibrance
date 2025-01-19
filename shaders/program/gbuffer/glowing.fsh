


#include "/lib/util/packing.glsl"

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
flat in int materialID;
in vec3 viewPos;
in vec3 normal;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 outData1;

void main() {
    color = texture(gtexture, texcoord) * glcolor;
    if(color.a < alphaTestRef){
        discard;
    }
    color.rgb = pow(color.rgb, vec3(2.2));

    color.rgb *= 50.0;

    outData1.xy = encodeNormal(mat3(gbufferModelViewInverse) * normal);
    outData1.z = 0.0;
    outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));
}
