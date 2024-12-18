#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/shadowSpace.glsl"

vec2 vogelDiscSample(int stepIndex, int stepCount, float noise) {
    float rotation = noise * 2 * PI;
    const float goldenAngle = 2.4;

    float r = sqrt(stepIndex + 0.5) / sqrt(float(stepCount));
    float theta = stepIndex * goldenAngle + rotation;

    return r * vec2(cos(theta), sin(theta));
}

float getShadowing(vec3 feetPlayerPos, vec3 faceNormal, vec2 lightmap){
    vec4 shadowClipPos = getShadowClipPos(feetPlayerPos);

    float faceNoL = dot(faceNormal, lightDir);

    vec3 bias = getShadowBias(shadowClipPos.xyz, mat3(gbufferModelViewInverse) * faceNormal, faceNoL);
    shadowClipPos.xyz += bias;
    float fakeShadow = clamp01(smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y));
    vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

    float distFade = pow5(
		max(
			clamp01(maxVec2(abs(shadowClipPos.xy))),
			mix(
				1.0, 0.55, 
				smoothstep(0.33, 0.8, worldLightDir.y)
			) * (dot(feetPlayerPos.xz, feetPlayerPos.xz) * rcp(pow2(shadowDistance)))
		)
	);

    float shadow = 0.0;
    float noise = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
    

    for (int i = 0; i < SHADOW_SAMPLES; i++) {
        vec3 offset = vec3(vogelDiscSample(i, SHADOW_SAMPLES, noise), 0.0) * SHADOW_RADIUS;
        shadow += shadow2D(shadowtex0, shadowScreenPos.xyz + offset).r;
    }

    shadow /= float(SHADOW_SAMPLES);

    return mix(shadow, fakeShadow, clamp01(distFade));
}

#endif // SHADOWS_GLSL