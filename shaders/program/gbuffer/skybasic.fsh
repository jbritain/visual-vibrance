



in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  if (renderStage == MC_RENDER_STAGE_STARS) {
    color = glcolor;
  } else {
    color = vec4(0.0);
  }

  color.rgb *= vec3(4.0, 4.0, 5.0);
  color.rgb = pow(color.rgb, vec3(2.2));
}