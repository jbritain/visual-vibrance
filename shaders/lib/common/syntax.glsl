#ifndef SYNTAX_GLSL
#define SYNTAX_GLSL

const float PI = 3.14159265358;

#define pow2(x) (x*x)
#define pow3(x) (x*x*x)
#define pow4(x) (x*x*x*x)
#define pow5(x) (x*x*x*x*x)

#define rcp(x) (1.0 / (x))

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

#define clamp01(x) clamp(x, 0.0, 1.0)

#define saturate clamp01
#define lerp mix

#endif // SYNTAX_GLSL