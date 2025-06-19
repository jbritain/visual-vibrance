#ifndef VOXEL_DATA_GLSL
#define VOXEL_DATA_GLSL

struct VoxelData {
  float emission; // 4 bits
  float opacity; // 4 bits
  vec3 color; // 12 bits
};

uint encodeVoxelData(VoxelData data) {
  uint encodedData = 0;

  encodedData = bitfieldInsert(
    encodedData,
    uint(clamp01(data.emission) * 15.0),
    0,
    4
  );
  encodedData = bitfieldInsert(
    encodedData,
    uint(clamp01(data.opacity) * 15.0),
    4,
    4
  );

  vec3 encodedColor = hsv(data.color).rbg;

  encodedData = bitfieldInsert(
    encodedData,
    uint(clamp01(encodedColor.r) * 255.0),
    8,
    8
  );
  encodedData = bitfieldInsert(
    encodedData,
    uint(clamp01(encodedColor.g) * 255.0),
    16,
    8
  );
  encodedData = bitfieldInsert(
    encodedData,
    uint(clamp01(encodedColor.b) * 255.0),
    24,
    8
  );

  return encodedData;
}

VoxelData decodeVoxelData(uint encodedData) {
  VoxelData data;

  data.emission = float(uint(bitfieldExtract(encodedData, 0, 4))) / 15.0;
  data.opacity = float(bitfieldExtract(encodedData, 4, 4)) / 15.0;

  vec3 encodedColor;

  encodedColor.r = float(bitfieldExtract(encodedData, 8, 8)) / 255.0;
  encodedColor.g = float(bitfieldExtract(encodedData, 16, 8)) / 255.0;
  encodedColor.b = float(bitfieldExtract(encodedData, 24, 8)) / 255.0;

  data.color = rgb(encodedColor.rbg);

  return data;
}

#endif // VOXEL_DATA_GLSL
