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

#define CLOUD_PLANE_ALTITUDE 192 // [64 96 128 160 192]
#define CLOUD_PLANE_HEIGHT 4 // [1 2 3 4 5 6 7 8]
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
  ivec2 p = ivec2(floor(mod((pos + vec2(frameTimeCounter, 0.0)) / 24, 256)));

  return texelFetch(vanillaCloudTex, p, 0).r;
}

vec3 getCloudShadow(vec3 origin){
  origin += cameraPosition;

  vec3 point;
  if(!rayPlaneIntersection(origin, worldLightDir, CLOUD_PLANE_ALTITUDE, point)) return vec3(1.0);
  vec3 exitPoint;
  rayPlaneIntersection(origin, worldLightDir, CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT, exitPoint);
  float totalDensityAlongRay = getCloudDensity(point.xz) * distance(point, exitPoint);
  return clamp01(mix(exp(-totalDensityAlongRay * CLOUD_EXTINCTION_COLOR), vec3(1.0), (1.0 - smoothstep(0.1, 0.2, worldLightDir.y))));

}

vec3 getClouds(vec3 origin, vec3 feetPlayerPos, out vec3 transmittance, float depth){
  transmittance = vec3(1.0);
  #ifndef CLOUDS
  return vec3(0.0);
  #endif

  vec3 worldDir = normalize(feetPlayerPos);

  vec3 scatter = vec3(0.0);

  origin += cameraPosition;

  vec3 a;
  if(!rayPlaneIntersection(origin, worldDir, CLOUD_PLANE_ALTITUDE, a)){
    if (worldDir.y > 0.0){
      a = cameraPosition;
    } else {
      return vec3(0.0);
    }
  }

  vec3 b;
  if(!rayPlaneIntersection(origin, worldDir, CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT, b)){
    if(worldDir.y < 0.0){
      b = cameraPosition;
    } else {
      return vec3(0.0);
    }
  };

  // a -= cameraPosition;
  // b -= cameraPosition;

  // if(length(a) > length(b)){ // for convenience, a will always be closer to the camera
  //   vec3 swap = a;
  //   a = b;
  //   b = swap;
  // }

  // if(depth != 1.0 && length(b) > length(feetPlayerPos)){
  //   b = feetPlayerPos;
  // }
  
  // a += cameraPosition;
  // b += cameraPosition;

  float totalDensity = 0.0;

  vec3 rayPos = a;
  vec3 rayStep = (b - a) / 8;
  rayPos += rayStep * interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  for(int i = 0; i < 8; i++, rayPos += rayStep){
    totalDensity += getCloudDensity(rayPos.xz); // I should be multiplying by the ray step length but it looks fine anyway
  }

  scatter = vec3(mix(sunlightColor, skylightColor, 0.5) * 0.5 * step(0.01, totalDensity));

  float mixFactor = henyeyGreenstein(0.6, dot(worldDir, worldLightDir)) * 0.9 + 0.1;
  mixFactor *= 2.0;

  scatter *= mix(1.0, mixFactor, totalDensity / 7.0);
  transmittance = mix(transmittance, transmittance * 0.1, rainStrength * step(0.01, totalDensity));

  float fade = smoothstep(1000.0, 2000.0, length(a - cameraPosition));

  scatter = mix(scatter, vec3(0.0), fade);
  transmittance = mix(transmittance, vec3(1.0), fade);




  return scatter;
}

#endif