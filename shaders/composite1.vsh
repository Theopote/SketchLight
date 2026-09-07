/*
 * composite1 — full-screen outline pass vertex shader
 */
#version 120

varying vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord    = gl_MultiTexCoord0.xy;
}