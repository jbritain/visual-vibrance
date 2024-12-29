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

#ifndef SCREEN_SPACE_RAYTRACE_GLSL
#define SCREEN_SPACE_RAYTRACE_GLSL

#define BINARY_REFINEMENTS 6
#define BINARY_REDUCTION 0.5

const float handDepth = MC_HAND_DEPTH * 0.5 + 0.5;

float getDepth(vec2 pos){
	return texelFetch(depthtex0, ivec2(pos * vec2(viewWidth, viewHeight)), 0).r;
}

void binarySearch(inout vec3 rayPos, vec3 rayDir){
	vec3 lastGoodPos = rayPos; // stores the last position we know was inside, in case we accidentally step back out
	for (int i = 0; i < BINARY_REFINEMENTS; i++){
		float depth = getDepth(rayPos.xy);
		float intersect = sign(depth - rayPos.z);
		lastGoodPos = intersect == 1.0 && depth != 1.0 ? rayPos : lastGoodPos; // update last good pos if still inside
		
		rayPos += intersect * rayDir; // goes back if we're in geometry and forward if we're not
		rayDir *= BINARY_REDUCTION; // scale down the ray
	}
	rayPos = lastGoodPos;
}

// traces through screen space to find intersection point
// thanks, belmu!!
// https://gist.github.com/BelmuTM/af0fe99ee5aab386b149a53775fe94a3
bool rayIntersects(vec3 viewOrigin, vec3 viewDir, int maxSteps, float jitter, bool refine, out vec3 rayPos){

	if(viewDir.z > 0.0 && viewDir.z >= -viewOrigin.z){
		return false;
	}

	#if REFLECTION_MODE == 1
	rayPos = viewSpaceToScreenSpace(viewOrigin + 76.0 * viewDir);
	float rayDepth = getDepth(rayPos.xy);
	return clamp01(rayPos.xy) == rayPos.xy && rayDepth < 1.0 && length(screenSpaceToViewSpace(vec3(rayPos.xy, rayDepth))) > length(viewOrigin);

	#endif

	rayPos = viewSpaceToScreenSpace(viewOrigin);

	vec3 rayDir = viewSpaceToScreenSpace(viewOrigin + viewDir);
	
	rayDir -= rayPos;
	rayDir = normalize(rayDir);

    vec3 r = abs(sign(rayDir) - rayPos) / max(abs(rayDir), 0.00001);
	float rayLength = minVec3(r);
	float stepLength = rayLength * rcp(float(maxSteps));

	vec3 rayStep = rayDir * stepLength;
	rayPos += rayStep * jitter + length(vec2(rcp(viewWidth), rcp(viewHeight))) * rayDir;

	float depthLenience = max(abs(rayStep.z) * 3.0, 0.02 / pow2(viewOrigin.z)); // Provided by DrDesten

	bool intersect = false;

	for(int i = 0; i < maxSteps; ++i, rayPos += rayStep){
		if(clamp01(rayPos) != rayPos) return false; // we went offscreen

		vec3 rayPos2 = rayPos + rayStep * 0.25;
		vec3 rayPos3 = rayPos + rayStep * 0.5;
		vec3 rayPos4 = rayPos + rayStep * 0.75;

		float depth = getDepth(rayPos.xy); // sample depth at ray position
		float depth2 = getDepth(rayPos2.xy);
		float depth3 = getDepth(rayPos3.xy);
		float depth4 = getDepth(rayPos4.xy);

		if(depth < rayPos.z && abs(depthLenience - (rayPos.z - depth)) < depthLenience && rayPos.z > handDepth && depth < 1.0){
			intersect = true;
			break;
		}
		if(clamp01(rayPos2) != rayPos2) return false; // we went offscreen
		if(depth2 < rayPos2.z && abs(depthLenience - (rayPos2.z - depth2)) < depthLenience && rayPos2.z > handDepth && depth2 < 1.0){
			
			intersect = true;
			rayPos = rayPos2;
			break;
		}
		if(clamp01(rayPos3) != rayPos3) return false; // we went offscreen
		if(depth3 < rayPos3.z && abs(depthLenience - (rayPos3.z - depth3)) < depthLenience && rayPos3.z > handDepth && depth3 < 1.0){
			
			intersect = true;
			rayPos = rayPos3;
			break;
		}
		if(clamp01(rayPos4) != rayPos4) return false; // we went offscreen
		if(depth4 < rayPos4.z && abs(depthLenience - (rayPos4.z - depth4)) < depthLenience && rayPos4.z > handDepth && depth4 < 1.0){
			intersect = true;
			rayPos = rayPos4;
			break;
		}
	}

	if(clamp01(rayPos) != rayPos) return false; // we went offscreen

	if(refine && intersect){
		binarySearch(rayPos, rayStep);
	}

	return intersect;
}

#endif // SCREEN_SPACE_RAYTRACE_GLSL