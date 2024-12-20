#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL

#define CLOUD_PLANE_HEIGHT 1000
#define CLOUD_EXTINCTION_COLOR vec3(1.0)

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

vec3 getClouds(vec3 color, vec3 worldDir){
  vec3 point;
  if(!rayPlaneIntersection(cameraPosition, worldDir, CLOUD_PLANE_HEIGHT, point)) return color;

  float density = pow2(texture(perlinNoiseTex, mod(point.xz / 10000, 1.0)).r);

  vec3 transmittance = exp(-density * CLOUD_EXTINCTION_COLOR);
  vec3 radiance = sunlightColor * getMiePhase(dot(worldDir, worldLightDir)) + skylightColor;
  vec3 scatter = (radiance - radiance * clamp01(transmittance)) / CLOUD_EXTINCTION_COLOR;

  return color * transmittance + scatter;
}

#endif