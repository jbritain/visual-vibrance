#ifndef HILLAIRE_GLSL
#define HILLAIRE_GLSL

#include "/lib/atmosphere/sky/hillaireCommon.glsl"

/* 
    'Production Sky Rendering' by Andrew Helmer
    https://www.shadertoy.com/view/slSXRW
*/


vec3 getValFromSkyLUT(vec3 rayDir) {
    float height = atmospherePos.y;
    vec3 up = vec3(0.0, 1.0, 0.0);
    
    float horizonAngle = safeacos(sqrt(height * height - groundRadiusMM * groundRadiusMM) / height);
    float altitudeAngle = horizonAngle - acos(dot(rayDir, up)); // Between -PI/2 and PI/2
    float azimuthAngle; // Between 0 and 2*PI
    if (abs(altitudeAngle) > (0.5*PI - .0001)) {
        // Looking nearly straight up or down.
        azimuthAngle = 0.0;
    } else {
        vec3 right = vec3(1.0, 0.0, 0.0);
        vec3 forward = vec3(0.0, 0.0, -1.0);
        
        vec3 projectedDir = normalize(rayDir - up*(dot(rayDir, up)));
        float sinTheta = dot(projectedDir, right);
        float cosTheta = dot(projectedDir, forward);
        azimuthAngle = atan(sinTheta, cosTheta) + PI;
    }
    
    // Non-linear mapping of altitude angle. See Section 5.3 of the paper.
    float v = 0.5 + 0.5*sign(altitudeAngle)*sqrt(abs(altitudeAngle)*2.0/PI);
    vec2 uv = vec2(azimuthAngle / (2.0*PI), v);
    
    return texture(skyViewLUTTex, uv).rgb;
}

vec3 sun(vec3 rayDir){
    const float minSunCosTheta = cos(sunAngularRadius);

    float cosTheta = dot(rayDir, worldSunDir);
    if (cosTheta >= minSunCosTheta) return sunRadiance;

    return vec3(0.0);
}

float fogify(float x, float w) {
	return w / (x * x + w);
}


vec3 endSky(vec3 dir, bool includeSun){
  return vec3(0.5, 0.4, 1.0) * 8.0 * clamp01(dot(dir, worldLightDir) * 0.5 + 0.5) * 0.01 + 
  step(0.9989, dot(dir, worldLightDir)) * step(dot(dir, worldLightDir), 0.999) * 100 * float(includeSun);
}

vec3 getSky(vec3 color, vec3 rayDir, bool includeSun){
    #if !defined WORLD_OVERWORLD && !defined WORLD_THE_END
    return pow(mix(skyColor, fogColor, fogify(max0(dot(rayDir, vec3(0.0, 1.0, 0.0))), 0.25)), vec3(2.2));
    #endif

    #ifdef WORLD_THE_END
    return endSky(rayDir, includeSun);
    #endif

    vec3 lum = getValFromSkyLUT(rayDir);

    lum = mix(lum, weatherSkylightColor, wetness);

    if (!includeSun) return lum;

    vec3 sunLum = sun(rayDir);

    if (length(sunLum) > 0.0) {
        if (rayIntersectSphere(atmospherePos, rayDir, groundRadiusMM) >= 0.0) {
            sunLum *= 0.0;
        } else {
            // If the sun value is applied to this pixel, we need to calculate the transmittance to obscure it.
            sunLum *= getValFromTLUT(sunTransmittanceLUTTex, tLUTRes, atmospherePos, worldSunDir);
        }
    } else {
        if (color != vec3(0.0)){
            lum += color * getValFromTLUT(sunTransmittanceLUTTex, tLUTRes, atmospherePos, rayDir);
        }
    }

    lum = mix(lum, weatherSkylightColor, wetness);

    lum += sunLum;
    return lum;
}

vec3 getSky(vec3 rayDir, bool includeSun){
    return getSky(vec3(0.0), rayDir, includeSun);
}



#endif // HILLAIRE_GLSL