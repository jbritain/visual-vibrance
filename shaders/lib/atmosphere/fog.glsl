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

#ifndef FOG_GLSL
#define FOG_GLSL

#include "/lib/atmosphere/clouds.glsl"

vec3 atmosphericFog(vec3 color, vec3 viewPos) {
  #ifdef DISTANT_HORIZONS
  float end = dhRenderDistance;
  #else
  float end = far;
  #endif
  return mix(
    color,
    getSky(mat3(gbufferModelViewInverse) * normalize(viewPos), false),
    clamp01(exp(-(10.0 - VANILLA_FOG_DENSITY) * (1.0 - length(viewPos) / end)))
  );
}

#define FOG_DENSITY (0.01)
// above this height there is no fog
#define HEIGHT_FOG_TOP_HEIGHT mix(150, CLOUD_PLANE_ALTITUDE, wetness)
// below this height there is a constant fog density
#define HEIGHT_FOG_MIDDLE_HEIGHT (30)
#define HEIGHT_FOG_BOTTOM_HEIGHT (0)

float getFogDensity(float height) {
  if (height > HEIGHT_FOG_MIDDLE_HEIGHT) {
    return (1.0 -
      smoothstep(HEIGHT_FOG_MIDDLE_HEIGHT, HEIGHT_FOG_TOP_HEIGHT, height)) *
    FOG_DENSITY;
  } else {
    return FOG_DENSITY;
  }

}

vec3 cloudyFog(vec3 color, vec3 playerPos, float depth, vec3 scatterFactor) {
  // we want fog to occur between time = 15000 and time = 1000
  float fogFactor = 0.0;
  if (worldTime > 1000) {
    fogFactor = smoothstep(15000, 24000, worldTime) * MORNING_FOG_DENSITY;
  } else {
    fogFactor = (1.0 - smoothstep(0, 1000, worldTime)) * MORNING_FOG_DENSITY;
  }

  fogFactor += wetness * 0.2;
  fogFactor += thunderStrength;

  fogFactor += BASE_FOG_DENSITY;

  if (fogFactor < 1e-6) {
    return color;
  }

  float localTopHeight = HEIGHT_FOG_TOP_HEIGHT - cameraPosition.y;
  float localMiddleHeight = HEIGHT_FOG_MIDDLE_HEIGHT - cameraPosition.y;
  float localBottomHeight = HEIGHT_FOG_BOTTOM_HEIGHT - cameraPosition.y;

  vec3 dir = normalize(playerPos);

  // check if not looking at the fog at all
  if (cameraPosition.y > HEIGHT_FOG_TOP_HEIGHT && dir.y > 0) {
    return color;
  }

  float opticalDepth;

  // top part
  vec3 a = vec3(0.0);
  vec3 b = vec3(0.0);

  if (!rayPlaneIntersection(vec3(0.0), dir, localMiddleHeight, a)) {
    a = vec3(0.0);
  }
  if (!rayPlaneIntersection(vec3(0.0), dir, localTopHeight, b)) {
    b = vec3(0.0);
  }

  if (length(a) > length(b)) {
    // for convenience, a will always be closer to the camera
    vec3 swap = a;
    a = b;
    b = swap;
  }

  if (length(playerPos) < length(a)) {
    a = vec3(0.0);
    b = vec3(0.0);
  } else if (length(playerPos) < length(b)) {
    // terrain in the way
    b = playerPos;
  }

  float densityA = getFogDensity(a.y + cameraPosition.y);
  float densityB = getFogDensity(b.y + cameraPosition.y);

  opticalDepth = max0(distance(a, b) * (densityA + densityB) / 2) * fogFactor;

  if (!rayPlaneIntersection(vec3(0.0), dir, localBottomHeight, a)) {
    a = vec3(0.0);
  }
  if (!rayPlaneIntersection(vec3(0.0), dir, localMiddleHeight, b)) {
    b = vec3(0.0);
  }

  if (length(a) > length(b)) {
    // for convenience, a will always be closer to the camera
    vec3 swap = a;
    a = b;
    b = swap;
  }

  if (length(playerPos) < length(a)) {
    a = vec3(0.0);
    b = vec3(0.0);
  } else if (length(playerPos) < length(b)) {
    // terrain in the way
    b = playerPos;
  }

  opticalDepth += distance(a, b) * FOG_DENSITY * fogFactor;

  // opticalDepth *= (1.0 - smoothstep(far * 4.0, far * 8.0, length(playerPos)));

  float transmittance = exp(-opticalDepth);

  float costh = dot(normalize(playerPos), worldLightDir);

  vec3 phase = vec3(dualHenyeyGreenstein(-0.5, 0.8, costh, 0.5));

  vec3 radiance = sunlightColor * scatterFactor * phase + skylightColor * EBS.y;

  vec3 scatter = vec3(1.0 - transmittance) / 2; // / max(opticalDepth, 1e-6);
  scatter *= radiance;
  scatter *= skyMultiplier;

  return color * transmittance + scatter;
}

vec3 defaultFog(vec3 color, vec3 viewPos) {
  #ifdef WORLD_OVERWORLD
  if (isEyeInWater < 2) {
    return color;
  }
  #endif

  #ifdef WORLD_THE_END
  return color;
  #endif

  float end = far; // the render distance is the default

  switch (isEyeInWater) {
    case 2:
      end = 3;
      break;
    case 3:
      end = 2;
      break;
  }

  color.rgb = mix(
    color.rgb,
    pow(fogColor, vec3(2.2)),
    clamp01(length(viewPos) / end)
  );

  return color;
}

#endif
