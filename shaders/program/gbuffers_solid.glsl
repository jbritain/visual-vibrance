#include "/lib/common.glsl"

#ifdef vsh

    in vec2 mc_Entity;
    in vec4 at_tangent;

    out vec2 lmcoord;
    out vec2 texcoord;
    out vec4 glcolor;
    out mat3 tbnMatrix;
    flat out int materialID;
    out vec3 viewPos;

    void main() {
        materialID = int(mc_Entity.x + 0.5);
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        glcolor = gl_Color;

        tbnMatrix[0] = normalize(gl_NormalMatrix * at_tangent.xyz);
        tbnMatrix[2] = normalize(gl_NormalMatrix * gl_Normal);
        tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * at_tangent.w);

        viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
        gl_Position = gbufferProjection * vec4(viewPos, 1.0);
    }

#endif

// ===========================================================================================

#ifdef fsh
    #include "/lib/lighting/shading.glsl"

    in vec2 lmcoord;
    in vec2 texcoord;
    in vec4 glcolor;
    in mat3 tbnMatrix;
    flat in int materialID;
    in vec3 viewPos;

    vec3 getMappedNormal(vec2 texcoord){
        vec3 mappedNormal = texture(normals, texcoord).rgb;
        mappedNormal = mappedNormal * 2.0 - 1.0;
        mappedNormal.z = sqrt(1.0 - dot(mappedNormal.xy, mappedNormal.xy)); // reconstruct z due to labPBR encoding
        
        return tbnMatrix * mappedNormal;
    }

    /* RENDERTARGETS: 0 */
    layout(location = 0) out vec4 color;

    void main() {
        vec2 lightmap = (lmcoord * 33.05 / 32.0) - (1.05 / 32.0);

        vec4 albedo = texture(gtexture, texcoord) * glcolor;

        if (albedo.a < alphaTestRef) {
            discard;
        }

        albedo.rgb = pow(albedo.rgb, vec3(2.2));

        vec3 mappedNormal = getMappedNormal(texcoord);

        vec4 specularData = texture(specular, texcoord);
        Material material = materialFromSpecularMap(albedo.rgb, specularData);

        if(materialID == MATERIAL_PLANTS || materialID == MATERIAL_LEAVES){
            material.sss = 1.0;
        }



        color.rgb = getShadedColor(material, mappedNormal, tbnMatrix[2], lightmap, viewPos);
    }

#endif