/*
    Copyright (c) 2024 Josh Britain (jbritain)
    All rights reserved

 __   __ __   ______   __  __   ______   __           __   __ __   ______   ______   ______   __   __   ______   ______    
/\ \ / //\ \ /\  ___\ /\ \/\ \ /\  __ \ /\ \         /\ \ / //\ \ /\  == \ /\  == \ /\  __ \ /\ "-.\ \ /\  ___\ /\  ___\   
\ \ \'/ \ \ \\ \___  \\ \ \_\ \\ \  __ \\ \ \____    \ \ \'/ \ \ \\ \  __< \ \  __< \ \  __ \\ \ \-.  \\ \ \____\ \  __\   
 \ \__|  \ \_\\/\_____\\ \_____\\ \_\ \_\\ \_____\    \ \__|  \ \_\\ \_____\\ \_\ \_\\ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\ 
  \/_/    \/_/ \/_____/ \/_____/ \/_/\/_/ \/_____/     \/_/    \/_/ \/_____/ \/_/ /_/ \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/ 
                                                                                                                           
    
    By jbritain
    https://jbritain.net
                                            
*/

#include "/lib/common.glsl"

#ifdef vsh

    in vec2 mc_Entity;
    in vec4 at_tangent;

    out vec2 lmcoord;
    out vec2 texcoord;
    out vec4 glcolor;
    flat out int materialID;
    out vec3 viewPos;
    out vec3 normal;

    void main() {
        materialID = int(mc_Entity.x + 0.5);
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        normal = gl_NormalMatrix * gl_Normal;

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
        viewPos += normal * 1e-3; // z fighting fix

        gl_Position = gbufferProjection * vec4(viewPos, 1.0);
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/util/packing.glsl"

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    flat in int materialID;
    in vec3 viewPos;
    in vec3 normal;

    /* RENDERTARGETS: 0,1 */
    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 outData1;

    void main() {
        color = texture(gtexture, texcoord) * glcolor;
        if(color.a < alphaTestRef){
            discard;
        }
        color.rgb = pow(color.rgb, vec3(2.2));

        color.rgb *= 50.0;
        #ifdef REALLY_FUCKING_GLOWING
        color.rgb *= 20.0;
        #endif

        outData1.xy = encodeNormal(mat3(gbufferModelViewInverse) * normal);
        outData1.z = 0.0;
        outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));
    }

#endif