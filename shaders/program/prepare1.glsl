#include "/lib/common.glsl"

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

#include "/lib/common.glsl"

#include "/lib/atmosphere/sky/sky.glsl"

void main()
{
    skylightColor = getSky(vec3(0.0, 1.0, 0.0), false);
}

#endif