#ifndef DH_BLEND_GLSL
#define DH_BLEND_GLSL

#ifdef DISTANT_HORIZONS

uint murmurHash13(uvec3 src) {
    const uint M = 0x5bd1e995u;
    uint h = 1190494759u;
    src *= M;
    src ^= src >> 24u;
    src *= M;
    h *= M;
    h ^= src.x;
    h *= M;
    h ^= src.y;
    h *= M;
    h ^= src.z;
    h ^= h >> 13u;
    h *= M;
    h ^= h >> 15u;
    return h;
}

// 1 output, 3 inputs
float hash13(vec3 src) {
    uint h = murmurHash13(floatBitsToUint(src));
    return uintBitsToFloat(h & 0x007fffffu | 0x3f800000u) - 1.0;
}

void blendAtEdge(vec3 viewPos, float far, vec3 seed) {
    float l = length(viewPos);
    if (l >= far - 15) {
        float opacity = sqrt(clamp((1 + far - l) / 16, 0.0, 1.0));

        if (hash13(seed) > opacity)
            discard;
    }

    // if (length(viewPos) > far)
    //     discard;
}

#else

void blendAtEdge(vec3 viewPos, float far, vec3 seed) {
    return;
}

#endif

#endif
