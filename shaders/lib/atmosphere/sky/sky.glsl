#ifndef HILLAIRE_GLSL
#define HILLAIRE_GLSL

#include "/lib/atmosphere/sky/hillaireCommon.glsl"

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

vec3 getSky(vec3 rayDir, bool includeSun){
    vec3 lum = getValFromSkyLUT(rayDir);

    if (!includeSun) return lum;

    vec3 sunLum = sun(rayDir);

    if (length(sunLum) > 0.0) {
        if (rayIntersectSphere(atmospherePos, rayDir, groundRadiusMM) >= 0.0) {
            sunLum *= 0.0;
        } else {
            // If the sun value is applied to this pixel, we need to calculate the transmittance to obscure it.
            sunLum *= getValFromTLUT(sunTransmittanceLUTTex, tLUTRes, atmospherePos, worldSunDir);
        }
    }

    lum += sunLum;
    return lum;
}

#endif // HILLAIRE_GLSL