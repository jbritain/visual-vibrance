/*
Space conversions by Jessie-LC
https://github.com/Jessie-LC/open-source-utility-code/
*/

#ifndef SPACE_CONVERSIONS_GLSL
#define SPACE_CONVERSIONS_GLSL

vec3 screenSpaceToViewSpace(vec3 screenPosition) {
	screenPosition = screenPosition * 2.0 - 1.0;

	vec3 viewPosition  = vec3(vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * screenPosition.xy + gbufferProjectionInverse[3].xy, gbufferProjectionInverse[3].z);

  viewPosition /= gbufferProjectionInverse[2].w * screenPosition.z + gbufferProjectionInverse[3].w;

	return viewPosition;
}

float screenSpaceToViewSpace(float depth) {
	depth = depth * 2.0 - 1.0;
	return gbufferProjectionInverse[3].z / (gbufferProjectionInverse[2].w * depth + gbufferProjectionInverse[3].w);
}

vec3 viewSpaceToScreenSpace(vec3 viewPosition) {
	vec3 screenPosition  = vec3(gbufferProjection[0].x, gbufferProjection[1].y, gbufferProjection[2].z) * viewPosition + gbufferProjection[3].xyz;
	     screenPosition /= -viewPosition.z;

	return screenPosition * 0.5 + 0.5;
}

float viewSpaceToScreenSpace(float depth) {
	return ((gbufferProjection[2].z * depth + gbufferProjection[3].z) / -depth) * 0.5 + 0.5;
}

vec3 screenSpaceToViewSpace(vec3 screenPosition, mat4 projInv) {
	screenPosition = screenPosition * 2.0 - 1.0;

	vec3 viewPosition  = vec3(vec2(projInv[0].x, projInv[1].y) * screenPosition.xy + projInv[3].xy, projInv[3].z);

  viewPosition /= projInv[2].w * screenPosition.z + projInv[3].w;

	return viewPosition;
}

float screenSpaceToViewSpace(float depth, mat4 projInv) {
	depth = depth * 2.0 - 1.0;
	return projInv[3].z / (projInv[2].w * depth + projInv[3].w);
}

vec3 viewSpaceToScreenSpace(vec3 viewPosition, mat4 proj) {
	vec3 screenPosition  = vec3(proj[0].x, proj[1].y, proj[2].z) * viewPosition + proj[3].xyz;
	     screenPosition /= -viewPosition.z;

	return screenPosition * 0.5 + 0.5;
}

float viewSpaceToScreenSpace(float depth, mat4 proj) {
	return ((proj[2].z * depth + proj[3].z) / -depth) * 0.5 + 0.5;
}

#endif