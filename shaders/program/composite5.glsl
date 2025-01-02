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
#include "/lib/shadowSpace.glsl"

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main(){
    if(frameCounter == 0){
        sunVisibilitySmooth = 0.0;
        return;
    }



    vec2 lightScreenPos = viewSpaceToScreenSpace(shadowLightPosition).xy;
    
    // isn't this some fun syntax
    float sunVisibility = float(texture(depthtex0, lightScreenPos).r == 1.0
    #ifdef DISTANT_HORIZONS
     && texture(dhDepthTex0, lightScreenPos).r == 1.0
    #endif
    );
    

    if(clamp01(lightScreenPos) != lightScreenPos){
        #ifdef SHADOWS
        vec4 shadowClipPos = getShadowClipPos(vec3(0.0));
        vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

        sunVisibility = shadow2D(shadowtex0HW, shadowScreenPos).r;
        #else
        sunVisibility = EB.y;
        #endif
    }


    sunVisibilitySmooth = mix(sunVisibility, sunVisibilitySmooth, clamp01(exp2(frameTime * -10.0)));
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

    #include "/lib/dh.glsl"

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        color = texture(colortex0, texcoord);
        float depth = texture(depthtex0, texcoord).r;
        vec4 data1 = texture(colortex1, texcoord);
        int materialID = int(data1.a * 255 + 0.5) + 1000;
        bool isWater = materialID == MATERIAL_WATER;
        if(isEyeInWater == 1){
            return;
        }

        vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
        dhOverride(depth, viewPos, false);

        #if defined INFINITE_OCEAN && defined WORLD_OVERWORLD
        if(depth == 1.0 && cameraPosition.y > 63.0){
            vec3 feetPlayerPos;
            if(rayPlaneIntersection(vec3(0.0, 0.0, 0.0), normalize(mat3(gbufferModelViewInverse) * viewPos), 63.0 - cameraPosition.y, feetPlayerPos)){
                viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
                depth = 0.5;
                isWater = true;
            }
        }
        #endif

        color.rgb = defaultFog(color.rgb, viewPos);

        #ifdef WORLD_OVERWORLD
        #ifdef ATMOSPHERIC_FOG
        if(depth != 1.0 && !isWater) color.rgb = atmosphericFog(color.rgb, viewPos);
        #endif
        #ifdef CLOUDY_FOG
        color.rgb = cloudyFog(color.rgb, mat3(gbufferModelViewInverse) * viewPos, depth);
        #endif
        #endif
        
        
        
    }

#endif