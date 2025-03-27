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

#ifndef MATERIAL_GLSL
#define MATERIAL_GLSL

// enums for metal IDs
#define NO_METAL 0
#define IRON 1
#define GOLD 2
#define ALUMINIUM 3
#define CHROME 4
#define COPPER 5
#define LEAD 6
#define PLATINUM 7
#define SILVER 8
#define OTHER_METAL 9

mat3x2 getMetalN_K(uint metalID){
	switch(metalID){
		case IRON:
			return mat3x2(
				vec3(2.9114, 2.9497, 2.5845 ),
				vec3(3.0893, 2.9318, 2.7670 )
			);
		case GOLD:
			return mat3x2(
				vec3(0.18299, 0.42108, 1.3734),
				vec3(3.4242, 2.3459, 1.7704)
			);
		case ALUMINIUM:
			return mat3x2(
				vec3(1.3456, 0.96521, 0.61722),
				vec3(7.4746, 6.3995, 5.3031)
			);
		case CHROME:
			return mat3x2(
				vec3(3.1071, 3.1812, 2.3230),
				vec3(3.3314, 3.3291, 3.1350)
			);
		case COPPER:
			return mat3x2(
				vec3(0.27105, 0.67693, 1.3164),
				vec3(3.6092, 2.6248, 2.2921)
			);
		case LEAD:
			return mat3x2(
				vec3(1.9100, 1.8300, 1.4400),
				vec3(3.5100, 3.4000, 3.1800)
			);
		case PLATINUM:
			return mat3x2(
				vec3(2.3757, 2.0847, 1.8453),
				vec3(4.2655, 3.7153, 3.1365)
			);
		case SILVER:
			return mat3x2(
				vec3(0.15943, 0.14512, 0.13547),
				vec3(3.9291, 3.1900, 2.3808)
			);
	}
	return mat3x2(0.0);
}

struct Material {
	vec3 albedo;
	float emission;
	vec3 f0;
	mat3x2 N_K;
	float roughness;
	float sss;
	float porosity;
	uint metalID;
	float ao;
};

const Material waterMaterial = Material(
	vec3(0.0),
	0.0,
	vec3(0.02),
	mat3x2(0.0),
	0.0,
	0.0,
	0.0,
	NO_METAL,
	0.0
);

Material materialFromSpecularMap(vec3 albedo, vec4 specularData){
	Material material;

	material.albedo = albedo;

	#if PBR_MODE == 0
	material.roughness = 1.0;
	material.f0 = vec3(0.0);
	material.metalID = NO_METAL;
	material.porosity = 0.0;
	material.sss = 0.0;
	material.emission = 0.0;
	material.ao = 1.0;

	return material;
	#endif

	material.roughness = pow2(1.0 - specularData.r);
	if(specularData.g <= 229.0/255.0){
		material.f0 = vec3(specularData.g);
		material.metalID = NO_METAL;
	} else {
		material.f0 = albedo;
		material.metalID = int(specularData.g * 255 + 0.5) - 229;
	}

	if(specularData.b <= 0.25){
		material.porosity = specularData.b * 4.0;
		material.sss = 0.0;
	} else {
		material.porosity = (1.0 - specularData.r) * specularData.g; // fall back to using roughness and base reflectance for porosity
		material.sss = (specularData.b - 0.25) * 4.0/3.0;
	}

	material.emission = specularData.a < 1.0 ? specularData.a : 0.0;

	return material;
}

#endif // MATERIAL_GLSL