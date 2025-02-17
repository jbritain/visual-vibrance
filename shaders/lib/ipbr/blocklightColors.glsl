#ifndef BLOCK_LIGHT_COLORS_GLSL
#define BLOCK_LIGHT_COLORS_GLSL

// Colour values from Complementary by Emin
// https://github.com/ComplementaryDevelopment/ComplementaryReimagined/blob/3d69187a3569e08722e3aa85bb3131ac4ea04cca/shaders/lib/colors/blocklightColors.glsl

const vec3 fireColor = vec3(2.0, 0.87, 0.27) * 3.8;
const vec3 redstoneColor = vec3(4.0, 0.1, 0.1);
const vec3 soulFireColor = vec3(0.3, 2.0, 2.2);

vec3 getBlocklightColor(int ID){
  if(materialIsFireLightColor(ID)){
    return vec3(1.0, 0.5, 0.1);
  }

  if(materialIsTorchLightColor(ID)){
    return vec3(1.0, 0.3, 0.0);
  }

  if(materialIsSoulFireLightColor(ID)){
    return vec3(0.3, 2.0, 2.2) / 2.2;
  }

  return vec3(0.0);
}

#endif // BLOCK_LIGHT_COLORS_GLSL