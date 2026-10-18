#version 450

// This shader is a modification of the standard RA shader "lcdx.slang" :
// - It replaces the standard OriginalSize by SourceSize
// - This is usefull for pipelines asking for it
// The code has been written by Gemini 4.0 under the supervision of Tokumeino

layout(push_constant) uniform Push {
    vec4 SourceSize;
    vec4 OutputSize;
    float BRIGHTEN_SCANLINES;
    float BRIGHTEN_LCD;
} params;

#pragma parameter BRIGHTEN_SCANLINES "Brighten Scanlines" 16.0 1.0 32.0 0.5
#pragma parameter BRIGHTEN_LCD "Brighten LCD" 4.0 1.0 12.0 0.5

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

const float PI = 3.141592654;

void main() {
    vec2 pixelCoord = vTexCoord * params.SourceSize.xy;
    vec2 angle = 2.0 * PI * (pixelCoord - 0.25);
    
    float yfactor = (params.BRIGHTEN_SCANLINES + sin(angle.y)) / (params.BRIGHTEN_SCANLINES + 1.0);
    float xfactor = (params.BRIGHTEN_LCD + sin(angle.x)) / (params.BRIGHTEN_LCD + 1.0);
    
    vec3 color = texture(Source, vTexCoord).rgb;
    FragColor = vec4(color * yfactor * xfactor, 1.0);
}