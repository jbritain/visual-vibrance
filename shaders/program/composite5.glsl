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

#include "/lib/common.glsl"

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main(){
    if(frameCounter == 0){
        sunVisibilitySmooth = 0.0;
        return;
    }

    vec2 lightScreenPos = viewSpaceToScreenSpace(shadowLightPosition).xy;
    float sunVisibility = 1.0 - float(clamp01(lightScreenPos) != lightScreenPos || texture(depthtex0, lightScreenPos).r < 1.0);

    sunVisibilitySmooth = mix(sunVisibility, sunVisibilitySmooth, clamp01(exp2(frameTime * -1.0)));
}

#endif

#ifdef vsh

    out vec2 texcoord;

    void main() {
        gl_Position = ftransform();
	    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/atmosphere/sky/sky.glsl"
    #include "/lib/atmosphere/fog.glsl"

    in vec2 texcoord;

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        float depth = texture(depthtex0, texcoord).r;
        if(isEyeInWater == 1){
            return;
        }

        vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

        color.rgb = defaultFog(color.rgb, viewPos);

        #ifdef WORLD_OVERWORLD
        #ifdef ATMOSPHERIC_FOG
        if(depth != 1.0) color.rgb = atmosphericFog(color.rgb, viewPos);
        #endif
        #ifdef CLOUDY_FOG
        color.rgb = cloudyFog(color.rgb, mat3(gbufferModelViewInverse) * viewPos, depth);
        #endif
        #endif
        
        
        
    }

#endif