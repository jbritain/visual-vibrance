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

// ===========================================================================================

#ifdef fsh
in vec2 texcoord;

#include "/lib/dh.glsl"
#include "/lib/shadowSpace.glsl"
#include "/lib/atmosphere/clouds.glsl"

/* RENDERTARGETS: 4 */
layout(location = 0) out vec3 scattering;

void main() {
  scattering = vec3(0.0);

  #if GODRAYS == 1
  vec2 sampleCoord = texcoord;

  if (lightDir.z > 0.0) {
    // not facing sun
    float facingFactor = dot(vec3(0.0, -1.0, 0.0), lightDir);
    scattering = vec3(facingFactor);
    return;
  }

  vec3 sunScreenPos = viewSpaceToScreenSpace(shadowLightPosition);

  sunScreenPos.xy = clamp(sunScreenPos.xy, vec2(-0.5), vec2(1.5));

  vec2 deltaTexcoord = texcoord - sunScreenPos.xy;

  deltaTexcoord *= rcp(GODRAYS_SAMPLES) * GODRAYS_DENSITY;

  float decay = 1.0;

  sampleCoord -=
    deltaTexcoord *
    interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  for (int i = 0; i < GODRAYS_SAMPLES; i++) {
    vec3 scatterSample = texture(colortex4, sampleCoord).rgb;

    scatterSample *= decay * GODRAYS_WEIGHT;
    scattering += scatterSample;
    decay *= GODRAYS_DECAY;
    sampleCoord -= deltaTexcoord;

    if (clamp01(sampleCoord) != sampleCoord) {
      break;
    }
  }

  scattering /= GODRAYS_SAMPLES;
  scattering *= GODRAYS_EXPOSURE;
  #elif GODRAYS == 2 && defined SHADOWS

  float depth = texture(depthtex0, texcoord).r;
  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  #ifdef PIXEL_LOCKED_LIGHTING
  viewPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz + cameraPosition;
  viewPos = floor(viewPos * PIXEL_SIZE) / PIXEL_SIZE;
  viewPos = (gbufferModelView * vec4(viewPos - cameraPosition, 1.0)).xyz;
  #endif

  if (depth == 1.0) {
    viewPos = normalize(viewPos) * shadowDistance;
  }

  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

  vec3 a = vec3(0.0);
  vec3 b = feetPlayerPos;

  vec3 aShadow = getShadowClipPos(a).xyz;
  vec3 bShadow = getShadowClipPos(b).xyz;

  vec3 sampleDelta = (b - a) * rcp(GODRAYS_SAMPLES);
  vec3 samplePos = a;

  vec3 sampleDeltaShadow = (bShadow - aShadow) * rcp(GODRAYS_SAMPLES);
  vec3 samplePosShadow = aShadow;

  float noise = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
  samplePos += sampleDelta * noise;
  samplePosShadow += sampleDeltaShadow * noise;

  for (int i = 0; i < GODRAYS_SAMPLES; i++) {
    vec3 screenSamplePos = getShadowScreenPos(vec4(samplePosShadow, 1.0));

    if (clamp01(screenSamplePos) != screenSamplePos) {
      break;
    }

    vec3 cloudShadow = vec3(1.0);
    #ifdef CLOUD_SHADOWS
    cloudShadow = getCloudShadow(feetPlayerPos);
    cloudShadow = pow3(cloudShadow);
    #endif
    scattering += vec3(shadow2D(shadowtex0HW, screenSamplePos).r) * cloudShadow;

    samplePos += sampleDelta;
    samplePosShadow += sampleDeltaShadow;
  }

  scattering /= GODRAYS_SAMPLES;
  scattering *= distance(a, b);
  scattering /= shadowDistance / 2.0;
  scattering = pow2(scattering);
  #endif

  show(scattering);

}

#endif
