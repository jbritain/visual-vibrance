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

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

#include "/lib/atmosphere/sky/sky.glsl"

void main()
{
    const int samples = 16;

    // take a few hemisphere samples
    for(int i = 0; i < samples; i++){
        vec2 noise = blueNoise(vec2(0.0), i).rg;
        float phi = 2.0 * PI * noise.r;
        float cosTheta = noise.g;
        float sinTheta = fsqrt(1.0 - pow2(cosTheta));

        vec3 dir = vec3(
            sinTheta * cos(phi),
            sinTheta * sin(phi),
            cosTheta
        );

        skylightColor += getSky(dir, false);
    }
    skylightColor /= float(samples);

    if(lightningBoltPosition.xyz != vec3(0.0)){
        skylightColor += vec3(20.0, 20.0, 40.0);
        sunlightColor += vec3(20.0, 20.0, 40.0);
    }

    // skylightColor = mix(skylightColor, exp(-1.0 * 10 * skylightColor), wetness);
    // sunlightColor = mix(sunlightColor, exp(-1.0 * 10 * sunlightColor), wetness);
}

#endif