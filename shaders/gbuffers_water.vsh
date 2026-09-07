/*
 * gbuffers_water — translucent geometry (water, stained glass, ice)
 * Same as gbuffers_terrain for now; split out so you can special-case
 * translucents later (e.g. skip outline on water surfaces).
 */
#version 120

varying vec2 texcoord;
varying vec3 viewNormal;
varying vec4 vertexColor;

void main() {
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
    texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    viewNormal  = normalize(gl_NormalMatrix * gl_Normal);
    vertexColor = gl_Color;
}
