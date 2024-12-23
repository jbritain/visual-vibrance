#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL

#define CLOUD_PLANE_ALTITUDE 1000
#define CLOUD_PLANE_HEIGHT 100
#define CLOUD_EXTINCTION_COLOR vec3(1.0)

float remap(float val, float oMin, float oMax, float nMin, float nMax){
  return mix(nMin, nMax, smoothstep(oMin, oMax, val));
}

// O is the ray origin, D is the direction
// height is the height of the plane
bool rayPlaneIntersection(vec3 O, vec3 D, float height, inout vec3 point){
  vec3 N = vec3(0.0, sign(O.y - height), 0.0); // plane normal vector
  vec3 P = vec3(0.0, height, 0.0); // point on the plane

  float NoD = dot(N, D);
  if(NoD == 0.0){
    return false;
  }

  float t = dot(N, P - O) / NoD;

  point = O + t*D;

  if(t < 0){
    return false;
  }

  return true;
}

vec3 multipleScattering(float density, float costh, float g1, float g2, vec3 extinction, int octaves, float lobeWeight, float attenuation, float contribution, float phaseAttenuation){
  vec3 radiance = vec3(0.0);

  // float attenuation = 0.9;
  // float contribution = 0.5;
  // float phaseAttenuation = 0.7;

  float a = 1.0;
  float b = 1.0;
  float c = 1.0;

  for(int n = 0; n < octaves; n++){
    float phase = dualHenyeyGreenstein(g1 * c, g2 * c, costh, lobeWeight);
    radiance += b * phase * exp(-density * extinction * a);

    a *= attenuation;
    b *= contribution;
    c *= (1.0 - phaseAttenuation);
  }

  return radiance;
}

vec3 getClouds(vec3 color, vec3 worldDir){
  #ifndef CLOUDS
  return color;
  #endif

  vec3 point;
  if(!rayPlaneIntersection(cameraPosition, worldDir, CLOUD_PLANE_ALTITUDE, point)) return color;

  point.z += worldTime;

  float density = smoothstep(mix(0.25, 0.0, wetness), mix(0.75, 0.25, wetness), texture(perlinNoiseTex, mod(point.xz / 30000, 1.0)).r);
  density = remap(density, texture(perlinNoiseTex, mod(point.xz / 1000, 1.0)).g, 1.0, 0.0, 1.0);

  density = pow2(density);

  density *= 0.01;

  // angles relative to sun
  float costh = dot(worldDir, worldLightDir);
  float sinth = sqrt(1.0 - pow2(costh));

  float distanceThroughPlaneTowardsSun = CLOUD_PLANE_HEIGHT;// / sinth;

  float totalDensityTowardsSun = density * distanceThroughPlaneTowardsSun;
  
  // angles relative to the horizontal
  float tanph = worldDir.y / length(worldDir.xz);
  float sinph = tanph / sqrt(1.0 + pow2(tanph));

  float distanceThroughPlane = CLOUD_PLANE_HEIGHT;// / sinph;

  float totalDensityAlongRay = distanceThroughPlane * density;

  vec3 powder = clamp01((1.0 - exp(-totalDensityTowardsSun * 2 * CLOUD_EXTINCTION_COLOR)));

  vec3 radiance = skylightColor + sunlightColor * (1.0 + 9.0 * float(lightDir == sunDir)) * multipleScattering(totalDensityTowardsSun, costh, 0.9, -0.4, CLOUD_EXTINCTION_COLOR, 4, 0.85, 0.9, 0.8, 0.1) * mix(2.0 * powder, vec3(1.0), costh * 0.5 + 0.5);


  vec3 transmittance = exp(-totalDensityAlongRay * CLOUD_EXTINCTION_COLOR);
  vec3 integScatter = (radiance - radiance * clamp01(transmittance)) / CLOUD_EXTINCTION_COLOR;
  vec3 scatter = integScatter * transmittance;

  return color * transmittance + scatter;
}

#endif