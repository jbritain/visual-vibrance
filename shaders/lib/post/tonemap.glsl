#ifndef TONEMAP_GLSL
#define TONEMAP_GLSL

vec3 jodieReinhardTonemap(vec3 v){
    float l = luminance(v);
    vec3 tv = v / (1.0f + v);
    return mix(v / (1.0f + l), tv, tv);
}

#define tonemap jodieReinhardTonemap

#endif // TONEMAP_GLSL