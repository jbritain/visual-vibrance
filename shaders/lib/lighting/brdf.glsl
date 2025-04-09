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

#ifndef BRDF_GLSL
#define BRDF_GLSL

// https://advances.realtimerendering.com/s2017/DecimaSiggraph2017.pdf
float getNoHSquared(float NoL, float NoV, float VoL, float radius) {
  float radiusCos = cos(radius);
	float radiusTan = tan(radius);
  
  float RoL = 2.0 * NoL * NoV - VoL;
  if (RoL >= radiusCos)
    return 1.0;

  float rOverLengthT = radiusCos * radiusTan / sqrt(1.0 - RoL * RoL);
  float NoTr = rOverLengthT * (NoV - RoL * NoL);
  float VoTr = rOverLengthT * (2.0 * NoV * NoV - 1.0 - RoL * VoL);

  float triple = sqrt(clamp(1.0 - NoL * NoL - NoV * NoV - VoL * VoL + 2.0 * NoL * NoV * VoL, 0.0, 1.0));
  
  float NoBr = rOverLengthT * triple, VoBr = rOverLengthT * (2.0 * triple * NoV);
  float NoLVTr = NoL * radiusCos + NoV + NoTr, VoLVTr = VoL * radiusCos + 1.0 + VoTr;
  float p = NoBr * VoLVTr, q = NoLVTr * VoLVTr, s = VoBr * NoLVTr;  
  float xNum = q * (-0.5 * p + 0.25 * VoBr * NoLVTr);
  float xDenom = p * p + s * ((s - 2.0 * p)) + NoLVTr * ((NoL * radiusCos + NoV) * VoLVTr * VoLVTr + 
           q * (-0.5 * (VoLVTr + VoL * radiusCos) - 0.5));
  float twoX1 = 2.0 * xNum / (xDenom * xDenom + xNum * xNum);
  float sinTheta = twoX1 * xDenom;
  float cosTheta = 1.0 - twoX1 * xNum;
  NoTr = cosTheta * NoTr + sinTheta * NoBr;
  VoTr = cosTheta * VoTr + sinTheta * VoBr;
  
  float newNoL = NoL * radiusCos + NoTr;
  float newVoL = VoL * radiusCos + VoTr;
  float NoH = NoV + newNoL;
  float HoH = 2.0 * newVoL + 2.0;
  return clamp(NoH * NoH / HoH, 0.0, 1.0);
}

float schlickGGX(float NoV, float K) {
	float nom	 = NoV;
	float denom = NoV * (1.0 - K) + K;

	return nom / denom;
}
	
float geometrySmith(vec3 N, vec3 V, vec3 L, float K) {
	float NoV = max(dot(N, V), 1e-6);
	float NoL = max(dot(N, L), 1e-6);
	float ggx1 = schlickGGX(NoV, K);
	float ggx2 = schlickGGX(NoL, K);

	return ggx1 * ggx2;
}


vec3 fresnel(Material material, float NoV){
	if(material.metalID == NO_METAL || material.metalID == OTHER_METAL){ // normal schlick approx.
		return clamp01(vec3(material.f0 + (1.0 - material.f0) * pow5(1.0 - NoV)));
	} else {
		// https://naos-be.zcu.cz/server/api/core/bitstreams/c2d8b0a7-9947-4458-98e3-d3f8df920153/content
		mat3x2 N_K = getMetalN_K(material.metalID);
		const vec3 n = vec3(N_K[0][0], N_K[1][0], N_K[2][0]);
		const vec3 k = vec3(N_K[0][1], N_K[1][1], N_K[2][1]);

		return (pow2(n - 1) + 4 * n * pow5(1.0 - NoV) + pow2(k)) / (pow2(n + 1) + pow2(k));
	}
}

vec3 fresnelRoughness(Material material, float NoV){
	if(material.metalID == NO_METAL || material.metalID == OTHER_METAL){
		return material.f0 + (max(vec3(1.0 - material.roughness), material.f0) - material.f0) * pow(clamp(1.0 - NoV, 0.0, 1.0), 5.0);
	} else {
		return material.albedo + (max(vec3(1.0 - material.roughness), material.albedo) - material.albedo) * pow(clamp(1.0 - NoV, 0.0, 1.0), 5.0);
	}
}

vec3 brdf(Material material, vec3 mappedNormal, vec3 faceNormal, vec3 viewPos, vec3 shadow, float scatter){
	vec3 L = lightDir;
	float faceNoL = clamp01(dot(faceNormal, L));
	float mappedNoL = clamp01(dot(mappedNormal, L));

	float NoL = clamp01(mappedNoL * smoothstep(0.0, 0.1, faceNoL));

	if(NoL + scatter < 1e-6){
		return vec3(0.0);
	}

	vec3 V = normalize(-viewPos);
	vec3 N = mappedNormal;
	vec3 H = normalize(L + V);

	float NoV = dot(N, V);
	float VoL = dot(V, L);
	float HoV = dot(H, V);

	float alpha = max(1e-3, material.roughness);
	float NoHSquared = getNoHSquared(NoL, NoV, VoL, isDay? sunAngularRadius : moonAngularRadius);
	// float NoHSquared = pow2(dot(N, H));



	vec3 F = clamp01(fresnel(material, HoV));

	// trowbridge-reitz ggx
	float denominator = NoHSquared * (pow2(alpha) - 1.0) + 1.0;

	float D = max0(pow2(alpha) / (PI * pow2(denominator)));

	float G = max0(geometrySmith(N, V, L, material.roughness));

	if(material.metalID != NO_METAL){
		F *= material.albedo;
	}

	vec3 Rs = (F * D * G) / (4.0 * NoV + 1e-6);


	// this was causing some weird issues
	if(NoL < 1e-6){
		Rs = vec3(0.0);
	}


	vec3 Rd = material.albedo * (1.0 - F) * clamp01(NoL);

	return (Rs + Rd) * shadow + (scatter * material.albedo);
}

#endif // BRDF_GLSL