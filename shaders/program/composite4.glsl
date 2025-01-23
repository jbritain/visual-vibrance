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
    in vec2 texcoord;

    #include "/lib/dh.glsl"
    #include "/lib/shadowSpace.glsl"

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec3 scattering;

    void main() {
        scattering = vec3(0.0);

        #if GODRAYS == 1
            vec2 sampleCoord = texcoord;

            vec3 sunScreenPos = viewSpaceToScreenSpace(shadowLightPosition);

            sunScreenPos.xy = clamp(sunScreenPos.xy, vec2(-0.5), vec2(1.5));

            vec2 deltaTexcoord = (texcoord - sunScreenPos.xy);

            deltaTexcoord *= rcp(GODRAYS_SAMPLES) * GODRAYS_DENSITY;

            float decay = 1.0;

            sampleCoord -= deltaTexcoord * interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

            for(int i = 0; i < GODRAYS_SAMPLES; i++){
                vec3 scatterSample = texture(colortex4, sampleCoord).rgb;
                scatterSample *= decay * GODRAYS_WEIGHT;
                scattering += scatterSample;
                decay *= GODRAYS_DECAY;
                sampleCoord -= deltaTexcoord;
            }

            scattering /= GODRAYS_SAMPLES;
            scattering *= GODRAYS_EXPOSURE;
        #elif GODRAYS == 2 && defined SHADOWS

            float depth = texture(depthtex0, texcoord).r;
            vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

            if(depth == 1.0){
                viewPos = normalize(viewPos) * shadowDistance;
            }

            vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

            vec3 a = getShadowClipPos(vec3(0.0)).xyz;
            vec3 b = getShadowClipPos(feetPlayerPos).xyz;

            #define VL_SAMPLES 10

            vec3 sampleDelta = (b - a) * rcp(VL_SAMPLES);
            vec3 samplePos = a;

            samplePos += sampleDelta * interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

            for(int i = 0; i < VL_SAMPLES; i++){
                vec3 screenSamplePos = getShadowScreenPos(vec4(samplePos, 1.0));

                if(clamp01(screenSamplePos) != screenSamplePos){
                    break;
                }
                scattering += vec3(shadow2D(shadowtex0HW, screenSamplePos).r);
                samplePos += sampleDelta;
            }

            scattering /= VL_SAMPLES;
            scattering = pow2(scattering);
        #endif

    }

#endif