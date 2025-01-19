



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
    if(length(viewPos) < far - 16){
        discard;
        return;
    }

    if(texture(depthtex0, gl_FragCoord.xy / resolution).r < 1.0){
        discard;
    }

    vec2 lightmap = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);

    #ifdef WORLD_THE_END
    lightmap.y = 1.0;
    #endif


    vec4 albedo = glcolor;

    if (albedo.a < alphaTestRef) {
        discard;
    }

    int materialID = materialID;
    if(materialID == MATERIAL_WATER && albedo.a == 1.0){
        materialID = 0;
    }

    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;
    vec3 noisePos = mod(worldPos * 4.0, 64.0);
    vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
    ivec2 noiseCoord;
    if(abs(worldNormal.x) > 0.5){
        noiseCoord = ivec2(noisePos.yz);
    } else if (abs(worldNormal.y) > 0.5){
        noiseCoord = ivec2(noisePos.xz);
    } else {
        noiseCoord = ivec2(noisePos.xy);
    }

    albedo.rgb *= texelFetch(noisetex, noiseCoord, 0).r * 0.1 + 0.9;


    albedo.rgb = pow(albedo.rgb, vec3(2.2));

    Material material;
    material.albedo = albedo.rgb;
    material.roughness = 1.0;
    material.f0 = vec3(0.0);
    material.f82 = vec3(0.0);
    material.metalID = NO_METAL;
    material.porosity = 0.0;
    material.sss = 0.0;
    material.emission = 0.0;
    material.ao = 0.0;

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
        color = vec4(0.0);
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