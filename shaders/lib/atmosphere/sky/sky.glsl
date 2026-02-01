#ifndef HILLAIRE_GLSL
#define HILLAIRE_GLSL

vec3 sun(vec3 rayDir) {
  const float minSunCosTheta = cos(sunAngularRadius);

  float cosTheta = dot(rayDir, worldSunDir);
  if (cosTheta >= minSunCosTheta) return sunRadiance;

  return vec3(0.0);
}

float fogify(float x, float w) {
  return w / (x * x + w);
}

vec3 endSky(vec3 dir, bool includeSun) {
  return sunlightColor * smoothstep(0.8, 1.0, dot(dir, worldLightDir)) * float(includeSun);
}

vec3 getSky(vec3 color, vec3 rayDir, bool includeSun) {
  #if ! defined WORLD_OVERWORLD && ! defined WORLD_THE_END
  return mix(
    pow(skyColor, vec3(2.2)),
    pow(fogColor, vec3(2.2)),
    fogify(max0(dot(rayDir, vec3(0.0, 1.0, 0.0))), 0.25)
  );
  #endif

  #ifdef WORLD_THE_END
  return endSky(rayDir, includeSun);
  #endif

  vec3 lum = mix(
    pow(skyColor, vec3(2.2)),
    pow(fogColor, vec3(2.2)),
    fogify(max0(dot(rayDir, vec3(0.0, 1.0, 0.0))), 0.25)
  );

  lum = hsv(lum);
  lum.g *= 1.1;
  lum = rgb(lum);

  if (!includeSun) return lum;

  // #ifdef fsh
  // lum *= mix(0.9, 1.1, interleavedGradientNoise(floor(gl_FragCoord.xy))); // anti banding
  // #endif

  lum *= skyMultiplier;

  return lum;
}

vec3 getSky(vec3 rayDir, bool includeSun) {
  return getSky(vec3(0.0), rayDir, includeSun);
}

#endif // HILLAIRE_GLSL
