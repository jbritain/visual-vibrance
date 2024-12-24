#ifndef FOG_GLSL
#define FOG_GLSL

vec3 atmosphericFog(vec3 color, vec3 viewPos){
  #ifdef BORDER_FOG
  vec3 worldDir = mat3(gbufferModelViewInverse) * normalize(viewPos);
  color.rgb = mix(color.rgb, getSky(worldDir, false), smoothstep(0.8 * far, far, length(viewPos)));
  #endif
  return color;
}

#define FOG_DENSITY 0.01
// above this height there is no fog
#define HEIGHT_FOG_TOP_HEIGHT 100
// below this height there is a constant fog density
#define HEIGHT_FOG_BOTTOM_HEIGHT 63

float getFogDensity(float height){
  return (1.0 - smoothstep(HEIGHT_FOG_BOTTOM_HEIGHT, HEIGHT_FOG_TOP_HEIGHT, height)) * FOG_DENSITY;
}

vec3 cloudyFog(vec3 color, vec3 playerPos, float depth){
  return color;
  float localTopHeight = HEIGHT_FOG_TOP_HEIGHT - cameraPosition.y;
  float localBottomHeight = HEIGHT_FOG_BOTTOM_HEIGHT - cameraPosition.y;

  vec3 dir = normalize(playerPos);

  // check if not looking at the fog at all
  if(cameraPosition.y > HEIGHT_FOG_TOP_HEIGHT && dir.y > 0){
    return color;
  }

  float totalDensity;

  vec3 a = vec3(0.0);
  vec3 b = playerPos;

  if(localTopHeight < 0){ // above the fog plane
    rayPlaneIntersection(vec3(0.0), dir, localTopHeight, a);
  }

  if(depth == 1.0 && dir.y > 0.0){ // looking into top of fog plane
    rayPlaneIntersection(vec3(0.0), dir, localTopHeight, b);
  }
  

  float densityA = getFogDensity(a.y + cameraPosition.y);
  float densityB = getFogDensity(b.y + cameraPosition.y);

  totalDensity = max0(distance(a, b) * (densityA + densityB) / 2);

  color *= exp(-totalDensity);
  return color;
}

#endif