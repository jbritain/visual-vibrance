#ifndef FOG_GLSL
#define FOG_GLSL

vec3 atmosphericFog(vec3 color, vec3 viewPos){
  vec3 worldDir = mat3(gbufferModelViewInverse) * normalize(viewPos);
  color.rgb = mix(color.rgb, getSky(worldDir, false), smoothstep(0.8 * far, far, length(viewPos)));
  return color;
}

#endif