#ifndef BRDF_GLSL
#define BRDF_GLSL

float schlickGGX(float NoV, float K) {
	float nom	 = NoV;
	float denom = NoV * (1.0 - K) + K;

	return nom / denom;
}
	
float geometrySmith(vec3 N, vec3 V, vec3 L, float K) {
	float NoV = max(dot(N, V), 0.0);
	float NoL = max(dot(N, L), 0.0);
	float ggx1 = schlickGGX(NoV, K);
	float ggx2 = schlickGGX(NoL, K);

	return ggx1 * ggx2;
}


vec3 schlick(Material material, float NoV){
	const vec3 f0 = material.f0;
	const vec3 f82 = material.f82;
	if(material.metalID == NO_METAL){ // normal schlick approx.
		return clamp01(vec3(f0 + (1.0 - f0) * pow5(1.0 - NoV)));
	} else { // lazanyi schlick - https://www.shadertoy.com/view/DdlGWM
		vec3 a = (823543./46656.) * (f0 - f82) + (49./6.) * (1.0 - f0);

		float p1 = 1.0 - NoV;
		float p2 = p1*p1;
		float p4 = p2*p2;

		return clamp01(f0 + ((1.0 - f0) * p1 - a * NoV * p2) * p4);
	}
}

vec3 brdf(Material material, vec3 mappedNormal, vec3 faceNormal, vec3 viewPos, float scatter){
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
    float NoH = dot(N, H);

	float alpha = max(0.02, material.roughness);

	vec3 F = clamp01(schlick(material, HoV));

	// trowbridge-reitz ggx
	float denominator = max(pow2(NoH) * (pow2(alpha) - 1.0) + 1.0, 1e-6);
	float D = pow2(alpha) / (PI * pow2(denominator));
	float G = geometrySmith(N, V, L, material.roughness);

	vec3 Rs = (F * D * G) / (4.0 * NoV + 1e-6);

	if(material.metalID != NO_METAL){
		Rs *= material.albedo;
	}

	vec3 Rd = material.albedo * (1.0 - F) * clamp01(NoL + scatter);

	return Rs + Rd;
}

#endif // BRDF_GLSL