#ifndef WATER_FOG_GLSL
#define WATER_FOG_GLSL

#define WATER_ABSORPTION vec3(0.3, 0.09, 0.04)
#define WATER_SCATTERING vec3(0.01, 0.06, 0.05)
#define WATER_DENSITY 1.0

vec3 waterFog(vec3 color, vec3 a, vec3 b){
  vec3 transmittance = exp(-WATER_ABSORPTION * WATER_DENSITY * distance(a, b));

  vec3 radiance = sunlightColor + skylightColor;
  vec3 scatter = (radiance - radiance * clamp01(transmittance)) * transmittance / WATER_SCATTERING;

  return color * transmittance;// + scatter;
  // color *= fog(vec3(0.0, cameraPosition.y, 0.0), mat3(gbufferModelViewInverse) * normalize(b - a), worldLightDir, distance(a, b));
  return color;
}

#endif