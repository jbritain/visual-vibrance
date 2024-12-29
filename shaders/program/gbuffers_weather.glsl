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
        feetPlayerPos.zy = rotate(feetPlayerPos.zy, 0.3);
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

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        discard;
    }

#endif