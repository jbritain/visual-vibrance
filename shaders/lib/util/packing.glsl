#ifndef PACKING_GLSL
#define PACKING_GLSL

// pack 4 8 bit floats into a 32 bit float
float pack4x8F(vec4 a) {
  uvec4 v = uvec4(round(clamp01(a) * 255.0)) << uvec4(0, 8, 16, 24);

  return uintBitsToFloat(sum4(v));
}

vec4 unpack4x8F(float encodedbuffer) {
  uvec4 decode = uvec4(floatBitsToUint(encodedbuffer));
  decode.yzw = decode.yzw >> uvec3(8, 16, 24);
  decode.xyz = decode.xyz & 255;

  return vec4(decode) / 255.0;
}

// pack 2 16 bit floats into a 32 bit float
float pack2x16F(vec2 a) {
  uvec2 v = uvec2(round(clamp01(a) * 65535.0)) << uvec2(0, 16);

  return uintBitsToFloat(v.x + v.y);
}

vec2 unpack2x16F(float encodedbuffer) {
  uvec2 decode = uvec2(floatBitsToUint(encodedbuffer));
  decode.y = decode.y >> 16;
  decode.x = decode.x & 65535;

  return vec2(decode) / 65535.0;
}

// pack 2 8 bit floats into a 16 bit float
float pack2x8F(vec2 a) {
  return dot(floor(255.0 * a + 0.5), vec2(1.0 / 65535.0, 256.0 / 65535.0));
}

float pack2x8F(float a, float b) {
  return pack2x8F(vec2(a, b));
}

vec2 unpack2x8F(float pack) {
  vec2 xy;
  xy.x = modf(65535.0 / 256.0 * pack, xy.y);
  return xy * vec2(256.0 / 255.0, 1.0 / 255.0);
}

// https://knarkowicz.wordpress.com/2014/04/16/octahedron-normal-vector-encoding/
// ---------------------------------------------------------->
vec2 octWrap(vec2 v) {
  vec2 w = 1.0 - abs(v.yx);
  if (v.x < 0.0) w.x = -w.x;
  if (v.y < 0.0) w.y = -w.y;
  return w;
}
vec2 encodeNormal(vec3 n) {
  n = normalize(n + 1e-6); // what the fuck
  n /= abs(n.x) + abs(n.y) + abs(n.z);
  n.xy = n.z > 0.0 ? n.xy : octWrap(n.xy);
  n.xy = n.xy * 0.5 + 0.5;
  return n.xy;
}

vec3 decodeNormal(vec2 f) {
  f = f * 2.0 - 1.0;

  // https://twitter.com/Stubbesaurus/status/937994790553227264
  vec3 n = vec3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
  float t = max(-n.z, 0.0);
  n.x += n.x >= 0.0 ? -t : t;
  n.y += n.y >= 0.0 ? -t : t;
  return normalize(n);
}
// <----------------------------------------------------------

#endif
