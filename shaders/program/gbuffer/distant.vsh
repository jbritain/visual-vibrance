



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
