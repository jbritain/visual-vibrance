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

vec3 sampleShadow(vec3 shadowScreenPos){
  float transparentShadow = shadow2D(shadowtex0, shadowScreenPos).r;

  if(transparentShadow == 1.0){
    return vec3(1.0);
  }

  float opaqueShadow = shadow2D(shadowtex1, shadowScreenPos).r;

  if(opaqueShadow == 0.0){
    return vec3(0.0);
  }

  vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);

  return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec3 getShadowing(vec3 feetPlayerPos, vec3 faceNormal, vec2 lightmap, Material material, out float scatter){
    scatter = 0.0;

    vec4 shadowClipPos = getShadowClipPos(feetPlayerPos);

    float faceNoL = dot(faceNormal, lightDir);

    float sampleRadius = SHADOW_RADIUS;

    if(faceNoL <= 1e-6){
        scatter = pow2(clamp01(faceNoL) * 0.5 + 0.5) * material.sss;
        sampleRadius *= (1.0 + 7.0 * material.sss);
    }

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

    vec3 shadow = vec3(0.0);
    float noise = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
    

    for (int i = 0; i < SHADOW_SAMPLES; i++) {
        vec3 offset = vec3(vogelDiscSample(i, SHADOW_SAMPLES, noise), 0.0) * sampleRadius;
        shadow += sampleShadow(shadowScreenPos + offset);
    }

    shadow /= float(SHADOW_SAMPLES);

    scatter -= scatter * 0.75 * clamp01(distFade);
    return mix(shadow, vec3(fakeShadow), clamp01(distFade));
}

#endif // SHADOWS_GLSL