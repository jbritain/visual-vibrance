/*
    Copyright (c) 2024 Josh Britain (jbritain)
    All rights reserved

 __   __ __   ______   __  __   ______   __           __   __ __   ______   ______   ______   __   __   ______   ______    
/\ \ / //\ \ /\  ___\ /\ \/\ \ /\  __ \ /\ \         /\ \ / //\ \ /\  == \ /\  == \ /\  __ \ /\ "-.\ \ /\  ___\ /\  ___\   
\ \ \'/ \ \ \\ \___  \\ \ \_\ \\ \  __ \\ \ \____    \ \ \'/ \ \ \\ \  __< \ \  __< \ \  __ \\ \ \-.  \\ \ \____\ \  __\   
 \ \__|  \ \_\\/\_____\\ \_____\\ \_\ \_\\ \_____\    \ \__|  \ \_\\ \_____\\ \_\ \_\\ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\ 
  \/_/    \/_/ \/_____/ \/_____/ \/_/\/_/ \/_____/     \/_/    \/_/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/ 
                                                                                                                           
    
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

vec3 getMetalf0(uint metalID, vec3 albedo){
	switch(metalID){
		case IRON:
			return vec3(0.78, 0.77, 0.74);
		case GOLD:
			return vec3(1.00, 0.90, 0.61);
		case ALUMINIUM:
			return vec3(1.00, 0.98, 1.00);
		case CHROME:
			return vec3(0.77, 0.80, 0.79);
		case COPPER:
			return vec3(1.00, 0.89, 0.73);
		case LEAD:
			return vec3(0.79, 0.87, 0.85);
		case PLATINUM:
			return vec3(0.92, 0.90, 0.83);
		case SILVER:
			return vec3(1.00, 1.00, 0.91);
	}
	return clamp01(albedo);
}

vec3 getMetalf82(uint metalID, vec3 albedo){
	switch(metalID){
		case IRON:
			return vec3(0.74, 0.76, 0.76);
		case GOLD:
			return vec3(1.00, 0.93, 0.73);
		case ALUMINIUM:
			return vec3(0.96, 0.97, 0.98);
		case CHROME:
			return vec3(0.74, 0.79, 0.78);
		case COPPER:
			return vec3(1.00, 0.90, 0.80);
		case LEAD:
			return vec3(0.83, 0.80, 0.83);
		case PLATINUM:
			return vec3(0.89, 0.87, 0.81);
		case SILVER:
			return vec3(1.00, 1.00, 0.95);
	}
	return clamp01(albedo);
}

struct Material {
	vec3 albedo;
	float emission;
	vec3 f0;
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
		material.metalID = int(specularData.g * 255 + 0.5) - 229;
		material.f0 = getMetalf0(material.metalID, albedo);
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