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

#ifndef BLOOM_GLSL
#define BLOOM_GLSL

// implemented following https://learnopengl.com/Guest-Articles/2022/Phys.-Based-Bloom
// which is in turn an implementation of Sledgehammer Games' bloom used for COD Advanced Warfare

vec3 powVec3(vec3 v, float p)
{
    return vec3(pow(v.x, p), pow(v.y, p), pow(v.z, p));
}

vec3 toSRGB(vec3 v) { return powVec3(v, 1.0/2.2); }

float RGBToLuminance(vec3 col)
{
    return dot(col, vec3(0.2126f, 0.7152f, 0.0722f));
}

float karisAverage(vec3 col)
{
    // Formula is 1 / (1 + luma)
    float luma = RGBToLuminance(toSRGB(col)) * 0.25f;
    return 1.0f / (1.0f + luma);
}

struct BloomTile {
  vec2 origin;
  int mipLevel;
  float scale;
};

BloomTile tileA = BloomTile(vec2(0.0), 1, 0.5); // 1/2 scale
BloomTile tileB = BloomTile(vec2(0.5 + 2/(viewWidth * BLOOM_QUALITY), 0.0), 2, 0.25); // 1/4 scale
BloomTile tileC = BloomTile(vec2(0.75 + 4/(viewWidth * BLOOM_QUALITY), 0.0), 3, 0.125); // 1/8 scale
BloomTile tileD = BloomTile(vec2(0.875 + 6/(viewWidth * BLOOM_QUALITY), 0.0), 4, 0.0625); // 1/16 scale
BloomTile tileE = BloomTile(vec2(0.9375 + 8/(viewWidth * BLOOM_QUALITY), 0.0), 5, 0.03125); // 1/32 scale

BloomTile tiles[5] = BloomTile[5](tileA, tileB, tileC, tileD, tileE);

vec3 downSample(sampler2D sourceTexture, vec2 coord, bool doKarisAverage){
    // a - b - c
    // - j - k -
    // d - e - f
    // - l - m -
    // g - h - i

  float x = 1.0 / float(viewWidth * BLOOM_QUALITY);
  float y = 1.0 / float(viewHeight * BLOOM_QUALITY);

  vec3 a = texture(sourceTexture, vec2(coord.x - 2*x, coord.y + 2*y)).rgb;
  vec3 b = texture(sourceTexture, vec2(coord.x,       coord.y + 2*y)).rgb;
  vec3 c = texture(sourceTexture, vec2(coord.x + 2*x, coord.y + 2*y)).rgb;
  vec3 d = texture(sourceTexture, vec2(coord.x - 2*x, coord.y)).rgb;
  vec3 e = texture(sourceTexture, vec2(coord.x,       coord.y)).rgb;
  vec3 f = texture(sourceTexture, vec2(coord.x + 2*x, coord.y)).rgb;
  vec3 g = texture(sourceTexture, vec2(coord.x - 2*x, coord.y - 2*y)).rgb;
  vec3 h = texture(sourceTexture, vec2(coord.x,       coord.y - 2*y)).rgb;
  vec3 i = texture(sourceTexture, vec2(coord.x + 2*x, coord.y - 2*y)).rgb;
  vec3 j = texture(sourceTexture, vec2(coord.x - x, coord.y + y)).rgb;
  vec3 k = texture(sourceTexture, vec2(coord.x + x, coord.y + y)).rgb;
  vec3 l = texture(sourceTexture, vec2(coord.x - x, coord.y - y)).rgb;
  vec3 m = texture(sourceTexture, vec2(coord.x + x, coord.y - y)).rgb;

  vec3 dsample;
  if(doKarisAverage){
    vec3 group0 = (a+b+d+e) * (0.124/4.0);
    vec3 group1 = (b+c+e+f) * (0.124/4.0);
    vec3 group2 = (d+e+g+h) * (0.125/4.0);
    vec3 group3 = (e+f+h+i) * (0.125/4.0);
    vec3 group4 = (j+k+l+m) * (0.5/4.0);

    group0 *= karisAverage(group0);
    group1 *= karisAverage(group1);
    group2 *= karisAverage(group2);
    group3 *= karisAverage(group3);
    group4 *= karisAverage(group4);
    dsample = group0 + group1 + group2 + group3 + group4;
  } else {
    dsample = e * 0.125;
    dsample += (a+c+g+i) * 0.03125;
    dsample += (b+d+f+h) * 0.0625;
    dsample += (j+k+l+m) * 0.125;
  }

  dsample = max(dsample, 0.0001);

  return dsample;
}

vec3 upSample(sampler2D sourceTexture, vec2 coord){
    //  1   | 1 2 1 |
    // -- * | 2 4 2 |
    // 16   | 1 2 1 |

  float x = BLOOM_RADIUS / (viewWidth * BLOOM_QUALITY);
  float y = BLOOM_RADIUS / (viewHeight * BLOOM_QUALITY);

  vec3 a = texture(sourceTexture, vec2(coord.x - x, coord.y + y)).rgb;
  vec3 b = texture(sourceTexture, vec2(coord.x,     coord.y + y)).rgb;
  vec3 c = texture(sourceTexture, vec2(coord.x + x, coord.y + y)).rgb;

  vec3 d = texture(sourceTexture, vec2(coord.x - x, coord.y)).rgb;
  vec3 e = texture(sourceTexture, vec2(coord.x,     coord.y)).rgb;
  vec3 f = texture(sourceTexture, vec2(coord.x + x, coord.y)).rgb;

  vec3 g = texture(sourceTexture, vec2(coord.x - x, coord.y - y)).rgb;
  vec3 h = texture(sourceTexture, vec2(coord.x,     coord.y - y)).rgb;
  vec3 i = texture(sourceTexture, vec2(coord.x + x, coord.y - y)).rgb;

  vec3 usample = e*4.0;
  usample += (b + d + f + h) * 2.0;
  usample += (a + c + g + i);
  usample /= 16.0;

  usample = max(usample, 0.0001);

  return usample;
}

// takes a texcoord within a bloom tile and scales it up to spread across the whole screen
vec2 scaleToBloomTile(vec2 coord, BloomTile tile){
  return (coord - tile.origin) / tile.scale;
}

// takes a full screen texcoord and scales it down to map to a bloom tile
vec2 scaleFromBloomTile(vec2 coord, BloomTile tile){
  return coord * tile.scale + tile.origin;
}

#endif // BLOOM_GLSL