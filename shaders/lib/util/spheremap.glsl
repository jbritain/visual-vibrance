#ifndef SPHEREMAP_GLSL
#define SPHEREMAP_GLSL

vec2 mapSphere(vec3 dir) {
  dir = normalize(dir);
  //   dir = dir.xzy;

  float theta = atan(dir.z, dir.x);

  theta = mod(theta, 2 * PI);

  float phi = acos(dir.y);

  vec2 uv = vec2(theta / (2 * PI), phi / PI);

  uv += 0.025;
  uv /= 1.05;
  return uv;
}

vec3 unmapSphere(vec2 uv) {
  uv *= 1.05;
  uv -= 0.025;
  float theta = uv.x * 2 * PI;
  float phi = uv.y * PI;

  vec3 dir = normalize(
    vec3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta))
  );

  //   dir = dir.xzy;
  return dir;
}

#endif // SPHEREMAP_GLSL
