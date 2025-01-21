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
    #include "/lib/sway.glsl"

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

    #ifdef PARALLAX
        flat out vec2 singleTexSize;
        flat out ivec2 pixelTexSize;
        flat out vec4 textureBounds;
    #endif

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

        #ifdef GBUFFERS_HAND
        gl_Position = ftransform();
        return;
        #endif

        #ifdef WAVING_BLOCKS
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        feetPlayerPos = getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock.xyz) - cameraPosition;
        viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
        #endif

        #ifdef PARALLAX
            vec2 halfSize      = abs(texcoord - mc_midTexCoord);
            textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);

            singleTexSize = halfSize * 2.0;
            pixelTexSize  = ivec2(singleTexSize * atlasSize);
        #endif

        gl_Position = gbufferProjection * vec4(viewPos, 1.0);
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/lighting/shading.glsl"
    #include "/lib/util/packing.glsl"
    #include "/lib/lighting/directionalLightmap.glsl"

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    in mat3 tbnMatrix;
    flat in int materialID;
    in vec3 viewPos;
    in float emission;

    #ifdef PARALLAX
        flat in vec2 singleTexSize;
        flat in ivec2 pixelTexSize;
        flat in vec4 textureBounds;
        #include "/lib/parallax.glsl"
    #endif

    vec3 getMappedNormal(vec2 texcoord){
        vec3 mappedNormal = texture(normals, texcoord).rgb;
        mappedNormal = mappedNormal * 2.0 - 1.0;
        mappedNormal.z = sqrt(1.0 - dot(mappedNormal.xy, mappedNormal.xy)); // reconstruct z due to labPBR encoding
        
        return tbnMatrix * mappedNormal;
    }

    #ifdef GODRAYS
    /* RENDERTARGETS: 0,1,4 */
    #else
    /* RENDERTARGETS: 0,1,4 */
    #endif

    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 outData1;

    #ifdef GODRAYS
    layout(location = 2) out vec4 sunOcclusion;
    #endif

    void main() {

        float parallaxShadow = 1.0;
        #ifdef PARALLAX
        vec3 parallaxPos;
        vec2 dx = dFdx(texcoord);
        vec2 dy = dFdy(texcoord);
        vec2 texcoord = texcoord;
        if(
            materialID != MATERIAL_LAVA &&
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

        #ifdef DYNAMIC_HANDLIGHT
            vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
            float dist = length(playerPos);
            lightmap.x = max(lightmap.x, (1.0 - clamp01(smoothstep(0.0, 15.0, dist))) * max(heldBlockLightValue, heldBlockLightValue2) / 15.0);
        #endif


        vec4 albedo = texture(gtexture, texcoord) * glcolor;

        if (albedo.a < alphaTestRef) {
            discard;
        }

        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

        albedo.rgb = pow(albedo.rgb, vec3(2.2));

        vec3 mappedNormal = getMappedNormal(texcoord);

        vec4 specularData = texture(specular, texcoord);
        Material material = materialFromSpecularMap(albedo.rgb, specularData);
        material.ao = texture(normals, texcoord).z;
        #ifndef MC_TEXTURE_FORMAT_LAB_PBR
            if(material.emission == 0.0 && (renderStage == MC_RENDER_STAGE_TERRAIN_SOLID || renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT)){
                material.emission = emission * luminance(albedo.rgb);
            }
            
        #endif

        if(materialID == MATERIAL_PLANTS || materialID == MATERIAL_LEAVES || materialID == MATERIAL_TALL_PLANT_UPPER || materialID == MATERIAL_TALL_PLANT_LOWER){
            material.sss = 1.0;
            material.f0 = vec3(0.04);
            material.roughness = 0.5;
        }

        if(materialID == MATERIAL_WATER){
            mappedNormal = tbnMatrix[2];
            material.f0 = vec3(0.02);
            material.roughness = 0.0;
            material.albedo = vec3(0.0);
        }

        if(materialID == MATERIAL_LAVA){
            material.emission = 1.0;
        }

        #ifdef DIRECTIONAL_LIGHTMAPS
        applyDirectionalLightmap(lightmap, viewPos, mappedNormal, tbnMatrix, material.sss);
        #endif

        parallaxShadow = mix(parallaxShadow, 1.0, material.sss * 0.5);

        if(materialID == MATERIAL_WATER){
            color = vec4(0.0);
        }  else {
            color.rgb = getShadedColor(material, mappedNormal, tbnMatrix[2], lightmap, viewPos, parallaxShadow);
            color.a = albedo.a;
            if(albedo.a != 1.0){
                float fresnel = maxVec3(schlick(material, dot(mappedNormal, normalize(-viewPos))));
                color.a *= (1.0 - fresnel);
            }
            
        }

        outData1.xy = encodeNormal(mat3(gbufferModelViewInverse) * mappedNormal);
        outData1.z = lightmap.y;
        outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));

        #ifdef GODRAYS
        if(color.a == 1.0){
            sunOcclusion = vec4(0.0);
        } else {
            sunOcclusion = albedo;
        }
        #endif
        
    }

#endif