#ifndef UTIL_GLSL
#define UTIL_GLSL

float luminance(vec3 color){
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

#endif // UTIL_GLSL