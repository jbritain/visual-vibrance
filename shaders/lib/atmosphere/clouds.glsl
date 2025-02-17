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

#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL

#define CLOUD_PLANE_ALTITUDE 1000
#define CLOUD_PLANE_HEIGHT 50
#define CLOUD_EXTINCTION_COLOR vec3(1.0)

float remap(float val, float oMin, float oMax, float nMin, float nMax){
  return mix(nMin, nMax, smoothstep(oMin, oMax, val));
}

vec3 multipleScattering(float density, float costh, float g1, float g2, vec3 extinction, int octaves, float lobeWeight, float attenuation, float contribution, float phaseAttenuation){
  vec3 radiance = vec3(0.0);

  // float attenuation = 0.9;
  // float contribution = 0.5;
  // float phaseAttenuation = 0.7;

  float a = 1.0;
  float b = 1.0;
  float c = 1.0;

  for(int n = 0; n < octaves; n++){
    float phase = dualHenyeyGreenstein(g1 * c, g2 * c, costh, lobeWeight);
    radiance += b * phase * exp(-density * extinction * a);

    a *= attenuation;
    b *= contribution;
    c *= (1.0 - phaseAttenuation);
  }

  return radiance;
}

float getCloudDensity(vec2 pos){
  float density = 0.0;
  float weight = 0.0;

  pos = pos / 100000;

  pos.y += worldTimeCounter * 0.0002;

  for(int i = 0; i < 16; i++){
    float sampleWeight = exp2(-float(i));
    vec2 samplePos = pos * exp2(float(i));
    density += texture(perlinNoiseTex, fract(samplePos)).r * sampleWeight;
    weight += sampleWeight;
  }

  density /= weight;
  density = smoothstep(0.5 - 0.15 * wetness - 0.2 * thunderStrength, 1.0, density);
  // density = sqrt(density);
  density *= 0.2;

  return density;
}

vec3 getClouds(vec3 origin, vec3 worldDir, out vec3 transmittance){
  transmittance = vec3(1.0);
  #ifndef CLOUDS
  return vec3(0.0);
  #endif

  origin += cameraPosition;

  vec3 point;
  if(!rayPlaneIntersection(origin, worldDir, CLOUD_PLANE_ALTITUDE, point)) return vec3(0.0);

  float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  vec3 exitPoint; // where the view ray exits the cloud plane
  rayPlaneIntersection(origin, worldDir, CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT, exitPoint);
  float totalDensityAlongRay = getCloudDensity(point.xz) * distance(point, exitPoint);
  vec3 sunExitPoint;
  rayPlaneIntersection(point, worldLightDir, CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT, sunExitPoint);
  float totalDensityTowardsSun = getCloudDensity(mix(point.xz, sunExitPoint.xz, jitter)) * distance(point, sunExitPoint);
  float costh = dot(worldDir, worldLightDir);

  vec3 powder = clamp01((1.0 - exp(-totalDensityTowardsSun * 2 * CLOUD_EXTINCTION_COLOR)));

  vec3 radiance = skylightColor + sunlightColor * (1.0 + 9.0 * float(lightDir == sunDir)) * multipleScattering(totalDensityTowardsSun, costh, 0.9, -0.4, CLOUD_EXTINCTION_COLOR, 4, 0.85, 0.9, 0.8, 0.1) * mix(2.0 * powder, vec3(1.0), costh * 0.5 + 0.5);


  transmittance = exp(-totalDensityAlongRay * CLOUD_EXTINCTION_COLOR);
  transmittance = mix(transmittance, vec3(1.0), 1.0 - smoothstep(0.0, 0.2, worldDir.y)); // fade clouds towards horizon

  vec3 integScatter = (radiance - radiance * clamp01(transmittance)) / CLOUD_EXTINCTION_COLOR;
  vec3 scatter = integScatter * transmittance;
  scatter = mix(scatter, vec3(0.0), exp(-distance(point, cameraPosition) * 0.004));

  return scatter;
}

#endif