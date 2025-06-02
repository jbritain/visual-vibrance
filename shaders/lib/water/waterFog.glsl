/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under a custom non-commercial license.
    See LICENSE for full terms.

     __   __ __   ______   __  __   ______   __           __   __ __   ______   ______   ______   __   __   ______   ______    
    /\ \ / //\ \ /\  ___\ /\ \/\ \ /\  __ \ /\ \         /\ \ / //\ \ /\  == \ /\  == \ /\  __ \ /\ "-.\ \ /\  ___\ /\  ___\   
    \ \ \'/ \ \ \\ \___  \\ \ \_\ \\ \  __ \\ \ \____    \ \ \'/ \ \ \\ \  __< \ \  __< \ \  __ \\ \ \-.  \\ \ \____\ \  __\   
     \ \__|  \ \_\\/\_____\\ \_____\\ \_\ \_\\ \_____\    \ \__|  \ \_\\ \_____\\ \_\ \_\\ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\ 
      \/_/    \/_/ \/_____/ \/_____/ \/_/\/_/ \/_____/     \/_/    \/_/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/ 
                                                                                                                        
    
    By jbritain
    https://jbritain.net
                                            
*/

#ifndef WATER_FOG_GLSL
#define WATER_FOG_GLSL

#define WATER_ABSORPTION (vec3(1.0, 0.08, 0.1) * (isEyeInWater == 1 ? vec3(0.2) : vec3(1.0)))
#define WATER_SCATTERING (vec3(0.0, 0.02, 0.05) * (isEyeInWater == 1 ? vec3(0.5, 2.0, 0.5) : vec3(0.01)))
#define WATER_DENSITY 1.0

vec3 waterExtinction = clamp01(WATER_ABSORPTION + WATER_SCATTERING);

vec3 waterFog(vec3 color, vec3 a, vec3 b, float dhFactor){
  if(dhFactor > 0.0){
    vec3 sunTransmittance = exp(-waterExtinction * WATER_DENSITY * dhFactor);
    color.rgb *= sunTransmittance;
  }

  vec3 opticalDepth = waterExtinction * WATER_DENSITY * distance(a, b);
  vec3 transmittance = exp(-opticalDepth);


  vec3 scatter = (sunVisibilitySmooth * luminance(sunlightColor) * henyeyGreenstein(0.7, dot(normalize(b - a), lightDir)) + (EBS.y * 0.8 + 0.2) * skylightColor);
  scatter *= (1.0 - transmittance) * (WATER_SCATTERING / waterExtinction);
  

  return color * transmittance + scatter;
}

vec3 waterFog(vec3 color, vec3 a, vec3 b){
  return waterFog(color, a, b, 0.0);
}

#endif