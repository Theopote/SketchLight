/*
 * gbuffers_terrain — world geometry (blocks) fragment shader
 * Writes albedo to colortex0 and a view-space normal to colortex1.
 * The normal buffer is what composite.fsh uses to draw the
 * SketchUp-style crease/silhouette lines.
 */
#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec3 viewNormal;
varying vec4 vertexColor;

/* DRAWBUFFERS:01 */

void main() {
    vec4 albedo = texture2D(texture, texcoord) * vertexColor;
    if (albedo.a < 0.1) discard;

    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(viewNormal * 0.5 + 0.5, 1.0);
}
