/*
 * composite — full-screen pass vertex shader
 * Iris renders composite programs on a full-screen quad; this is
 * boilerplate pass-through, you generally never touch this file.
 */
#version 120

varying vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord    = gl_MultiTexCoord0.xy;
}
