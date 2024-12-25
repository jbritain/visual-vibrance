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

#ifndef WATER_FOG_GLSL
#define WATER_FOG_GLSL

#define WATER_ABSORPTION vec3(0.3, 0.09, 0.04)
#define WATER_SCATTERING vec3(0.01, 0.06, 0.05)
#define WATER_DENSITY 1.0

const vec3 waterExtinction = clamp01(WATER_ABSORPTION + WATER_SCATTERING);

vec3 waterFog(vec3 color, vec3 a, vec3 b){
  vec3 transmittance = exp(-waterExtinction * WATER_DENSITY * distance(a, b));

  vec3 radiance = (weatherSunlightColor + weatherSkylightColor) * EB.y;
  vec3 integScatter = (radiance - radiance * clamp01(transmittance)) / waterExtinction;
  vec3 scatter = integScatter * transmittance;

  scatter *= getMiePhase(dot(normalize(b - a), lightDir));

  return color * transmittance;// + scatter;
  // color *= fog(vec3(0.0, cameraPosition.y, 0.0), mat3(gbufferModelViewInverse) * normalize(b - a), worldLightDir, distance(a, b));
  return color;
}

#endif