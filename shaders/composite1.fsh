/*
 * composite1 — SketchUp-style edge detection & line pass
 *
 * Reads the cel-shaded scene color emitted by composite.fsh, then
 * overlays depth silhouettes and normal-based crease lines.
 */
#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    vec2 texel = vec2(1.0 / viewWidth, 1.0 / viewHeight);

    vec2 offsets[8];
    offsets[0] = vec2(-texel.x, -texel.y);
    offsets[1] = vec2( 0.0,     -texel.y);
    offsets[2] = vec2( texel.x, -texel.y);
    offsets[3] = vec2(-texel.x,  0.0);
    offsets[4] = vec2( texel.x,  0.0);
    offsets[5] = vec2(-texel.x,  texel.y);
    offsets[6] = vec2( 0.0,      texel.y);
    offsets[7] = vec2( texel.x,  texel.y);

    float kernelX[8];
    kernelX[0] = -1.0; kernelX[1] =  0.0; kernelX[2] =  1.0;
    kernelX[3] = -2.0; kernelX[4] =  2.0;
    kernelX[5] = -1.0; kernelX[6] =  0.0; kernelX[7] =  1.0;

    float kernelY[8];
    kernelY[0] = -1.0; kernelY[1] = -2.0; kernelY[2] = -1.0;
    kernelY[3] =  0.0; kernelY[4] =  0.0;
    kernelY[5] =  1.0; kernelY[6] =  2.0; kernelY[7] =  1.0;

    float depthGx = 0.0;
    float depthGy = 0.0;
    for (int i = 0; i < 8; i++) {
        float d = texture2D(depthtex0, texcoord + offsets[i]).r;
        depthGx += d * kernelX[i];
        depthGy += d * kernelY[i];
    }
    float depthEdge = smoothstep(0.0005, 0.002, length(vec2(depthGx, depthGy)));

    vec3 normalCenter = texture2D(colortex1, texcoord).rgb * 2.0 - 1.0;
    float normalGx = 0.0;
    float normalGy = 0.0;
    for (int i = 0; i < 8; i++) {
        vec3 normal = texture2D(colortex1, texcoord + offsets[i]).rgb * 2.0 - 1.0;
        float difference = 1.0 - dot(normal, normalCenter);
        normalGx += difference * kernelX[i];
        normalGy += difference * kernelY[i];
    }
    float normalEdge = smoothstep(0.05, 0.2, length(vec2(normalGx, normalGy)));

    float edge = max(depthEdge, normalEdge * 0.6);
    vec3 celColor = texture2D(colortex0, texcoord).rgb;
    vec3 outlineColor = vec3(0.05, 0.05, 0.05);

    gl_FragData[0] = vec4(mix(celColor, outlineColor, edge), 1.0);
}