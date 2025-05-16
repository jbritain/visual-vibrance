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

#ifndef SWAY_GLSL
#define SWAY_GLSL

#include "/lib/water/waveNormals.glsl"

vec3 getWave(vec3 pos){
  float t = (frameTimeCounter + weatherFrameTimeCounter) * 0.3;

  float magnitude = (sin(((pos.y + pos.x) * 0.5 + t * PI / ((88.0)))) * 0.05 + 0.15) * 0.35;

  float d0 = sin(t * 20.0 * PI / 112.0 * 3.0 - 1.5);
  float d1 = sin(t * 20.0 * PI / 152.0 * 3.0 - 1.5);
  float d2 = sin(t * 20.0 * PI / 192.0 * 3.0 - 1.5);
  float d3 = sin(t * 20.0 * PI / 142.0 * 3.0 - 1.5);

  vec3 wave = vec3(0.0);
  wave.x += (sin((t * 20.0 * PI / 16.0) + (pos.x + d0) * 0.5 + (pos.z + d1) * 0.5 + pos.y)) * magnitude;
  wave.z += (sin((t * 20.0 * PI / 18.0) + (pos.z + d2) * 0.5 + (pos.x + d3) * 0.5 + pos.y)) * magnitude;
  wave.y += (sin((t * 20.0 * PI / 10.0) + (pos.z + d2)       + (pos.x + d3)       + pos.y)) * magnitude * 0.5;

  return wave;
}

vec3 upperSway(vec3 pos, vec3 midblock){ // top halves of double high plants
float waveMult = (1.0 - step(0, midblock.y)) * 0.5 + 0.5;
  return pos + getWave(pos) * waveMult;
}

vec3 lowerSway(vec3 pos, vec3 midblock){ // bottom halves of double high plants
  float waveMult = (1.0 - step(0, midblock.y)) * 0.5;

  return pos + getWave(pos) * waveMult;
}

vec3 hangingSway(vec3 pos, vec3 midblock){ // stuff hanging from a block
  float waveMult = smoothstep(-32.0, 32.0, midblock.y);
  return pos + getWave(pos + midblock / 64) * waveMult;
}

vec3 floatingSway(vec3 pos){ // stuff on the water
  return pos;
  return pos + vec3(0.0, waveHeight(pos.xz) - 0.5, 0.0);
}

vec3 fullSway(vec3 pos){ // leaves, mainly
  return pos + getWave(pos);
}

vec3 getSway(int materialID, vec3 pos, vec3 midblock){
  switch(materialSwayType(materialID).value){
    case 1:
      return upperSway(pos, midblock);
    case 2:
      return lowerSway(pos, midblock);
    case 3:
      return hangingSway(pos, midblock);
    case 4:
      return floatingSway(pos);
    case 5:
      return fullSway(pos);
    default:
      return pos;
  }
}

#endif // SWAY_GLSL