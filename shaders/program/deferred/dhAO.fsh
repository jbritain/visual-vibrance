



in vec2 texcoord;

#include "/lib/dh.glsl"
#include "/lib/util/packing.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    #if defined DISTANT_HORIZONS && defined DH_AO
    float depth = texture(depthtex0, texcoord).r;
    vec3 viewPos;
    if(depth != 1.0){
        return;
    }

    dhOverride(depth, viewPos, false);
    if(depth == 1.0){
        return;
    }

    vec3 worldNormal = decodeNormal(texture(colortex1, texcoord).xy);
    vec3 normal = mat3(gbufferModelView) * worldNormal;

    mat3 tbn;
    tbn[2] = normal;
    tbn[0] = normal.yzx;
    tbn[1] = cross(tbn[0], tbn[2]);

    float occlusion;

    for(int i = 0; i < DH_AO_SAMPLES; i++){
        vec4 noise = blueNoise(texcoord, i + frameCounter * DH_AO_SAMPLES);

        float scale = i / float(DH_AO_SAMPLES);
        scale = mix(0.1, 1.0, pow2(scale));

        vec3 hemisphereDir = normalize(vec3(noise.x * 2.0 - 1.0, noise.y * 2.0 - 1.0, noise.z)) * noise.w * scale;

        vec3 sampleOffset = tbn * hemisphereDir;
        vec3 sampleViewPos = viewPos + sampleOffset * DH_AO_RADIUS;

        vec4 sampleClipPos = dhProjection * vec4(sampleViewPos, 1.0);
        vec3 sampleScreenPos = (sampleClipPos.xyz / sampleClipPos.w) * 0.5 + 0.5;

        sampleScreenPos.z = texture(dhDepthTex0, sampleScreenPos.xy).r;
        sampleClipPos = dhProjectionInverse * vec4(sampleScreenPos * 2.0 - 1.0, 1.0);
        sampleViewPos = sampleClipPos.xyz / sampleClipPos.w;


        float rangeCheck = smoothstep(0.0, 1.0, DH_AO_RADIUS / abs(viewPos.z - sampleViewPos.z));
        occlusion += float(sampleViewPos.z >= viewPos.z + DH_AO_BIAS) * rangeCheck;
    }

    occlusion /= DH_AO_SAMPLES;

    color.rgb *= 1.0 - occlusion;
    #endif

}