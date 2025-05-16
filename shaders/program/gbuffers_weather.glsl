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
    out vec3 viewPos;

    void main() {
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        feetPlayerPos.xz += feetPlayerPos.y * 0.25;
        viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;

        gl_Position = gbufferProjection * vec4(viewPos, 1.0);
    }

#endif

// ===========================================================================================

#ifdef fsh
    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    in vec3 viewPos;

    /* RENDERTARGETS: 0,5 */
    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 rainMask;

    void main() {
        color = texture(gtexture, texcoord) * glcolor;

        if(color.a < alphaTestRef){
            discard;
        }

        if(color.r == color.g) { // snow
            rainMask = vec4(0.0);
            return;
        } else {
            color = vec4(0.0);
            rainMask = vec4(1.0);
        }

        rainMask = vec4(1.0);
    }

#endif