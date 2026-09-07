#version 120

varying vec3 viewNormal;
varying vec4 vertexColor;

/* DRAWBUFFERS:01 */
// colortex0 <- albedo, colortex1 <- encoded view-space normal

void main() {
    gl_FragData[0] = vertexColor;
    gl_FragData[1] = vec4(viewNormal * 0.5 + 0.5, 1.0);
}
