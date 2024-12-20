#ifndef SETTINGS_GLSL
#define SETTINGS_GLSL

const float shadowDistance = 192;
const int shadowMapResolution = 1024;

const bool shadowHardwareFiltering = true;

#define SHADOW_DISTORTION 0.85
#define SHADOW_RADIUS 0.005
#define SHADOW_SAMPLES 4

#define BLOOM_RADIUS 1.0

#endif // SETTINGS_GLSL