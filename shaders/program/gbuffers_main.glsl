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
    #include "/lib/sway.glsl"
    #include "/lib/water/waveNormals.glsl"

    in vec2 mc_Entity;
    in vec4 at_tangent;
    in vec4 at_midBlock;
    in vec2 mc_midTexCoord;

    out vec2 lmcoord;
    out vec2 texcoord;
    out vec4 glcolor;
    out mat3 tbnMatrix;
    flat out int materialID;
    out vec3 viewPos;
    out float emission;
    out vec3 midblock;
    out vec2 midtexcoord;

    flat out vec2 singleTexSize;
    flat out ivec2 pixelTexSize;
    flat out vec4 textureBounds;

    void main() {
        materialID = int(mc_Entity.x + 0.5);
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        emission = at_midBlock.w / 15.0;

        tbnMatrix[0] = normalize(gl_NormalMatrix * at_tangent.xyz);
        tbnMatrix[2] = normalize(gl_NormalMatrix * gl_Normal);
        tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * at_tangent.w);

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

        if(renderStage == MC_RENDER_STAGE_HAND_SOLID || renderStage == MC_RENDER_STAGE_HAND_TRANSLUCENT){
            gl_Position = ftransform();
            return;
        }

        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

        #ifdef WAVING_BLOCKS
        feetPlayerPos = getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock.xyz) - cameraPosition;
        #endif

        #if WAVE_MODE == 2
        if(materialIsWater(materialID)){
            feetPlayerPos.y += (waveHeight(feetPlayerPos.xz + cameraPosition.xz) - 0.5) * fract(feetPlayerPos.y + cameraPosition.y);
        }
        #endif

        viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;

        vec2 halfSize      = abs(texcoord - mc_midTexCoord);
        textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);

        singleTexSize = halfSize * 2.0;
        pixelTexSize  = ivec2(singleTexSize * atlasSize);

        gl_Position = gbufferProjection * vec4(viewPos, 1.0);

        midblock = at_midBlock.xyz;
        midtexcoord = mc_midTexCoord.xy;
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/lighting/shading.glsl"
    #include "/lib/util/packing.glsl"
    #include "/lib/lighting/directionalLightmap.glsl"
    #include "/lib/voxel/voxelMap.glsl"
    #include "/lib/voxel/voxelData.glsl"
    #include "/lib/ipbr/blocklightColors.glsl"
    #include "/lib/dhBlend.glsl"

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    in mat3 tbnMatrix;
    flat in int materialID;
    in vec3 viewPos;
    in float emission;
    in vec3 midblock;
    in vec2 midtexcoord;

    flat in vec2 singleTexSize;
    flat in ivec2 pixelTexSize;
    flat in vec4 textureBounds;

    #include "/lib/parallax.glsl"

    vec3 getMappedNormal(vec2 texcoord, int materialID){
        #if PBR_MODE == 0
        return tbnMatrix[2];
        #endif

        vec3 mappedNormal = materialIsWater(materialID) ? textureLod(normals, texcoord, 0).rgb : texture(normals, texcoord).rgb;
        mappedNormal = mappedNormal * 2.0 - 1.0;
        mappedNormal.z = sqrt(1.0 - dot(mappedNormal.xy, mappedNormal.xy)); // reconstruct z due to labPBR encoding

        return tbnMatrix * mappedNormal;
    }

    /* RENDERTARGETS: 0,1 */

    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 outData1;

    void main() {
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

        float parallaxShadow = 1.0;
        vec2 dx = dFdx(texcoord);
        vec2 dy = dFdy(texcoord);

        #ifdef PARALLAX
        vec3 parallaxPos;
        vec2 texcoord = texcoord;
        if(
            !materialIsLava(materialID) &&
            (
                renderStage == MC_RENDER_STAGE_TERRAIN_SOLID ||
                renderStage ==  MC_RENDER_STAGE_ENTITIES ||
                renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT
            )
        ){
            texcoord = getParallaxTexcoord(texcoord, viewPos, tbnMatrix, parallaxPos, dx, dy, 0.0);

            #ifdef PARALLAX_SHADOW
            float pomJitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
            parallaxShadow = getParallaxShadow(parallaxPos, tbnMatrix, dx, dy, pomJitter, viewPos);
            #endif
        }
        #endif

        vec2 lightmap = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);

        #ifdef WORLD_THE_END
        lightmap.y = 1.0;
        #endif




        vec4 albedo = texture(gtexture, texcoord) * glcolor;

        if (albedo.a < alphaTestRef) {
            discard;
        }

        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

        albedo.rgb = pow(albedo.rgb, vec3(2.2));

        #ifdef PATCHY_LAVA
            if(materialIsLava(materialID)){
                vec3 worldPos = feetPlayerPos + cameraPosition;
                float noise = texture(perlinNoiseTex, mod(worldPos.xz / 100 + vec2(0.0, frameTimeCounter * 0.005), 1.0)).r;
                noise *= texture(perlinNoiseTex, mod(worldPos.xz / 200 + vec2(frameTimeCounter * 0.005, 0.0), 1.0)).r;
                albedo.rgb *= noise;
                albedo.rgb *= 4.0;
            }
        #endif

        vec3 mappedNormal = getMappedNormal(texcoord, materialID);
        if(renderStage == MC_RENDER_STAGE_ENTITIES){
            vec3 mappedNormal = texture(normals, texcoord).rgb;
        }

        #if PBR_MODE == 0
        vec4 specularData = vec4(0.0);
        #else
        vec4 specularData = texture(specular, texcoord);
        #endif
        Material material = materialFromSpecularMap(albedo.rgb, specularData, materialID);
        material.ao = texture(normals, texcoord).z;
        #ifndef MC_TEXTURE_FORMAT_LAB_PBR
            if(material.emission == 0.0 && emission > 0.0 && (renderStage == MC_RENDER_STAGE_TERRAIN_SOLID || renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT)){
                material.emission = luminance(albedo.rgb);
            }

        #endif

        #ifdef GBUFFERS_ARMOR_GLINT
        material.emission = 1.0;
        #endif




        if(materialIsWater(materialID)){
            #if WAVE_MODE == 1
            // sample texture 1 pixel in each direction to determine normal
            // using the luminance as a heightmap

            float inversePixelSize = rcp(PIXEL_SIZE);

            vec3 xPosMinus = vec3(-inversePixelSize, 0.0, 0.0);
            vec3 xPosPlus = vec3(inversePixelSize, 0.0, 0.0);

            vec3 yPosMinus = vec3(0.0, -inversePixelSize, 0.0);
            vec3 yPosPlus = vec3(0.0, inversePixelSize, 0.0);

            vec2 localCoord = atlasToLocal(texcoord);

            xPosMinus.z = luminance(pow(textureGrad(gtexture, localToAtlas(localCoord + xPosMinus.xy), dx, dy).rgb, vec3(2.2))) * (WATER_HEIGHTMAP_HEIGHT) + (0.5 - WATER_HEIGHTMAP_HEIGHT * 0.5);
            xPosPlus.z = luminance(pow(textureGrad(gtexture, localToAtlas(localCoord + xPosPlus.xy), dx, dy).rgb, vec3(2.2))) * (WATER_HEIGHTMAP_HEIGHT) + (0.5 - WATER_HEIGHTMAP_HEIGHT * 0.5);

            yPosMinus.z = luminance(pow(textureGrad(gtexture, localToAtlas(localCoord + yPosMinus.xy), dx, dy).rgb, vec3(2.2))) * (WATER_HEIGHTMAP_HEIGHT) + (0.5 - WATER_HEIGHTMAP_HEIGHT * 0.5);
            yPosPlus.z = luminance(pow(textureGrad(gtexture, localToAtlas(localCoord + yPosPlus.xy), dx, dy).rgb, vec3(2.2))) * (WATER_HEIGHTMAP_HEIGHT) + (0.5 - WATER_HEIGHTMAP_HEIGHT * 0.5);

            vec3 xDir = normalize(xPosPlus - xPosMinus);
            vec3 yDir = normalize(yPosPlus - yPosMinus);

            mappedNormal = tbnMatrix * cross(xDir, yDir);
            #endif
            material.roughness = 0.0;
        }

        if(materialIsMaxEmission(materialID)){
            material.emission = 1.0;
        }

        #ifdef DIRECTIONAL_LIGHTMAPS
        applyDirectionalLightmap(lightmap, viewPos, mappedNormal, tbnMatrix, material.sss);
        #endif

        #if defined DYNAMIC_HANDLIGHT && !defined FLOODFILL
            float dist = length(feetPlayerPos);
            float falloff = (1.0 - clamp01(smoothstep(0.0, 15.0, dist))) * max(heldBlockLightValue, heldBlockLightValue2) / 15.0;

            #ifdef DIRECTIONAL_LIGHTMAPS
                falloff *= mix(dot(normalize(-viewPos), mappedNormal), 1.0, material.sss * 0.25 + 0.75);
            #endif

            lightmap.x = max(lightmap.x, falloff);

            // #ifdef GBUFFERS_HAND
            // atomicMax(encodedHeldLightColor, floatBitsToUint(pack4x8F(vec4(hsv(albedo.rgb).gbr, 0.0))));
            // #endif
        #endif

        #ifdef RAIN_PUDDLES
        float rainFactor = clamp01(smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y)) * wetness;

        rainFactor *= smoothstep(0.6, 0.7, texture(noisetex, mod((feetPlayerPos.xz + cameraPosition.xz) / 2.0, 64.0) / 64.0).r);

        material.f0 = mix(material.f0, vec3(0.02), rainFactor * (1.0 - material.porosity));
        material.roughness = mix(material.roughness, 0.0, rainFactor * (1.0 - material.porosity) * 0.8);
        material.albedo *= (1.0 - 0.5 * rainFactor * material.porosity);
        #endif

        parallaxShadow = mix(parallaxShadow, 1.0, material.sss * 0.5);

        if(materialIsWater(materialID)){
            color.rgb = material.albedo;
            color.a = 0.0;

        }  else {
            bool sampleColoredLight = false;

            #ifdef PIXEL_LOCKED_LIGHTING
                feetPlayerPos += cameraPosition;
                feetPlayerPos = floor(feetPlayerPos * PIXEL_SIZE) / PIXEL_SIZE;
                feetPlayerPos -= cameraPosition;

                vec3 viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
            #endif

            #ifdef FLOODFILL


                #ifdef DIRECTIONAL_LIGHTMAPS
                    vec3 offset = -mat3(gbufferModelViewInverse) * tbnMatrix[2] * 0.5 + mat3(gbufferModelViewInverse) * mappedNormal;
                    offset = mix(offset, vec3(0.0), material.sss * 0.25);
                    vec3 voxelPosInterp = mapVoxelPosInterp(feetPlayerPos + offset);
                #else
                    vec3 voxelPosInterp = mapVoxelPosInterp(feetPlayerPos + mat3(gbufferModelViewInverse) * tbnMatrix[2] * 0.5);
                #endif
            sampleColoredLight = clamp01(voxelPosInterp) == voxelPosInterp;
            #endif

            if(sampleColoredLight){
                #ifdef FLOODFILL
                    vec3 blocklightColor;
                    if(frameCounter % 2 == 0){
                        blocklightColor = texture(floodfillVoxelMapTex2, voxelPosInterp).rgb;
                    } else {
                        blocklightColor = texture(floodfillVoxelMapTex1, voxelPosInterp).rgb;
                    }

                    if(luminance(blocklightColor) < 0.2 && lightmap.x > 0.5 && renderStage == MC_RENDER_STAGE_PARTICLES){
                        material.emission = lightmap.x;
                    }

                    #ifdef DYNAMIC_HANDLIGHT
                        float dist = length(feetPlayerPos);
                        float falloff = (1.0 - clamp01(smoothstep(0.0, 15.0, dist))) * max(heldBlockLightValue, heldBlockLightValue2) / 15.0;

                        #ifdef DIRECTIONAL_LIGHTMAPS
                            falloff *= mix(dot(normalize(-viewPos), mappedNormal), 1.0, material.sss * 0.25 + 0.75);
                        #endif

                        blocklightColor += pow(vec3(255, 152, 54), vec3(2.2)) * 1e-8 * max0(exp(-(1.0 - falloff * 10.0)));
                    #endif

                    color.rgb = getShadedColor(material, mappedNormal, tbnMatrix[2], blocklightColor, lightmap, viewPos, parallaxShadow);
                #endif
            } else {
                color.rgb = getShadedColor(material, mappedNormal, tbnMatrix[2], lightmap, viewPos, parallaxShadow);
            }


            color.a = albedo.a;
        }

        blendAtEdge(viewPos, far, midblock);

        outData1.xy = encodeNormal(mat3(gbufferModelViewInverse) * mappedNormal);
        outData1.z = lightmap.y;
        outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));
    }

#endif
