#version 450

layout(push_constant) uniform Push {
    vec4 SourceSize;
    vec4 OutputSize;
} params;

layout(std140, set = 0, binding = 0) uniform UBO { mat4 MVP; } global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;
void main() { gl_Position = global.MVP * Position; vTexCoord = TexCoord; }

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main() {
    vec2 outPx = floor(vTexCoord * params.OutputSize.xy);

    // 1. Ecran principal (256x192) a gauche (X de 0 a 255)
    if (outPx.x < 256.0 && outPx.y < 192.0) {
        vec2 uv = (vec2(outPx.x, outPx.y) + 0.5) / vec2(256.0, 384.0);
        FragColor = vec4(texture(Source, uv).rgb, 1.0);
        return;
    }

    // 2. Gap noir strict de 1 pixel natif (X = 256)
    if (outPx.x == 256.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 3. Vignette 0.25x stricte (Moyenne 4x4 parfaite)
    // De X = 257 a X = 319 (le 64eme pixel est naturelement hors-champ)
    float startX = 257.0;
    float startY = 72.0; // Centrage vertical : (192 - 48) / 2 = 72

    if (outPx.x >= startX && outPx.x < 320.0 && outPx.y >= startY && outPx.y < startY + 48.0) {
        vec2 thumbPx = outPx - vec2(startX, startY);
        
        // Decalage de 192 sur Y pour lire l'ecran du bas dans le flux natif
        vec2 baseSrcPx = thumbPx * 4.0 + vec2(0.0, 192.0);

        vec3 acc = vec3(0.0);
        for (int dy = 0; dy < 4; dy++) {
            for (int dx = 0; dx < 4; dx++) {
                vec2 uv = (baseSrcPx + vec2(float(dx), float(dy)) + 0.5) / vec2(256.0, 384.0);
                acc += texture(Source, uv).rgb;
            }
        }
        FragColor = vec4(acc / 16.0, 1.0);
        return;
    }
    
    FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}