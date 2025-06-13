/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under a custom non-commercial license.
    See LICENSE for full terms.

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

out vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef fsh
in vec2 texcoord;

#include "/lib/util/spheremap.glsl"
#include "/lib/atmosphere/sky/sky.glsl"
#include "/lib/atmosphere/clouds.glsl"

/* RENDERTARGETS: 7 */
layout(location = 0) out vec3 color;

void main() {
    vec3 dir = mat3(gbufferModelViewInverse) * unmapSphere(texcoord);

    color = getSky(vec3(0.0), dir, false);
    vec3 transmittance;
    vec3 scatter = getClouds(vec3(0.0), dir * 1000.0, transmittance, 1.0);
    color = color * transmittance + scatter;
}
#endif
