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

#ifndef PARALLAX_GLSL
#define PARALLAX_GLSL


float getDepth(vec2 texcoord, vec2 dx, vec2 dy){
  return (1.0 - textureGrad(normals, texcoord, dx, dy).a);
}

vec2 localToAtlas(vec2 texcoord){
  // vec2 localCoord = 1.0 - abs(mod(texcoord, 2.0) - 1.0); // mirror the texture coordinate if it goes out of bounds instead of wrapping it
  vec2 localCoord = mod(texcoord, 1.0); // wrap texture coordinate

  return localCoord * singleTexSize + textureBounds.xy;
}

vec2 atlasToLocal(vec2 texcoord){
  return (texcoord - textureBounds.xy) / singleTexSize;
}

vec2 getParallaxTexcoord(vec2 texcoord, vec3 viewPos, mat3 tbnMatrix, out vec3 previousPos, vec2 dx, vec2 dy, float jitter){
  vec3 viewDir = normalize(-viewPos) * tbnMatrix;

  float currentDepth = getDepth(texcoord, dx, dy);

  const float layerDepth = rcp(POM_SAMPLES); // depth per layer

  vec3 rayStep = vec3(viewDir.xy * rcp(-viewDir.z) * POM_HEIGHT, 1.0) * layerDepth;
  vec3 pos = vec3(atlasToLocal(texcoord), 0.0);

  float depth = getDepth(texcoord, dx, dy);
  if(depth < rcp(255.0)){
    previousPos = pos;
    return texcoord;
  }

  // pos += rayStep * jitter;

  depth = getDepth(localToAtlas(pos.xy), dx, dy);

  while(depth - pos.z > rcp(255.0)){
    previousPos = pos;
    depth = getDepth(localToAtlas(pos.xy), dx, dy);
    pos += rayStep;
  }

  depth = getDepth(localToAtlas(pos.xy), dx, dy);
  // binary refinement
  for(int i = 0; i < 6; i++){
    rayStep /= 2.0;

    pos += rayStep * float(depth - pos.z > rcp(255.0));
    depth = getDepth(localToAtlas(pos.xy), dx, dy);

    if (depth - pos.z > rcp(255.0)){
      previousPos = pos;
    }
  }

  return localToAtlas(previousPos.xy);
}

bool getParallaxShadow(vec3 pos, mat3 tbnMatrix, vec2 dx, vec2 dy, float jitter){
  float NoL = clamp01(dot(normalize(shadowLightPosition), tbnMatrix[2]));
  if(NoL < 0.01){
    return false;
  }

  vec3 lightDir = normalize(shadowLightPosition) * tbnMatrix;
  vec3 rayStep = vec3(lightDir.xy * rcp(lightDir.z) * POM_HEIGHT, -1.0) * pos.z * rcp(PARALLAX_SHADOW_SAMPLES);

  if(getDepth(localToAtlas(pos.xy), dx, dy) < pos.z) return true;

  pos += rayStep * jitter;

  for(int i = 0; i < PARALLAX_SHADOW_SAMPLES; i++){
    if(getDepth(localToAtlas(pos.xy), dx, dy) < pos.z) return true;
    pos += rayStep;
  }

  return false;
}

#endif