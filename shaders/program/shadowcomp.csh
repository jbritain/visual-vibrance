
layout (local_size_x = 4, local_size_y = 4, local_size_z = 4) in;

#include "/lib/common.glsl"
#include "/lib/voxel/voxelMap.glsl"
#include "/lib/voxel/voxelData.glsl"

const ivec3 workGroups = ivec3(64, 32, 64); // 4 * 64 = 256

layout (rgba16f) uniform image3D floodfillVoxelMap1;
layout (rgba16f) uniform image3D floodfillVoxelMap2;
layout(r32ui) uniform uimage3D voxelMap;

vec3 gatherLight(ivec3 voxelPos){
  const ivec3[6] sampleOffsets = ivec3[6](
    ivec3( 0, -1,  0), // DOWN
    ivec3( 0,  1,  0), // UP
    ivec3( 0,  0, -1), // NORTH
    ivec3( 0,  0,  1), // SOUTH
    ivec3(-1,  0,  0), // WEST
    ivec3( 1,  0,  0)  // EAST
  );

  vec3 light = vec3(0.0);


  for(int i = 0; i < 6; i++){
    ivec3 offsetPos = voxelPos + sampleOffsets[i] + getPreviousVoxelOffset();

    VoxelData sampleData = decodeVoxelData(imageLoad(voxelMap, offsetPos).r);

    // if(sampleData.opacity == 1.0){
    //   continue;
    // }

    if(frameCounter % 2 == 0){
      light += imageLoad(floodfillVoxelMap1, offsetPos).rgb ;
    } else {
      light += imageLoad(floodfillVoxelMap2, offsetPos).rgb;
    }
  }

  light /= 6.0;
  light *= 0.99;

  return light;
}

void main(){
  ivec3 pos = ivec3(gl_GlobalInvocationID);
  VoxelData data = decodeVoxelData(imageLoad(voxelMap, pos).r);

  vec3 indirect = data.opacity < 1.0 ? gatherLight(pos) : vec3(0.0);
  vec3 emitted = data.color * data.emission * 32.0;

  if(pos == mapVoxelPos(vec3(0.0))){
    emitted = max(emitted, vec3(heldBlockLightValue * 16.0));
  }

  // tint
  if(data.opacity < 1.0){
    indirect *= (data.color * (data.opacity) + (1.0 - data.opacity));
  }

  vec3 color = emitted + indirect;

  if(frameCounter % 2 == 0){
    imageStore(floodfillVoxelMap2, pos, vec4(color, 1.0));
  } else {
    imageStore(floodfillVoxelMap1, pos, vec4(color, 1.0));
  }
}