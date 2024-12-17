#ifndef UTIL_INCLUDE
#define UTIL_INCLUDE

float luminance(vec3 color){
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

#endif // UTIL_INCLUDE