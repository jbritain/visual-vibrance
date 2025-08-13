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

#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/shadowSpace.glsl"
#include "/lib/atmosphere/clouds.glsl"

vec3 sampleShadow(vec3 shadowScreenPos) {
  return vec3(texture(shadowtex1HW, shadowScreenPos).r);
}

vec3 getShadowing(
  vec3 feetPlayerPos,
  vec3 faceNormal,
  vec2 lightmap,
  Material material,
  out float scatter
) {
  #ifdef PIXEL_LOCKED_LIGHTING
  feetPlayerPos += cameraPosition;
  feetPlayerPos = floor(feetPlayerPos * PIXEL_SIZE) / PIXEL_SIZE;
  feetPlayerPos -= cameraPosition;
  #endif

  scatter = 0.0;
  if (EBS.y == 0.0 && lightmap.y < 0.1 && constantMood > 0.2) {
    return vec3(0.0);
  }

  vec3 cloudShadow = vec3(1.0);

  #ifdef CLOUD_SHADOWS
  cloudShadow = getCloudShadow(feetPlayerPos);
  #endif

  #ifdef WORLD_THE_NETHER
  return vec3(0.0);
  #endif

  float fakeShadow = clamp01(smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y));

  float faceNoL = dot(faceNormal, lightDir);
  float sampleRadius = SHADOW_SOFTNESS * 0.003;

  if (faceNoL <= 1e-6 && material.sss > 1e-6) {
    scatter = material.sss;
    sampleRadius *= 1.0 + 16.0 * material.sss;

    float VoL = dot(normalize(feetPlayerPos), worldSunDir);
    float phase1 = henyeyGreenstein(0.4, VoL) * 0.75;
    float phase2 = henyeyGreenstein(0.1, VoL) * 0.5;
    // float phase3 = henyeyGreenstein(0.6, VoL);

    scatter *= max(phase1, phase2);
  }

  #ifndef SHADOWS
  return vec3(fakeShadow) * cloudShadow;
  #else

  vec4 shadowClipPos = getShadowClipPos(feetPlayerPos);

  vec3 bias = getShadowBias(
    shadowClipPos.xyz,
    mat3(gbufferModelViewInverse) * faceNormal,
    faceNoL
  );
  shadowClipPos.xyz += bias;

  vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

  float distFade = pow5(
    max(
      clamp01(maxVec2(abs(shadowClipPos.xy))),
      mix(1.0, 0.55, smoothstep(0.33, 0.8, worldLightDir.y)) *
        (dot(feetPlayerPos.xz, feetPlayerPos.xz) * rcp(pow2(shadowDistance)))
    )
  );

  vec3 shadow = vec3(0.0);

  if (distFade < 1.0) {
    float noise = interleavedGradientNoise(
      floor(gl_FragCoord.xy),
      frameCounter
    );
    // scatter falloff
    float scatterSampleAngle = noise * 2 * PI;
    vec2 scatterSampleOffset =
      vec2(sin(scatterSampleAngle), cos(scatterSampleAngle)) *
      (sampleRadius / SHADOW_SAMPLES);
    float blockerDepthDifference = max0(
      shadowScreenPos.z -
        texture(shadowtex0, shadowScreenPos.xy + scatterSampleOffset).r
    );
    float blockerDistance = blockerDepthDifference * 512;

    scatter *= mix(1.0 - smoothstep(blockerDistance, 0.0, 2.0), 1.0, distFade);

    if (faceNoL > 1e-6) {
      for (int i = 0; i < SHADOW_SAMPLES; i++) {
        vec3 offset =
          vec3(vogelDiscSample(i, SHADOW_SAMPLES, noise), 0.0) * sampleRadius;
        shadow += sampleShadow(shadowScreenPos + offset);
      }

      shadow /= float(SHADOW_SAMPLES);

      shadow = step(vec3(0.5), shadow);

      #ifdef CAUSTICS
      bool isWater =
        texture(shadowcolor0, shadowScreenPos.xy).r > 0.5 &&
        texture(shadowtex0HW, shadowScreenPos) < 0.5;

      if (isWater) {
        const ivec2 causticsSize = textureSize(causticsTex, 0);
        const int slices = causticsSize.y / causticsSize.x;

        vec3 worldPos = feetPlayerPos + cameraPosition;

        vec3 worldNormal = mat3(gbufferModelViewInverse) * faceNormal;

        // we want to find the two smallest components of the normal and use those to align the texture
        // i.e if normal.y is biggest we use the xz of the position
        vec3 faceMask =
          1.0 - vec3(equal(worldNormal, vec3(maxVec3(abs(worldNormal))))); // sets the largest component to 0.0 and the other two to 1.0

        vec2 causticsPos =
          faceMask.y == 0.0
            ? worldPos.xz
            : faceMask.x == 0.0
              ? worldPos.yz
              : worldPos.xy;

        causticsPos = fract(causticsPos / 2.0);

        causticsPos.y /= float(slices);
        causticsPos.y += fract(
          rcp(float(slices)) * floor(frameTimeCounter * 20.0)
        );

        shadow *=
          texelFetch(causticsTex, ivec2(causticsPos * causticsSize), 0).r * 3.0;
      }
      #endif
    }

  }

  scatter *= maxVec3(cloudShadow); // since the cloud shadows are so blurry anyway, if something is shadowed by a cloud, it's probably not getting any sunlight
  shadow = mix(shadow, vec3(fakeShadow), clamp01(distFade));
  return shadow * cloudShadow;

  #endif
}

#endif // SHADOWS_GLSL
