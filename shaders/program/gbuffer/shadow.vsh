


#include "/lib/shadowSpace.glsl"

#include "/lib/sway.glsl"

in vec2 mc_Entity;
in vec4 at_tangent;
in vec3 at_midBlock;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
flat out int materialID;
out vec3 feetPlayerPos;
out vec3 shadowViewPos;

void main() {        
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    normal = gl_NormalMatrix * gl_Normal; // shadow view space

    materialID = int(mc_Entity.x + 0.5);

    shadowViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    #ifdef WAVING_BLOCKS
    feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;
    feetPlayerPos = getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock) - cameraPosition;
    shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
    #endif
    gl_Position = gl_ProjectionMatrix * vec4(shadowViewPos, 1.0);

    
    gl_Position.xyz = distort(gl_Position.xyz);
}