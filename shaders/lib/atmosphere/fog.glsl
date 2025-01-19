

#ifndef FOG_GLSL
#define FOG_GLSL

#include "/lib/atmosphere/clouds.glsl"

vec3 atmosphericFog(vec3 color, vec3 viewPos){
  float transmittance = clamp01(exp(-length(viewPos) * 0.0004 * (EBS.y)));
  vec3 fogColor = weatherSkylightColor;

  #ifdef DISTANT_HORIZONS
  fogColor = mix(fogColor, getSky(normalize(mat3(gbufferModelViewInverse) * viewPos), false), smoothstep(dhFarPlane, dhFarPlane * 2.0, length(viewPos)));
  #else
  fogColor = mix(fogColor, getSky(normalize(mat3(gbufferModelViewInverse) * viewPos), false), smoothstep(far, far * 2.0, length(viewPos)));
  #endif

  color = mix(fogColor, color.rgb, transmittance);
  return color;
}

#define FOG_DENSITY 0.01
// above this height there is no fog
#define HEIGHT_FOG_TOP_HEIGHT mix(150, CLOUD_PLANE_ALTITUDE, wetness)
// below this height there is a constant fog density
#define HEIGHT_FOG_MIDDLE_HEIGHT 30
#define HEIGHT_FOG_BOTTOM_HEIGHT 0

float getFogDensity(float height){
  if(height > HEIGHT_FOG_MIDDLE_HEIGHT){
    return (1.0 - smoothstep(HEIGHT_FOG_MIDDLE_HEIGHT, HEIGHT_FOG_TOP_HEIGHT, height)) * FOG_DENSITY;
  } else {
    return FOG_DENSITY;
  }
  
}

vec3 cloudyFog(vec3 color, vec3 playerPos, float depth){
  // we want fog to occur between time = 15000 and time = 1000
  float fogFactor = 0.0;
  if(worldTime > 1000){
    fogFactor = smoothstep(15000, 24000, worldTime);  
  } else {
    fogFactor = 1.0 - smoothstep(0, 1000, worldTime);
  }

  fogFactor += wetness * 0.1;
  fogFactor += thunderStrength;

  if(fogFactor < 1e-6){
    return color;
  }

  float localTopHeight = HEIGHT_FOG_TOP_HEIGHT - cameraPosition.y;
  float localMiddleHeight = HEIGHT_FOG_MIDDLE_HEIGHT - cameraPosition.y;
  float localBottomHeight = HEIGHT_FOG_BOTTOM_HEIGHT - cameraPosition.y;

  vec3 dir = normalize(playerPos);

  // check if not looking at the fog at all
  if(cameraPosition.y > HEIGHT_FOG_TOP_HEIGHT && dir.y > 0){
    return color;
  }

  float opticalDepth;

  // top part
    vec3 a = vec3(0.0);
    vec3 b = vec3(0.0);

    if(!rayPlaneIntersection(vec3(0.0), dir, localMiddleHeight, a)){
      a = vec3(0.0);
    }
    if(!rayPlaneIntersection(vec3(0.0), dir, localTopHeight, b)){
      b = vec3(0.0);
    }

    if(length(a) > length(b)){ // for convenience, a will always be closer to the camera
      vec3 swap = a;
      a = b;
      b = swap;
    }

    if(length(playerPos) < length(a)){
      a = vec3(0.0);
      b = vec3(0.0);
    } else if(length(playerPos) < length(b) && depth != 1.0){ // terrain in the way
      b = playerPos;
    }
    

    float densityA = getFogDensity(a.y + cameraPosition.y);
    float densityB = getFogDensity(b.y + cameraPosition.y);

  opticalDepth = max0(distance(a, b) * (densityA + densityB) / 2) * fogFactor;

    if(!rayPlaneIntersection(vec3(0.0), dir, localBottomHeight, a)){
      a = vec3(0.0);
    }
    if(!rayPlaneIntersection(vec3(0.0), dir, localMiddleHeight, b)){
      b = vec3(0.0);
    }

    if(length(a) > length(b)){ // for convenience, a will always be closer to the camera
      vec3 swap = a;
      a = b;
      b = swap;
    }

    if(length(playerPos) < length(a)){
      a = vec3(0.0);
      b = vec3(0.0);
    } else if(length(playerPos) < length(b) && depth != 1.0){ // terrain in the way
      b = playerPos;
    }

  opticalDepth += distance(a, b) * FOG_DENSITY * fogFactor;

  float transmittance = exp(-opticalDepth);

  float sunVisibility = (depth == 1.0 ? 1.0 : sunVisibilitySmooth);

  vec3 radiance = sunlightColor * sunVisibilitySmooth * getMiePhase(dot(normalize(playerPos), worldLightDir)) + skylightColor * EBS.y;

  vec3 scatter = (radiance - radiance * clamp01(transmittance));

  return color * transmittance + scatter;
}

vec3 defaultFog(vec3 color, vec3 viewPos){
  #ifdef WORLD_OVERWORLD
  if(isEyeInWater < 2){
    return color;
  }
  #endif

  #ifdef WORLD_THE_END
    return color;
  #endif

  // approximately fit beer's law to match the given fog end
  const float zeroPoint = -log(0.1); // at a distance of fogEnd, the transmittance hits 0.1
  float extinction = zeroPoint/fogEnd;

  color.rgb = mix(color.rgb, pow(fogColor, vec3(2.2)), 1.0 - clamp01(exp(-extinction * max0(length(viewPos)))));

  return color;
}

#endif