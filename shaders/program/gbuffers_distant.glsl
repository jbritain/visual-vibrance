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

    out vec2 texcoord;
    out vec2 lmcoord;
    out vec4 glcolor;
    out vec3 normal;
    flat out int materialID;
    out vec3 viewPos;

    #include "/lib/dh.glsl"

    void main() {
        materialID = convertDHMaterialIDs(dhMaterialId);
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        normal = normalize(gl_NormalMatrix * gl_Normal);

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

        gl_Position = dhProjection * vec4(viewPos, 1.0);
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
    in vec3 normal;
    flat in int materialID;
    in vec3 viewPos;

    /* RENDERTARGETS: 0,1 */
    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 outData1;

    void main() {
        vec2 lightmap = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);

        #ifdef WORLD_THE_END
        lightmap.y = 1.0;
        #endif


        vec4 albedo = texture(gtexture, texcoord) * glcolor;

        if (albedo.a < alphaTestRef) {
            discard;
        }

        albedo.rgb = pow(albedo.rgb, vec3(2.2));

        vec4 specularData = texture(specular, texcoord);
        Material material = materialFromSpecularMap(albedo.rgb, specularData);
        material.ao = texture(normals, texcoord).z;

        if(materialID == MATERIAL_PLANTS || materialID == MATERIAL_LEAVES || materialID == MATERIAL_TALL_PLANT_UPPER || materialID == MATERIAL_TALL_PLANT_LOWER){
            material.sss = 1.0;
            material.f0 = vec3(0.04);
            material.roughness = 0.5;
        }

        if(materialID == MATERIAL_WATER){
            material.f0 = vec3(0.02);
            material.roughness = 0.0;
        }

        if(materialID == MATERIAL_WATER){
            color.a = 0.0;
        }  else {
            color.rgb = getShadedColor(material, normal, normal, lightmap, viewPos);
            color.a = albedo.a;
            float fresnel = maxVec3(schlick(material, dot(normal, normalize(-viewPos))));
            color.a *= (1.0 - fresnel);
        }

        outData1.xy = encodeNormal(mat3(gbufferModelViewInverse) * normal);
        outData1.z = lightmap.y;
        outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));
    }

#endif