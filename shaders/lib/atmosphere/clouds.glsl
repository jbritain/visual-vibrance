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

#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL

#define CLOUD_EXTINCTION_COLOR (vec3(0.1 + wetness))

float remap(float val, float oMin, float oMax, float nMin, float nMax) {
  return mix(nMin, nMax, smoothstep(oMin, oMax, val));
}

vec3 multipleScattering(
  float density,
  float costh,
  float g1,
  float g2,
  vec3 extinction,
  int octaves,
  float lobeWeight,
  float attenuation,
  float contribution,
  float phaseAttenuation
) {
  vec3 radiance = vec3(0.0);

  // float attenuation = 0.9;
  // float contribution = 0.5;
  // float phaseAttenuation = 0.7;

  float a = 1.0;
  float b = 1.0;
  float c = 1.0;

  for (int n = 0; n < octaves; n++) {
    float phase = dualHenyeyGreenstein(g1 * c, g2 * c, costh, lobeWeight);
    radiance += b * phase * exp(-density * extinction * a);

    a *= attenuation;
    b *= contribution;
    c *= 1.0 - phaseAttenuation;
  }

  return radiance;
}

float getCloudDensity(vec2 pos) {
  ivec2 p = ivec2(floor(mod((pos + vec2(frameTimeCounter, 0.0)) / 24, 256)));

  return texelFetch(vanillaCloudTex, p, 0).r;
}

vec3 getCloudShadow(vec3 origin) {
  #ifndef WORLD_OVERWORLD
  return vec3(0.0);
  #endif

  origin += cameraPosition;

  vec3 point;
  if (!rayPlaneIntersection(origin, worldLightDir, CLOUD_PLANE_ALTITUDE, point))
    return vec3(1.0);
  vec3 exitPoint;
  rayPlaneIntersection(
    origin,
    worldLightDir,
    CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT,
    exitPoint
  );
  float totalDensityAlongRay =
    getCloudDensity(point.xz) * distance(point, exitPoint);
  return clamp01(
    mix(
      exp(-totalDensityAlongRay * CLOUD_EXTINCTION_COLOR),
      vec3(1.0),
      1.0 - smoothstep(0.1, 0.2, worldLightDir.y)
    )
  );
}

vec3 getClouds(
  vec3 origin,
  vec3 feetPlayerPos,
  out vec3 transmittance,
  float depth
) {
  transmittance = vec3(1.0);
  #ifndef CLOUDS
  return vec3(0.0);
  #endif

  vec3 worldDir = normalize(feetPlayerPos);

  vec3 scatter = vec3(0.0);

  origin += cameraPosition;

  vec3 a;
  if (!rayPlaneIntersection(origin, worldDir, CLOUD_PLANE_ALTITUDE, a)) {
    if (worldDir.y > 0.0) {
      a = cameraPosition;
    } else {
      return vec3(0.0);
    }
  }

  if (length(feetPlayerPos) < length(a - cameraPosition) && depth != 1.0) {
    return vec3(0.0);
  }

  vec3 b;
  if (
    !rayPlaneIntersection(
      origin,
      worldDir,
      CLOUD_PLANE_ALTITUDE + CLOUD_PLANE_HEIGHT,
      b
    )
  ) {
    if (worldDir.y < 0.0) {
      b = cameraPosition;
    } else {
      return vec3(0.0);
    }
  }
  ;

  a -= cameraPosition;
  b -= cameraPosition;

  if (length(a) > length(b)) {
    // for convenience, a will always be closer to the camera
    vec3 swap = a;
    a = b;
    b = swap;
  }

  if (depth != 1.0 && length(feetPlayerPos) < length(b)) {
    b = feetPlayerPos;
  }

  a += cameraPosition;
  b += cameraPosition;

  float totalDensity = 0.0;

  vec3 rayPos = a;
  vec3 rayStep = (b - a) / 8;
  rayPos +=
    rayStep * interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  for (int i = 0; i < 8; i++, rayPos += rayStep) {
    totalDensity += getCloudDensity(rayPos.xz); // I should be multiplying by the ray step length but it looks fine anyway
  }
  transmittance = vec3(
    exp(-totalDensity * length(rayStep) * CLOUD_EXTINCTION_COLOR)
  );

  vec3 radiance =
    sunlightColor *
      (1.0 - wetness * 0.5) *
      henyeyGreenstein(0.6, dot(worldDir, worldLightDir)) +
    skylightColor *
      (1.0 - wetness * 0.3) *
      vec3(0.5, 1.0, 2.0) *
      henyeyGreenstein(0.0, 0.0);

  scatter =
    (radiance - radiance * clamp01(transmittance)) / CLOUD_EXTINCTION_COLOR;

  scatter = mix(scatter * 5.0, scatter, smoothstep(6.0, 7.0, totalDensity));

  // scatter = vec3(
  //   mix(sunlightColor, skylightColor, 0.5) * 0.5 * step(0.01, totalDensity)
  // );

  // float mixFactor =
  //   (1.0 - rainStrength) *
  //     henyeyGreenstein(0.6, dot(worldDir, worldLightDir)) *
  //     0.9 +
  //   0.1;
  // mixFactor *= 2.0;

  // scatter *= mix(1.0, mixFactor, totalDensity / 7.0);

  float fade = smoothstep(1000.0, 2000.0, length(a - cameraPosition));

  scatter = mix(scatter, vec3(0.0), fade);
  transmittance = mix(transmittance, vec3(1.0), fade);

  return scatter;
}

#endif
