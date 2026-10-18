#version 450

// This shader is designed to work with the standalone ARMSX2 emulator 
// It is an adaptation from a piple line with the RA shaders
// - "image-adjustment.slang" to correct colors and light after applying a mask
// - "dotmask.slang" by Lottes with mask #1 and adequate settings for a 640 host screen
// The adaptation has been performed by Gemini 4.0 under the supervision of Tokumeino

// =====================================================================
// PARAMETRES MODIFIABLES (Valeurs par defaut deja reglees sur votre preset)
// Syntaxe : #pragma parameter NOM "Description" DEFAUT MIN MAX PAS
// =====================================================================
#pragma parameter ia_SHARPEN       "Sharpen (0.0=Bilinear, 1.0=Quilez)" 0.25 0.00 1.00 0.05
#pragma parameter ia_luminance     "Luminance"                          1.05 0.00 2.00 0.01
#pragma parameter ia_monitor_gamma "Monitor Gamma"                      2.22 0.10 5.00 0.01
#pragma parameter ia_target_gamma  "Target Gamma"                       2.20 0.10 5.00 0.01
#pragma parameter ia_contrast      "Contrast"                           1.05 0.00 5.00 0.01
#pragma parameter ia_saturation    "Saturation"                         1.06 0.00 5.00 0.01
#pragma parameter ia_bright_boost  "Brightness Boost"                   0.00 -1.00 1.00 0.01
#pragma parameter ia_black_level   "Black Level"                        0.00 -0.30 0.30 0.01
#pragma parameter shadowMask       "Mask Style (0:CGWG, 1:TV, 3:Lottes, 4:VGA, 5:Check)" 1.00 0.00 5.00 1.00
#pragma parameter maskDark         "Lottes maskDark"                    0.70 0.00 2.00 0.01
#pragma parameter maskLight        "Lottes maskLight"                   1.30 0.00 2.00 0.01
#pragma parameter DOTMASK_STRENGTH "CGWG Dot Mask Strength"             0.15 0.00 1.00 0.01
#pragma parameter BGR              "Subpixels Order (0=RGB, 1=BGR)"     0.00 0.00 1.00 1.00

layout(push_constant) uniform Push
{
   vec4 SourceSize;
   vec4 OriginalSize;
   vec4 OutputSize;
   uint FrameCount;
   float ia_SHARPEN;
   float ia_luminance;
   float ia_monitor_gamma;
   float ia_target_gamma;
   float ia_contrast;
   float ia_saturation;
   float ia_bright_boost;
   float ia_black_level;
   float shadowMask;
   float maskDark;
   float maskLight;
   float DOTMASK_STRENGTH;
   float BGR;
} registers;

layout(std140, set = 0, binding = 0) uniform UBO
{
   mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord   = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

// --- Fonctions de conversion d'espace colorimetrique (issues de colorspace-tools.h) ---
vec3 RGBtoHSV(vec3 c)
{
   vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
   vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
   vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
   float d = q.x - min(q.w, q.y);
   float e = 1.0e-10;
   return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 HSVtoRGB(vec3 c)
{
   vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
   vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
   return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// --- Interpolation polynomiale d'Inigo Quilez (issue de image-adjustment.slang) ---
vec3 sharp(sampler2D tex, vec2 texCoord)
{
   vec2 p = texCoord.xy * registers.SourceSize.xy + vec2(0.5, 0.5);
   vec2 i = floor(p);
   vec2 f = p - i;
   f = f * f * f * (f * (f * 6.0 - vec2(15.0, 15.0)) + vec2(10.0, 10.0));
   p = i + f;
   p = (p - vec2(0.5, 0.5)) * registers.SourceSize.zw;
   return texture(tex, p).rgb;
}

// --- Masques de Timothy Lottes (issus de dotmask.slang) ---
vec3 Mask(vec2 pos)
{
   vec3 mask = vec3(registers.maskDark, registers.maskDark, registers.maskDark);

   // 1.0 : Very compressed TV style shadow mask
   if (registers.shadowMask == 1.0)
   {
      float line = registers.maskLight;
      float odd  = 0.0;
      if (fract(pos.x / 6.0) < 0.5) odd = 1.0;
      if (fract((pos.y + odd) / 2.0) < 0.5) line = registers.maskDark;

      pos.x = fract(pos.x / 3.0);
      if      (pos.x < 0.333) mask.rgb = (registers.BGR == 1.0) ? vec3(mask.r, mask.g, registers.maskLight) : vec3(registers.maskLight, mask.g, mask.b);
      else if (pos.x < 0.666) mask.g   = registers.maskLight;
      else                    mask.rgb = (registers.BGR == 1.0) ? vec3(registers.maskLight, mask.g, mask.b) : vec3(mask.r, mask.g, registers.maskLight);
      mask *= line;
   }
   // 2.0 : Aperture-grille
   else if (registers.shadowMask == 2.0)
   {
      pos.x = fract(pos.x / 3.0);
      if      (pos.x < 0.333) mask.rgb = (registers.BGR == 1.0) ? vec3(mask.r, mask.g, registers.maskLight) : vec3(registers.maskLight, mask.g, mask.b);
      else if (pos.x < 0.666) mask.g   = registers.maskLight;
      else                    mask.rgb = (registers.BGR == 1.0) ? vec3(registers.maskLight, mask.g, mask.b) : vec3(mask.r, mask.g, registers.maskLight);
   }
   // 3.0 : Stretched VGA style shadow mask
   else if (registers.shadowMask == 3.0)
   {
      pos.x += pos.y * 3.0;
      pos.x  = fract(pos.x / 6.0);
      if      (pos.x < 0.333) mask.rgb = (registers.BGR == 1.0) ? vec3(mask.r, mask.g, registers.maskLight) : vec3(registers.maskLight, mask.g, mask.b);
      else if (pos.x < 0.666) mask.g   = registers.maskLight;
      else                    mask.rgb = (registers.BGR == 1.0) ? vec3(registers.maskLight, mask.g, mask.b) : vec3(mask.r, mask.g, registers.maskLight);
   }
   // 4.0 : VGA style shadow mask
   else if (registers.shadowMask == 4.0)
   {
      pos.xy = floor(pos.xy * vec2(1.0, 0.5));
      pos.x += pos.y * 3.0;
      pos.x  = fract(pos.x / 6.0);
      if      (pos.x < 0.333) mask.rgb = (registers.BGR == 1.0) ? vec3(mask.r, mask.g, registers.maskLight) : vec3(registers.maskLight, mask.g, mask.b);
      else if (pos.x < 0.666) mask.g   = registers.maskLight;
      else                    mask.rgb = (registers.BGR == 1.0) ? vec3(registers.maskLight, mask.g, mask.b) : vec3(mask.r, mask.g, registers.maskLight);
   }
   // 5.0 : Checkered monochrome fine mask
   else if (registers.shadowMask == 5.0)
   {
      float line = registers.maskLight;
      float odd  = 0.0;
      if (fract(pos.x / 2.0) < 0.5) odd = 1.0;
      if (fract((pos.y + odd) / 2.0) < 0.5) line = registers.maskDark;
      mask = vec3(line);
   }

   return mask;
}

void main()
{
   // 1. Echantillonnage et lissage Bilineaire / Quilez (Passe 0)
   vec3 res = texture(Source, vTexCoord).rgb;
   res = mix(res, sharp(Source, vTexCoord), registers.ia_SHARPEN);

   // 2. Ajustement colorimetrique et gamma (image-adjustment)
   vec3 gamma = vec3(registers.ia_monitor_gamma / registers.ia_target_gamma);
   vec3 satColor = clamp(HSVtoRGB(RGBtoHSV(res) * vec3(1.0, registers.ia_saturation, registers.ia_luminance)), 0.0, 1.0);
   vec3 conColor = clamp((satColor - 0.5) * registers.ia_contrast + 0.5 + registers.ia_bright_boost, 0.0, 1.0);

   conColor -= vec3(registers.ia_black_level);
   conColor *= (vec3(1.0) / vec3(1.0 - registers.ia_black_level));
   conColor  = pow(max(conColor, vec3(0.0)), 1.0 / gamma);
   conColor  = clamp(conColor, 0.0, 1.0);

   // 3. Application du masque physique sur le Viewport (dotmask)
   vec3 linearColor = pow(conColor, vec3(2.2));
   float mod_factor = vTexCoord.x * registers.OutputSize.x;
   float cgwg_mask  = 1.0 - registers.DOTMASK_STRENGTH;
   vec3 dotMaskWeights = mix(vec3(1.0, cgwg_mask, 1.0), vec3(cgwg_mask, 1.0, cgwg_mask), floor(mod(mod_factor, 2.0)));

   if (registers.shadowMask == 0.0)
   {
      linearColor *= dotMaskWeights;
   }
   else
   {
      linearColor *= Mask(floor(vTexCoord * registers.OutputSize.xy * 1.0001));
   }

   FragColor = vec4(pow(linearColor, vec3(1.0 / 2.2)), 1.0);
}