#version 430 compatibility
#include "/lib/common.glsl"

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
#define WORLD_OVERWORLD
#define TILE_INDEX 1



in vec2 texcoord;

#include "/lib/post/bloom.glsl"

/* RENDERTARGETS: 2 */
layout(location = 0) out vec4 bloomColor;

void main() {
	BloomTile tile = tiles[TILE_INDEX];
	bloomColor = vec4(0.0, 0.0, 0.0, 1.0);
	#if TILE_INDEX > 0
	BloomTile nextTile = tiles[max(0, TILE_INDEX - 1)];
	vec2 tileCoord = scaleToBloomTile(texcoord, nextTile);

	bloomColor = texture(colortex2, texcoord);

	if(clamp01(tileCoord) != tileCoord){
		return;
	}

	tileCoord = scaleFromBloomTile(tileCoord, tile);
	// bloomColor.rgb = vec3(tileCoord.xy, 0.0);
	#else
	vec2 tileCoord = texcoord / 2;
	#endif
	bloomColor.rgb += upSample(colortex2, tileCoord);	
}
