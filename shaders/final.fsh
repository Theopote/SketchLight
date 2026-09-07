/*
 * final — output pass
 *
 * Applies a tiled paper texture to the cel-shaded, outlined scene.
 */
#version 120

uniform sampler2D colortex0;
uniform sampler2D paperTexture;

varying vec2 texcoord;

#define PAPER_GRAIN_STRENGTH 0.08 // [0.0 0.04 0.08 0.12]

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    vec3 paperColor = texture2D(paperTexture, texcoord * 4.0).rgb;
    float paperLuminance = dot(paperColor, vec3(0.2126, 0.7152, 0.0722));
    float paperModulation = 1.0 + (paperLuminance - 0.5) * 2.0 * PAPER_GRAIN_STRENGTH;

    color *= paperModulation;

    gl_FragColor = vec4(color, 1.0);
}
