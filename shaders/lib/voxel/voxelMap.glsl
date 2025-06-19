#ifndef VOXEL_MAP_GLSL
#define VOXEL_MAP_GLSL

// takes in a player space position and returns a position in the voxel map
ivec3 mapVoxelPos(vec3 playerPos) {
  return ivec3(
    floor(playerPos + cameraPositionFract) + ivec3(VOXEL_MAP_SIZE / 2)
  );
}

bool isWithinVoxelBounds(ivec3 voxelPos) {
  return all(greaterThanEqual(voxelPos, ivec3(0))) &&
  all(lessThan(voxelPos, ivec3(VOXEL_MAP_SIZE)));
}

// for sampling the voxel texture as a sampler3D so we get interpolation
vec3 mapVoxelPosInterp(vec3 playerPos) {
  return (playerPos + cameraPositionFract + VOXEL_MAP_SIZE / 2) /
  VOXEL_MAP_SIZE;
}

ivec3 getPreviousVoxelOffset() {
  return ivec3(floor(cameraPosition) - floor(previousCameraPosition));
}

#endif // VOXEL_MAP_GLSL
