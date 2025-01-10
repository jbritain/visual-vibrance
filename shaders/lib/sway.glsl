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

#ifndef SWAY_GLSL
#define SWAY_GLSL

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

vec3 fullSway(vec3 pos){ // leaves, mainly
  return pos + getWave(pos);
}

vec3 plantSway(vec3 pos, vec3 midblock){
    float waveMult = (1.0 - step(0, midblock.y));

    return pos + getWave(pos) * waveMult;
}

vec3 getSway(int materialID, vec3 pos, vec3 midblock){
    switch(materialID){
        case MATERIAL_PLANTS:
            return plantSway(pos, midblock);
        case MATERIAL_LEAVES:
            return fullSway(pos);
        case MATERIAL_TALL_PLANT_LOWER:
            return lowerSway(pos, midblock);
        case MATERIAL_TALL_PLANT_UPPER:
            return upperSway(pos, midblock);
        default:
            return pos;
    }
}

#endif // SWAY_GLSL