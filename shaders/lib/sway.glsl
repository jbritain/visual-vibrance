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
  float magnitude = 0.1;

  float d0 = sin(frameTimeCounter);
  float d1 = sin(frameTimeCounter * 0.5);
  float d2 = sin(frameTimeCounter * 0.25);

  vec3 wave;
  wave.x = sin(0.2 + d0 + d1 - pos.x + pos.y + pos.z) * magnitude;
  wave.y = sin(0.05 + d1 + d2 + pos.x - pos.y + pos.z) * magnitude * 0.2;
  wave.z = sin(0.4 + d2 + d0 + pos.x + pos.y - pos.z) * magnitude;

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