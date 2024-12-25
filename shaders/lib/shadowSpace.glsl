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

#ifndef SHADOW_SPACE_GLSL
#define SHADOW_SPACE_GLSL

float cubeLength(vec2 v) {
    vec2 t = abs(pow3(v));
    return pow(t.x + t.y, 1.0/3.0);
}

float getShadowDistanceZ(float depth) {
	depth = depth * 2.0 - 1.0;
	depth /= 0.5; // for distortion
	vec4 shadowHomPos = shadowProjectionInverse * vec4(0.0, 0.0, depth, 1.0);
	return shadowHomPos.z / shadowHomPos.w;
}

vec3 distort(vec3 pos) {
	float factor = cubeLength(pos.xy) * SHADOW_DISTORTION + (1.0 - SHADOW_DISTORTION);
	pos.xy /= factor;
	pos.z /= 2.0;
	// pos.xy += jitter[frameCounter % 16] * rcp(shadowMapResolution);
	return pos;
}

vec4 getShadowClipPos(vec3 playerPos){
	vec4 shadowViewPos = shadowModelView * vec4(playerPos, 1.0);
	vec4 shadowClipPos = shadowProjection * shadowViewPos;
	return shadowClipPos;
}

vec3 getShadowScreenPos(vec4 shadowClipPos){
	vec3 shadowScreenPos = distort(shadowClipPos.xyz); //apply shadow distortion
  	shadowScreenPos.xyz = shadowScreenPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1


	return shadowScreenPos;
}

vec4 getUndistortedShadowScreenPos(vec4 shadowClipPos){

	vec4 shadowScreenPos = shadowClipPos; //convert to shadow ndc space.
  	shadowScreenPos.xyz = shadowScreenPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1


	return shadowScreenPos;
}

vec3 getShadowBias(vec3 pos, vec3 worldNormal, float faceNoL){
	float biasAdjust = log2(max(4.0, shadowDistance - shadowMapResolution * 0.125)) * 0.5;

	float factor = cubeLength(pos.xy) * SHADOW_DISTORTION + (1.0 - SHADOW_DISTORTION);

	return mat3(shadowProjection) * (mat3(shadowModelView) * worldNormal) * factor * biasAdjust;
}

#endif