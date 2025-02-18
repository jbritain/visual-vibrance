#ifndef BLOCK_LIGHT_COLORS_GLSL
#define BLOCK_LIGHT_COLORS_GLSL

// Colour values from Complementary by Emin
// https://github.com/ComplementaryDevelopment/ComplementaryReimagined/blob/3d69187a3569e08722e3aa85bb3131ac4ea04cca/shaders/lib/colors/blocklightColors.glsl

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

  if(materialIsRedstoneLightColor(ID)){
    return vec3(4.0, 0.3, 0.1) / 4.0;
  }

  if(materialIsPurpleFroglight(ID)){
    return vec3(160/255.0, 55/255.0, 183/255.0);
  }

  if(materialIsGreenFroglight(ID)){
    return vec3(95/255.0, 163/255.0, 52/255.0);
  }

  if(materialIsYellowFroglight(ID)){
    return vec3(242/255.0, 199/255.0, 70/255.0);
  }

  return vec3(0.0);
}

#endif // BLOCK_LIGHT_COLORS_GLSL