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

#ifndef PARALLAX_GLSL
#define PARALLAX_GLSL

vec2 localToAtlas(vec2 texcoord) {
  // vec2 localCoord = 1.0 - abs(mod(texcoord, 2.0) - 1.0); // mirror the texture coordinate if it goes out of bounds instead of wrapping it
  vec2 localCoord = mod(texcoord, 1.0); // wrap texture coordinate

  return localCoord * singleTexSize + textureBounds.xy;
}

vec2 atlasToLocal(vec2 texcoord) {
  return (texcoord - textureBounds.xy) / singleTexSize;
}

vec4 bilinearSample(sampler2D tex, vec2 texcoord, vec2 dx, vec2 dy) {
  vec2 localCoord = atlasToLocal(texcoord);

  vec2 f = fract(localCoord * singleTexSize - 0.5);

  vec2 invRes = rcp(atlasSize);
  vec4 tl = textureGrad(tex, texcoord, dx, dy);
  vec4 tr = textureGrad(
    tex,
    localToAtlas(localCoord + vec2(invRes.x, 0.0)),
    dx,
    dy
  );
  vec4 bl = textureGrad(
    tex,
    localToAtlas(localCoord + vec2(0.0, invRes.y)),
    dx,
    dy
  );
  vec4 br = textureGrad(tex, localToAtlas(localCoord + invRes), dx, dy);

  vec4 top = mix(tl, tr, f.x);
  vec4 bottom = mix(bl, br, f.x);

  return mix(top, bottom, f.y);
}

float getDepth(vec2 texcoord, vec2 dx, vec2 dy) {
  #ifdef SMOOTH_PARALLAX
  return 1.0 - bilinearSample(normals, texcoord, dx, dy).a;
  #else
  return 1.0 - textureGrad(normals, texcoord, dx, dy).a;
  #endif
}

vec2 getParallaxTexcoord(
  vec2 texcoord,
  vec3 viewPos,
  mat3 tbnMatrix,
  out vec3 previousPos,
  vec2 dx,
  vec2 dy,
  float jitter
) {
  float distFade = smoothstep(
    PARALLAX_DISTANCE * PARALLAX_DISTANCE_CURVE,
    PARALLAX_DISTANCE,
    length(viewPos)
  );

  if (distFade >= 1.0) {
    previousPos = vec3(-1.0);
    return texcoord;
  }

  vec3 viewDir = normalize(-viewPos) * tbnMatrix;

  float currentDepth = getDepth(texcoord, dx, dy);

  const float layerDepth = rcp(PARALLAX_SAMPLES * (1.0 - distFade)); // depth per layer

  vec3 rayStep =
    vec3(
      viewDir.xy * rcp(-viewDir.z) * PARALLAX_HEIGHT * (1.0 - distFade),
      1.0
    ) *
    layerDepth;
  vec3 pos = vec3(atlasToLocal(texcoord), 0.0);

  float depth = getDepth(texcoord, dx, dy);
  if (depth < rcp(255.0)) {
    previousPos = pos;
    return texcoord;
  }

  depth = getDepth(localToAtlas(pos.xy), dx, dy);

  while (depth - pos.z > rcp(255.0)) {
    previousPos = pos;
    depth = getDepth(localToAtlas(pos.xy), dx, dy);
    pos += rayStep;
  }

  pos = previousPos;
  depth = getDepth(localToAtlas(pos.xy), dx, dy);
  // binary refinement
  for (int i = 0; i < 6; i++) {
    rayStep /= 2.0;

    pos += rayStep * (depth - pos.z > rcp(255.0) ? 1.0 : -1.0);
    depth = getDepth(localToAtlas(pos.xy), dx, dy);

    if (depth - pos.z > rcp(255.0)) {
      previousPos = pos;
    }
  }

  return localToAtlas(previousPos.xy);
}

float getParallaxShadow(
  vec3 pos,
  mat3 tbnMatrix,
  vec2 dx,
  vec2 dy,
  float jitter,
  vec3 viewPos
) {
  float distFade = smoothstep(
    PARALLAX_DISTANCE * PARALLAX_DISTANCE_CURVE,
    PARALLAX_DISTANCE,
    length(viewPos)
  );

  if (distFade >= 1.0) {
    return 1.0;
  }

  float NoL = clamp01(dot(normalize(shadowLightPosition), tbnMatrix[2]));
  if (NoL < 0.01) {
    return 0.0;
  }

  vec3 lightDir = normalize(shadowLightPosition) * tbnMatrix;
  vec3 rayStep =
    vec3(lightDir.xy * rcp(lightDir.z) * PARALLAX_HEIGHT, -1.0) *
    pos.z *
    rcp(PARALLAX_SHADOW_SAMPLES * (1.0 - distFade));

  if (getDepth(localToAtlas(pos.xy), dx, dy) < pos.z) return distFade;

  pos += rayStep * jitter;

  for (int i = 0; i < PARALLAX_SHADOW_SAMPLES; i++) {
    if (getDepth(localToAtlas(pos.xy), dx, dy) < pos.z) return distFade;
    pos += rayStep;
  }

  return 1.0;
}

#endif
