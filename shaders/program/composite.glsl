/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under the MIT license

      _____   __   _                          
     / ___/  / /  (_)  __ _   __ _  ___   ____
    / (_ /  / /  / /  /  ' \ /  ' \/ -_) / __/
    \___/  /_/  /_/  /_/_/_//_/_/_/\__/ /_/   
    
    By jbritain
    https://jbritain.net
                                            
*/

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
    #include "/lib/water/waveNormals.glsl"
    #include "/lib/util/packing.glsl"
    #include "/lib/water/waterFog.glsl"
    #include "/lib/atmosphere/fog.glsl"
    #include "/lib/atmosphere/clouds.glsl"

    in vec2 texcoord;

    #include "/lib/dh.glsl"

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        vec4 data1 = texture(colortex1, texcoord);

        vec3 normal = mat3(gbufferModelView) * decodeNormal(data1.xy);
        float skyLightmap = data1.z;
        int materialID = int(data1.a * 255 + 0.5) + 1000;

        bool isWater = materialID == MATERIAL_WATER;
        bool inWater = isEyeInWater == 1;

        float translucentDepth = texture(depthtex0, texcoord).r;
        float opaqueDepth = texture(depthtex2, texcoord).r;

        vec3 translucentViewPos = screenSpaceToViewSpace(vec3(texcoord, translucentDepth));
        vec3 opaqueViewPos = screenSpaceToViewSpace(vec3(texcoord, opaqueDepth));

        dhOverride(translucentDepth, translucentViewPos, false);
        dhOverride(opaqueDepth, opaqueViewPos, true);

        vec3 viewDir = normalize(translucentViewPos);

        vec3 translucentFeetPlayerPos = (gbufferModelViewInverse * vec4(translucentViewPos, 1.0)).xyz;

        #ifdef INFINITE_OCEAN
        if(translucentDepth == 1.0 && !inWater && cameraPosition.y > 63.0){
            if(rayPlaneIntersection(vec3(0.0, 0.0, 0.0), normalize(translucentFeetPlayerPos), 63.0 - cameraPosition.y, translucentFeetPlayerPos)){
                translucentViewPos = (gbufferModelView * vec4(translucentFeetPlayerPos, 1.0)).xyz;
                normal = mat3(gbufferModelView) * vec3(0.0, 1.0, 0.0);
                isWater = true;
            }
        }
        #endif

        if(isWater){

            Material material = Material(
                vec3(0.0),
                0.0,
                vec3(0.02),
                vec3(0.0),
                0.0,
                0.0,
                0.0,
                NO_METAL,
                0.0
            );

            vec3 waveNormal = mat3(gbufferModelView) * waveNormal(translucentFeetPlayerPos.xz + cameraPosition.xz, mat3(gbufferModelViewInverse) * normal, clamp01(sin(abs(normalize(translucentFeetPlayerPos).y) * PI / 2.0)));

            // refraction
            #ifdef REFRACTION
            vec3 refractionNormal = normal - waveNormal;

            vec3 refractedDir = normalize(refract(viewDir, refractionNormal, !inWater ? rcp(1.33) : 1.33)); // when in water it should be rcp(1.33) but unless I use the actual normal (which results in snell's window) this results in no refraction
            vec3 refractedViewPos = translucentViewPos + refractedDir * distance(translucentViewPos, opaqueViewPos);
            vec3 refractedPos = viewSpaceToScreenSpace(refractedViewPos);
            if(clamp01(refractedPos.xy) == refractedPos.xy && texture(depthtex2, refractedPos.xy).r > translucentDepth){
                color = texture(colortex0, refractedPos.xy);
                opaqueDepth = texture(depthtex2, refractedPos.xy).r;
                opaqueViewPos = screenSpaceToViewSpace(vec3(texcoord, opaqueDepth));
            } 
            #endif

            // water fog when we're not in water
            if (!inWater){
                color.rgb = waterFog(color.rgb, translucentViewPos, opaqueViewPos);
            }

            // SSR
            float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
            vec3 reflectedDir = reflect(viewDir, waveNormal);
            vec3 reflectedPos;
            vec3 reflectedColor;

            float scatter = 0.0;

            #if REFLECTION_MODE > 0
            bool doReflections = true;

            #ifdef DISTANT_HORIZONS
            if(DH_MASK){
                doReflections = false;
            }
            #endif
            #else
            bool doReflections = false;
            #endif

            float fadeFactor = 0.0;

            if(doReflections && rayIntersects(translucentViewPos, reflectedDir, SSR_STEPS, jitter, true, reflectedPos)){
                reflectedColor = texture(colortex0, reflectedPos.xy).rgb;
                vec3 viewReflectedPos = screenSpaceToViewSpace(reflectedPos);
                vec3 playerReflectedPos = mat3(gbufferModelViewInverse) * viewReflectedPos;
                #ifdef ATMOSPHERIC_FOG
                reflectedColor = atmosphericFog(reflectedColor, viewReflectedPos);
                #endif
                #ifdef CLOUDY_FOG
                reflectedColor = cloudyFog(reflectedColor, playerReflectedPos, reflectedPos.z);
                #endif
                #ifdef FADE_REFLECTIONS
                fadeFactor = 1.0 - smoothstep(0.9, 1.0, maxVec2(abs(reflectedPos.xy - 0.5)) * 2);
                #else
                fadeFactor = 1.0;
                #endif
            }

            if(fadeFactor < 1.0){
                vec3 worldReflectedDir = mat3(gbufferModelViewInverse) * reflectedDir;
                vec3 skyReflection = getSky(worldReflectedDir, false) * skyLightmap;
                vec3 shadow = getShadowing(translucentFeetPlayerPos, waveNormal, vec2(skyLightmap), material, scatter);
                skyReflection += max0(brdf(material, waveNormal, waveNormal, translucentViewPos, scatter) * weatherSunlightColor * shadow);
                skyReflection = mix(skyReflection, getClouds(translucentFeetPlayerPos, skyReflection, worldReflectedDir), skyLightmap);

                skyReflection = mix(skyReflection, weatherSkylightColor, wetness);

                reflectedColor = mix(skyReflection, reflectedColor, fadeFactor);
            }

            

            vec3 fresnel = schlick(material, dot(waveNormal, normalize(-translucentViewPos)));

            color.rgb = mix(color.rgb, reflectedColor, fresnel);
        }

        // water fog when we're in water
        if (inWater){
            float distanceThroughWater;
            if(isWater){
                color.rgb = waterFog(color.rgb, vec3(0.0), translucentViewPos);
            } else {
               color.rgb = waterFog(color.rgb, vec3(0.0), opaqueViewPos);
            }
        }
    }

#endif