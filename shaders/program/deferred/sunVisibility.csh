


#include "/lib/shadowSpace.glsl"

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main(){
    if(frameCounter == 0){
        sunVisibilitySmooth = 0.0;
        return;
    }



    vec2 lightScreenPos = viewSpaceToScreenSpace(shadowLightPosition).xy;
    
    // isn't this some fun syntax
    float sunVisibility = float(texture(depthtex1, lightScreenPos).r == 1.0
    #ifdef DISTANT_HORIZONS
     && texture(dhDepthTex1, lightScreenPos).r == 1.0
    #endif
    );
    

    if(clamp01(lightScreenPos) != lightScreenPos){
        #ifdef SHADOWS
        vec4 shadowClipPos = getShadowClipPos(vec3(0.0));
        vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

        sunVisibility = shadow2D(shadowtex1HW, shadowScreenPos).r;
        #else
        sunVisibility = EB.y;
        #endif
    }


    sunVisibilitySmooth = mix(sunVisibility, sunVisibilitySmooth, clamp01(exp2(frameTime * -10.0)));
}