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
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 texcoord;

#define OUTLINE_STRENGTH 1.0 // [0.25 0.5 0.75 1.0]
#define SHOW_NORMAL_EDGES

/* DRAWBUFFERS:0 */

float hash(vec2 position) {
    return fract(sin(dot(position, vec2(127.1, 311.7))) * 43758.5453123);
}

float valueNoise(vec2 position) {
    vec2 cell = floor(position);
    vec2 fraction = fract(position);
    fraction = fraction * fraction * (3.0 - 2.0 * fraction);

    return mix(
        mix(hash(cell), hash(cell + vec2(1.0, 0.0)), fraction.x),
        mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), fraction.x),
        fraction.y
    );
}

vec3 worldPositionFromDepth(vec2 screenPosition, float depth) {
    vec4 clipPosition = vec4(screenPosition * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPosition = gbufferProjectionInverse * clipPosition;
    viewPosition /= viewPosition.w;

    return (gbufferModelViewInverse * viewPosition).xyz + cameraPosition;
}

void main() {
    vec2 texel = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    float centerDepth = texture2D(depthtex0, texcoord).r;
    vec3 worldPosition = worldPositionFromDepth(texcoord, centerDepth);
    vec2 wobble = vec2(
        valueNoise(worldPosition.xz * 0.12),
        valueNoise(worldPosition.xz * 0.12 + vec2(19.7, 43.2))
    ) - 0.5;
    vec2 sampleCoord = clamp(texcoord + wobble * texel * 0.8, texel * 0.5, 1.0 - texel * 0.5);

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
        float d = texture2D(depthtex0, sampleCoord + offsets[i]).r;
        depthGx += d * kernelX[i];
        depthGy += d * kernelY[i];
    }
    float depthEdge = smoothstep(0.0005, 0.002, length(vec2(depthGx, depthGy)));

    float normalGx = 0.0;
    float normalGy = 0.0;
#ifdef SHOW_NORMAL_EDGES
    vec3 normalCenter = texture2D(colortex1, sampleCoord).rgb * 2.0 - 1.0;
    for (int i = 0; i < 8; i++) {
        vec3 normal = texture2D(colortex1, sampleCoord + offsets[i]).rgb * 2.0 - 1.0;
        float difference = 1.0 - dot(normal, normalCenter);
        normalGx += difference * kernelX[i];
        normalGy += difference * kernelY[i];
    }
#endif
    float normalEdge = smoothstep(0.05, 0.2, length(vec2(normalGx, normalGy)));

    float edge = clamp(max(depthEdge, normalEdge * 0.6) * OUTLINE_STRENGTH, 0.0, 1.0);
    vec3 celColor = texture2D(colortex0, texcoord).rgb;
    float celLuminance = dot(celColor, vec3(0.2126, 0.7152, 0.0722));
    vec3 desaturatedColor = mix(celColor, vec3(celLuminance), 0.65);
    vec3 outlineColor = desaturatedColor * 0.22 + vec3(0.015);

    gl_FragData[0] = vec4(mix(celColor, outlineColor, edge), 1.0);
}