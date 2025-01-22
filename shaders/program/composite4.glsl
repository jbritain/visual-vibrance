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

    /* RENDERTARGETS: 4 */
    layout(location = 0) out vec3 scattering;

    void main() {
        scattering = vec3(0.0);

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

    }

#endif