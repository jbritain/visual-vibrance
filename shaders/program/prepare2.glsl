/*
    Copyright (c) 2024 Josh Britain (jbritain)
    All rights reserved

     __   __ __   ______   __  __   ______   __           __   __ __   ______   ______   ______   __   __   ______   ______    
    /\ \ / //\ \ /\  ___\ /\ \/\ \ /\  __ \ /\ \         /\ \ / //\ \ /\  == \ /\  == \ /\  __ \ /\ "-.\ \ /\  ___\ /\  ___\   
    \ \ \'/ \ \ \\ \___  \\ \ \_\ \\ \  __ \\ \ \____    \ \ \'/ \ \ \\ \  __< \ \  __< \ \  __ \\ \ \-.  \\ \ \____\ \  __\   
     \ \__|  \ \_\\/\_____\\ \_____\\ \_\ \_\\ \_____\    \ \__|  \ \_\\ \_____\\ \_\ \_\\ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\ 
      \/_/    \/_/ \/_____/ \/_____/ \/_/\/_/ \/_____/     \/_/    \/_/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/ 
                                                                                                                        
    
    By jbritain
    https://jbritain.net
                                            
*/

#include "/lib/common.glsl"

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

layout (r32ui) uniform uimage3D voxelMap;

#include "/lib/atmosphere/sky/sky.glsl"

void main()
{
    skylightColor = texture(lightmap, vec2(0.0, 1.0)).rgb;
    sunlightColor = sunPosition == shadowLightPosition ? sunIrradiance : moonIrradiance;

    if(isEyeInWater == 1 && sunPosition == shadowLightPosition){
        sunlightColor *= vec3(1.5, 1.5, 0.5);
    }

    weatherFrameTimeCounter += frameTime * (wetness + thunderStrength) * 2.0;

    // skylightColor = mix(skylightColor, exp(-1.0 * 10 * skylightColor), wetness);
    // sunlightColor = mix(sunlightColor, exp(-1.0 * 10 * sunlightColor), wetness);
}

#endif

#ifdef vsh
    void main(){

    }
#endif

#ifdef fsh
#ifdef ROUGH_SKY_REFLECTIONS
    const bool colortex7MipmapEnabled = true;
#endif
    void main(){
        
    }

#endif