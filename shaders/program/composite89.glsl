/*
    Copyright (c) 2024 Josh Britain (jbritain)
    All rights reserved

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

    /* RENDERTARGETS: 0,3 */
    layout(location = 0) out vec4 color;
    layout(location = 1) out vec4 newHistory;

    const ivec2 neighbourhoodOffsets[8] = ivec2[8](
        ivec2( 1, 1),
        ivec2( 1,-1),
        ivec2(-1, 1),
        ivec2(-1,-1),
        ivec2( 1, 0),
        ivec2( 0, 1),
        ivec2(-1, 0),
        ivec2( 0,-1)
    );
    

    void main() {
        float depth = texture(depthtex0, texcoord).r;
        float opaqueDepth = texture(depthtex2, texcoord).r;
        vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
        vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
        feetPlayerPos += cameraPosition;
        feetPlayerPos -= previousCameraPosition;
        vec3 previousViewPos = (gbufferPreviousModelView * vec4(feetPlayerPos, 1.0)).xyz;
        vec4 previousClipPos = gbufferPreviousProjection * vec4(previousViewPos, 1.0);
        vec3 previousScreenPos = (previousClipPos.xyz / previousClipPos.w) * 0.5 + 0.5;

        color = texture(colortex0, texcoord);

        bool rejectSample = clamp01(previousScreenPos.xy) != previousScreenPos.xy;
        #ifndef SSR_JITTER
        rejectSample = rejectSample || opaqueDepth != depth;

        #ifdef DISTANT_HORIZONS
        rejectSample = rejectSample || (depth == 1.0 && texture(dhDepthTex0, texcoord).r  != 1.0);
        #endif

        #endif



        vec4 historyColor = texture(colortex3, previousScreenPos.xy);

        // neighbourhood clamping
        vec3 maxCol = vec3(0.0);
        vec3 minCol = vec3(999999999.0);

        for(int i = 0; i < 8; i++){
            vec3 neighbourhoodSample = texelFetch(colortex0, ivec2(gl_FragCoord.xy) + neighbourhoodOffsets[i], 0).rgb;
            maxCol = max(maxCol, neighbourhoodSample);
            minCol = min(minCol, neighbourhoodSample);
        }

        historyColor.rgb = clamp(historyColor.rgb, minCol, maxCol);

        color = mix(color, historyColor, 0.7 * float(!rejectSample));

        newHistory = color;
        
    }

#endif