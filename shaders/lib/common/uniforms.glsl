#ifndef UNIFORMS_GLSL
#define UNIFORMS_GLSL

// uniform list from Complementary
// https://github.com/ComplementaryDevelopment/ComplementaryReimagined/blob/main/shaders/lib/uniforms.glsl

/*----------------------------------------------------------------------------------------------
        _____                                                                    _____
        ( ___ )                                                                  ( ___ )
        |   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|   |
        |   | ██╗   ██╗███╗   ██╗██╗███████╗ ██████╗ ██████╗ ███╗   ███╗███████╗ |   |
        |   | ██║   ██║████╗  ██║██║██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔════╝ |   |
        |   | ██║   ██║██╔██╗ ██║██║█████╗  ██║   ██║██████╔╝██╔████╔██║███████╗ |   |
        |   | ██║   ██║██║╚██╗██║██║██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║╚════██║ |   |
        |   | ╚██████╔╝██║ ╚████║██║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████║ |   |
        |   |  ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ |   |
        |___|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___|
        (_____)                              (thanks to isuewo and SpacEagle17)  (_____)

---------------------------------------------------------------------------------------------*/

uniform float alphaTestRef;

uniform int blockEntityId;
uniform int currentRenderedItemId;
uniform int entityId;
uniform int frameCounter;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform int heldItemId;
uniform int heldItemId2;
uniform int isEyeInWater;
uniform int moonPhase;
uniform int worldTime;
uniform int worldDay;
uniform int renderStage;

uniform float aspectRatio;
uniform float blindness;
uniform float darknessFactor;
uniform float darknessLightFactor;
uniform float maxBlindnessDarkness;
uniform float eyeAltitude;
uniform float frameTime;

#ifdef FREEZE_TIME
const float frameTimeCounter = 0.0;
#else
uniform float frameTimeCounter;
#endif

uniform float far;
uniform float near;
uniform float nightVision;
uniform float rainStrength;
uniform float thunderStrength;
uniform float screenBrightness;
uniform float viewHeight;
uniform float viewWidth;
vec2 resolution = vec2(viewWidth, viewHeight);
uniform float wetness;
uniform float sunAngle;
uniform float playerMood;
uniform float constantMood;

uniform ivec2 atlasSize;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;

vec2 EB = vec2(eyeBrightness) / 240.0;
vec2 EBS = vec2(eyeBrightnessSmooth) / 240.0;

uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform vec3 relativeEyePosition;

uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;

uniform vec4 entityColor;
uniform vec4 lightningBoltPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D colortex13;
uniform sampler2D colortex14;
uniform sampler2D colortex15;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D normals;
uniform sampler2D noisetex;
uniform sampler2D specular;
uniform sampler2D gtexture;
uniform sampler2D lightmap;

uniform ivec3 cameraPositionInt;
uniform ivec3 previousCameraPositionInt;
uniform vec3 cameraPositionFract;
uniform vec3 previousCameraPositionFract;

uniform sampler2D shadowtex1;
uniform sampler2D shadowtex0;
uniform sampler2DShadow shadowtex1HW;
uniform sampler2DShadow shadowtex0HW;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D sunTransmittanceLUTTex;
uniform sampler2D multipleScatteringLUTTex;
uniform sampler2D skyViewLUTTex;

uniform sampler2D perlinNoiseTex;
uniform sampler2D blueNoiseTex;
uniform sampler2D turbulentNoiseTex;
uniform sampler2D vanillaCloudTex;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
    uniform float dhFarPlane;

    uniform mat4 dhProjection;
    uniform mat4 dhProjectionInverse;
    
    uniform sampler2D dhDepthTex0;
    uniform sampler2D dhDepthTex1;

    
    uniform vec4 combinedProjection0;
    uniform vec4 combinedProjection1;
    uniform vec4 combinedProjection2;
    uniform vec4 combinedProjection3;
    #define combinedProjection mat4(combinedProjection0, combinedProjection1, combinedProjection2, combinedProjection3)

    uniform vec4 combinedProjectionInverse0;
    uniform vec4 combinedProjectionInverse1;
    uniform vec4 combinedProjectionInverse2;
    uniform vec4 combinedProjectionInverse3;
    #define combinedProjectionInverse mat4(combinedProjectionInverse0, combinedProjectionInverse1, combinedProjectionInverse2, combinedProjectionInverse3)

#endif

#ifdef FLOODFILL
uniform usampler3D voxelMapTex;
uniform sampler3D floodfillVoxelMapTex1;
uniform sampler3D floodfillVoxelMapTex2;
#endif

#endif // UNIFORMS_GLSL