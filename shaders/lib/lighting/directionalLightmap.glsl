#ifndef DIRECTIONAL_LIGHTMAP_GLSL
#define DIRECTIONAL_LIGHTMAP_GLSL

void applyDirectionalLightmap(inout vec2 lightmap, vec3 viewPos, vec3 mappedNormal, mat3 tbnMatrix, float sss){
  vec3 dFdViewposX = dFdx(viewPos);
  vec3 dFdViewposY = dFdy(viewPos);

  vec2 dFdTorch = vec2(dFdx(lightmap.x), dFdy(lightmap.x));
  vec2 dFdSky = vec2(dFdx(lightmap.y), dFdy(lightmap.y));

  vec3 torchDir = (length(dFdTorch) > 1e-6) ? normalize(dFdViewposX * dFdTorch.x + dFdViewposY * dFdTorch.y) : -tbnMatrix[2];
  vec3 skyDir = (length(dFdSky) > 1e-6) ? normalize(dFdViewposX * dFdSky.x + dFdViewposY * dFdSky.y) : - gbufferModelViewInverse[1].xyz;

  float torchFactor;

  if(length(dFdTorch) > 1e-6){
    float NoL = dot(torchDir, mappedNormal);
    float NGoL = dot(torchDir, tbnMatrix[2]);

    lightmap.x += clamp01((NoL - NGoL) * lightmap.x * (1.0 - sss * 0.5)) * 0.25;
  } else {
    float NoL = 0.9 - dot(tbnMatrix[2], mappedNormal);
    lightmap.x -= clamp01(NoL * lightmap.x * (1.0 - sss * 0.5)) * 0.25;
  }

  float skyFactor;

  if(length(dFdSky) > 1e-6){
    float NoL = dot(skyDir, mappedNormal);
    float NGoL = dot(skyDir, tbnMatrix[2]);

    lightmap.y += clamp01((NoL - NGoL) * lightmap.y * (1.0 - sss * 0.5));
  } else {
    float NoL = 0.9 - dot(tbnMatrix[2], mappedNormal);
    lightmap.y -= clamp01(NoL * lightmap.y * (1.0 - sss * 0.5));
  }


  lightmap = clamp01(lightmap);

}

#endif