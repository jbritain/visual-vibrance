/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under the MIT license

      _____   __   _                          
     / ___/  / /  (_)  __ _   __ _  ___   ____
    / (_ /  / /  / /  /  ' \ /  ' \/ -_) / __/
    \___/  /_/  /_/  /_/_/_//_/_/_/\__/ /_/   
    
    By jbritain
    https://jbritain.net
                                            
*/

#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/shadowSpace.glsl"
#include "/lib/atmosphere/clouds.glsl"

vec3 sampleShadow(vec3 shadowScreenPos){
	float transparentShadow = shadow2D(shadowtex0HW, shadowScreenPos).r;

	if(transparentShadow >= 1.0 - 1e-6){
		return vec3(transparentShadow);
	}

	float opaqueShadow = shadow2D(shadowtex1HW, shadowScreenPos).r;

	if(opaqueShadow <= 1e-6){
		return vec3(opaqueShadow);
	}
  
	vec4 shadowColorData = texture(shadowcolor0, shadowScreenPos.xy);
	vec3 shadowColor = pow(shadowColorData.rgb, vec3(2.2)) * (1.0 - shadowColorData.a);
	return mix(shadowColor * opaqueShadow, vec3(1.0), transparentShadow);
}

vec3 getShadowing(vec3 feetPlayerPos, vec3 faceNormal, vec2 lightmap, Material material, out float scatter){
    scatter = 0.0;
    if(EBS.y == 0.0 && lightmap.y < 0.1 && constantMood > 0.2){
      return vec3(0.0);
    }

    vec3 cloudShadow = vec3(1.0);

    #ifdef CLOUD_SHADOWS
    cloudShadow = getCloudShadow(feetPlayerPos);
    #endif

    #ifdef WORLD_THE_NETHER
    return vec3(0.0);
    #endif

    float fakeShadow = clamp01(smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y));


    float faceNoL = dot(faceNormal, lightDir);
    float sampleRadius = SHADOW_SOFTNESS * 0.003;

    if(faceNoL <= 1e-6 && material.sss > 1e-6){
      scatter = max0(1.0 - faceNoL) * material.sss;
      sampleRadius *= (1.0 + 7.0 * material.sss);

      float VoL = dot(normalize(feetPlayerPos), worldSunDir);
      float phase1 = henyeyGreenstein(0.4, VoL) * 0.75;
      float phase2 = henyeyGreenstein(0.1, VoL) * 0.5;
      // float phase3 = henyeyGreenstein(0.6, VoL);

      scatter *= max(phase1, phase2);
    }

    #ifndef SHADOWS
    return vec3(fakeShadow) * cloudShadow;
    #else

    vec4 shadowClipPos = getShadowClipPos(feetPlayerPos);


    vec3 bias = getShadowBias(shadowClipPos.xyz, mat3(gbufferModelViewInverse) * faceNormal, faceNoL);
    shadowClipPos.xyz += bias;
    
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
    
    
	if(distFade < 1.0){
		float noise = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

		// scatter falloff
		float scatterSampleAngle = noise * 2 * PI;
		vec2 scatterSampleOffset = vec2(sin(scatterSampleAngle), cos(scatterSampleAngle)) * (sampleRadius / SHADOW_SAMPLES);
		float blockerDepthDifference = max0(shadowScreenPos.z - texture(shadowtex0, shadowScreenPos.xy + scatterSampleOffset).r);
		float blockerDistance = blockerDepthDifference * 512;

		scatter *= mix(1.0 - smoothstep(blockerDistance, 0.0, 2.0), 1.0, distFade);
    
    if(faceNoL > 1e-6){
      for (int i = 0; i < SHADOW_SAMPLES; i++) {
        vec3 offset = vec3(vogelDiscSample(i, SHADOW_SAMPLES, noise), 0.0) * sampleRadius;
        shadow += sampleShadow(shadowScreenPos + offset);
      }

      shadow /= float(SHADOW_SAMPLES);
    }

	}

  scatter -= scatter * 0.75 * clamp01(distFade);
  scatter *= maxVec3(cloudShadow); // since the cloud shadows are so blurry anyway, if something is shadowed by a cloud, it's probably not getting any sunlight
  shadow = mix(shadow, vec3(fakeShadow), clamp01(distFade));
  return shadow * cloudShadow;
  
  #endif
}

#endif // SHADOWS_GLSL