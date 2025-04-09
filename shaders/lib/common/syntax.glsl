#ifndef SYNTAX_GLSL
#define SYNTAX_GLSL

const float PI = 3.14159265358;

#define _rcp(x) (1.0 / x)
#define _log10(x, y) (log2(x) / log2(y))
#define _pow2(x) (x*x)
#define _pow3(x) (x*x*x)
#define _pow4(x) (x*x*x*x)
#define _pow5(x) (x*x*x*x*x)

float pow2(in float x) {
    return _pow2(x);
}
int pow2(in int x) {
    return _pow2(x);
}
vec2 pow2(in vec2 x) {
    return _pow2(x);
}
vec3 pow2(in vec3 x) {
    return _pow2(x);
}
vec4 pow2(in vec4 x) {
    return _pow2(x);
}

float pow3(in float x) {
    return _pow3(x);
}
int pow3(in int x) {
    return _pow3(x);
}
vec2 pow3(in vec2 x) {
    return _pow3(x);
}
vec3 pow3(in vec3 x) {
    return _pow3(x);
}
vec4 pow3(in vec4 x) {
    return _pow3(x);
}

float pow4(in float x) {
    return _pow4(x);
}
int pow4(in int x) {
    return _pow4(x);
}
vec2 pow4(in vec2 x) {
    return _pow4(x);
}
vec3 pow4(in vec3 x) {
    return _pow4(x);
}
vec4 pow4(in vec4 x) {
    return _pow4(x);
}

float pow5(in float x) {
    return _pow5(x);
}
int pow5(in int x) {
    return _pow5(x);
}
vec2 pow5(in vec2 x) {
    return _pow5(x);
}
vec3 pow5(in vec3 x) {
    return _pow5(x);
}
vec4 pow5(in vec4 x) {
    return _pow5(x);
}

float rcp(in float x) {
    return _rcp(x);
}
vec2 rcp(in vec2 x) {
    return _rcp(x);
}
vec3 rcp(in vec3 x) {
    return _rcp(x);
}
vec4 rcp(in vec4 x) {
    return _rcp(x);
}

#define max0(x) max(x, 0.0)
#define max1(x) max(x, 1.0)
#define min0(x) min(x, 0.0)
#define min1(x) min(x, 1.0)

#define min3(x, y, z)    min(x, min(y, z))
#define min4(x, y, z, w) min(min(x, y), min(z, w))

#define minVec2(v) min(v.x, v.y)
#define minVec3(v) min(v.x, min(v.y, v.z))
#define minVec4(v) min(min(v.x, v.y), min(v.z, v.w))

#define max3(x, y, z)    max(x, max(y, z))
#define max4(x, y, z, w) max(max(x, y), max(z, w))

#define maxVec2(v) max(v.x, v.y)
#define maxVec3(v) max(v.x, max(v.y, v.z))
#define maxVec4(v) max(max(v.x, v.y), max(v.z, v.w))

#define sum2(v) ((v).x + (v).y)
#define sum3(v) (((v).x + (v).y) + (v).z)
#define sum4(v) (((v).x + (v).y) + ((v).z + (v).w))

#define mean3(v) sum3(v) / (3.0)

#define clamp01(x) clamp(x, 0.0, 1.0)

#define saturate clamp01
#define lerp mix

#define RED vec3(1.0, 0.0, 0.0)
#define GREEN vec3(0.0, 1.0, 0.0)
#define BLUE vec3(0.0, 0.0, 1.0)

#endif // SYNTAX_GLSL