/*
 * gbuffers_basic — fallback vertex shader
 * Used by Iris/OptiFine for render stages that don't have a more
 * specific gbuffers_* program (particles, misc entities, etc.)
 */
#version 120

varying vec3 viewNormal;
varying vec4 vertexColor;

void main() {
    gl_Position = ftransform();
    viewNormal  = normalize(gl_NormalMatrix * gl_Normal);
    vertexColor = gl_Color;
}
