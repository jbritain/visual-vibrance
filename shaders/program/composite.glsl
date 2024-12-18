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
    #include "/lib/util/screenSpaceRayTrace.glsl"
    #include "/lib/atmosphere/sky/sky.glsl"
    #include "/lib/lighting/shading.glsl"
    #include "/lib/waveNormals.glsl"
    #include "/lib/util/packing.glsl"

    in vec2 texcoord;

    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        vec4 data1 = texture(colortex1, texcoord);

        vec3 normal = mat3(gbufferModelView) * decodeNormal(data1.xy);
        float skyLightmap = data1.z;
        int materialID = int(data1.a * 255 + 0.5) + 1000;


        float translucentDepth = texture(depthtex0, texcoord).r;
        float opaqueDepth = texture(depthtex2, texcoord).r;

        vec3 translucentViewPos = screenSpaceToViewSpace(vec3(texcoord, translucentDepth));
        vec3 opaqueViewPos = screenSpaceToViewSpace(vec3(texcoord, opaqueDepth));

        vec3 translucentFeetPlayerPos = (gbufferModelViewInverse * vec4(translucentViewPos, 1.0)).xyz;

        bool isWater = materialID == MATERIAL_WATER;
        bool inWater = isEyeInWater == 1;

        // water fog when we're not in water
        if (!inWater && isWater){
            float distanceThroughWater = distance(opaqueViewPos, translucentViewPos);
            color.rgb *= exp(-distanceThroughWater * WATER_ABSORPTION);
        }

        // SSR
        if(isWater){
            Material material = Material(
                vec3(0.0),
                0.0,
                vec3(0.02),
                vec3(0.0),
                0.0,
                0.0,
                0.0,
                NO_METAL
            );

            normal = mat3(gbufferModelView) * waveNormal(translucentFeetPlayerPos.xz + cameraPosition.xz, mat3(gbufferModelViewInverse) * normal);

            float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
            vec3 reflectedDir = reflect(normalize(translucentViewPos), normal);
            vec3 reflectedPos;
            vec3 reflectedColor;

            vec3 shadow;
            float scatter = 0.0;

            if(rayIntersects(translucentViewPos, reflectedDir, 4, jitter, true, reflectedPos)){
                reflectedColor = texture(colortex0, reflectedPos.xy).rgb;
                shadow = vec3(0.0);
            } else {
                reflectedColor = getSky(mat3(gbufferModelViewInverse) * reflectedDir, false) * skyLightmap;
                shadow = getShadowing(translucentFeetPlayerPos, normal, vec2(skyLightmap), material, scatter);
            }



            reflectedColor += max0(brdf(material, normal, normal, translucentViewPos, scatter) * sunlightColor * shadow);

            vec3 fresnel = schlick(material, dot(normal, normalize(-translucentViewPos)));

            color.rgb = mix(color.rgb, reflectedColor, fresnel);
        }

        // water fog when we're in water
        if (inWater){
            float distanceThroughWater;
            if(isWater){
                distanceThroughWater = length(translucentViewPos);
            } else {
                distanceThroughWater = length(opaqueViewPos);
            }
            color.rgb *= exp(-distanceThroughWater * WATER_ABSORPTION);
        }
        
        
        


        
    }

#endif