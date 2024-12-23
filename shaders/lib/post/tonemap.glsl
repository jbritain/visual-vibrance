#ifndef TONEMAP_GLSL
#define TONEMAP_GLSL

vec3 jodieReinhardTonemap(vec3 v){
    float l = luminance(v);
    vec3 tv = v / (1.0f + v);
    return mix(v / (1.0f + l), tv, tv);
}

vec3 uncharted2TonemapPartial(vec3 x)
{
    float A = 0.15f;
    float B = 0.50f;
    float C = 0.10f;
    float D = 0.20f;
    float E = 0.02f;
    float F = 0.30f;
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 uncharted2FilmicTonemap(vec3 v)
{
    float exposure_bias = 2.0f;
    vec3 curr = uncharted2TonemapPartial(v * exposure_bias);

    vec3 W = vec3(11.2f);
    vec3 white_scale = vec3(1.0f) / uncharted2TonemapPartial(W);
    return curr * white_scale;
}


vec3 hejlBurgessTonemap(vec3 v){
    v /= 2.0;
    vec3 x = max0(v - 0.004);
    return (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
}

vec3 ACESTonemap(vec3 v) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp01((v*(a*v+b))/(v*(c*v+d)+e));
}

#define tonemap hejlBurgessTonemap // [jodieReinhardTonemap uncharted2FilmicTonemap hejlBurgessTonemap ACESTonemap]

#endif // TONEMAP_GLSL