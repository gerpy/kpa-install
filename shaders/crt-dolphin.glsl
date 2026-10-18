// This shader is designed to work with the standalone Dolphin Android emulator 
// It is an adaptation from a piple line with the RA shaders
// - "image-adjustment.slang" to correct colors and light after applying a mask
// - "dotmask.slang" by Lottes with mask #1 and adequate settings for a 640 host screen
// The adaptation has been performed by Gemini 4.0 under the supervision of Tokumeino

/*
[configuration]

[OptionRangeFloat]
GUIName = Sharpen
OptionName = ia_SHARPEN
MaxValue = 1.0
MinValue = 0.0
DefaultValue = 0.25
StepAmount = 0.05

[OptionRangeFloat]
GUIName = Luminance
OptionName = ia_luminance
MaxValue = 2.0
MinValue = 0.0
DefaultValue = 1.05
StepAmount = 0.05

[OptionRangeFloat]
GUIName = Monitor Gamma
OptionName = ia_monitor_gamma
MaxValue = 3.0
MinValue = 1.0
DefaultValue = 2.22
StepAmount = 0.02

[OptionRangeFloat]
GUIName = Contrast
OptionName = ia_contrast
MaxValue = 2.0
MinValue = 0.0
DefaultValue = 1.04
StepAmount = 0.02

[OptionRangeFloat]
GUIName = Saturation
OptionName = ia_saturation
MaxValue = 2.0
MinValue = 0.0
DefaultValue = 1.06
StepAmount = 0.02

[OptionRangeFloat]
GUIName = Bright Boost
OptionName = ia_bright_boost
MaxValue = 1.0
MinValue = -1.0
DefaultValue = 0.0
StepAmount = 0.05

[OptionRangeFloat]
GUIName = Mask Style (0-4)
OptionName = shadowMask
MaxValue = 4.0
MinValue = 0.0
DefaultValue = 1.0
StepAmount = 1.0

[OptionRangeFloat]
GUIName = Mask Dark
OptionName = maskDark
MaxValue = 2.0
MinValue = 0.0
DefaultValue = 0.70
StepAmount = 0.05

[OptionRangeFloat]
GUIName = Mask Light
OptionName = maskLight
IntentName = maskLight
MaxValue = 2.0
MinValue = 0.0
DefaultValue = 1.30
StepAmount = 0.05

[OptionRangeFloat]
GUIName = DotMask Strength
OptionName = DOTMASK_STRENGTH
MaxValue = 1.0
MinValue = 0.0
DefaultValue = 0.15
StepAmount = 0.01

[OptionRangeFloat]
GUIName = BGR Subpixels (0=RGB, 1=BGR)
OptionName = BGR
MaxValue = 1.0
MinValue = 0.0
DefaultValue = 0.0
StepAmount = 1.0

[/configuration]
*/

// Fonction de calcul du masque de phosphore (adaptée de dotmask.glsl de cgwg/Lottes)
vec3 Mask(vec2 pos, float sMask, float bgr, float mDark, float mLight)
{
   vec3 mask = vec3(mDark, mDark, mDark);
   
   // 1. Très compressé style TV
   if (sMask == 1.0)
   {
      float line = mLight;
      float odd  = 0.0;

      if (fract(pos.x/6.0) < 0.5)
         odd = 1.0;
      if (fract((pos.y + odd)/2.0) < 0.5)
         line = mDark;

      pos.x = fract(pos.x/3.0);

      if (pos.x < 0.3333) mask.rgb = (bgr == 1.0) ? vec3(mask.r, mask.g, mLight) : vec3(mLight, mask.g, mask.b);
      else if (pos.x < 0.6666) mask.g = mLight;
      else mask.rgb = (bgr == 1.0) ? vec3(mLight, mask.g, mask.b) : vec3(mask.r, mask.g, mLight);
      mask *= line;  
   } 
   // 2. Grille d'ouverture (Aperture-grille)
   else if (sMask == 2.0)
   {
      pos.x = fract(pos.x/3.0);

      if (pos.x < 0.3333) mask.rgb = (bgr == 1.0) ? vec3(mask.r, mask.g, mLight) : vec3(mLight, mask.g, mask.b);
      else if (pos.x < 0.6666) mask.g = mLight;
      else mask.rgb = (bgr == 1.0) ? vec3(mLight, mask.g, mask.b) : vec3(mask.r, mask.g, mLight);
   } 
   // 3. Style VGA étiré horizontalement (Shadow mask classique)
   else if (sMask == 3.0)
   {
      pos.x += pos.y * 3.0;
      pos.x  = fract(pos.x / 6.0);

      if (pos.x < 0.3333) mask.rgb = (bgr == 1.0) ? vec3(mask.r, mask.g, mLight) : vec3(mLight, mask.g, mask.b);
      else if (pos.x < 0.6666) mask.g = mLight;
      else mask.rgb = (bgr == 1.0) ? vec3(mLight, mask.g, mask.b) : vec3(mask.r, mask.g, mLight);
   }
   // 4. Style VGA standard
   else if (sMask == 4.0)
   {
      pos.xy = floor(pos.xy * vec2(1.0, 0.5));
      pos.x += pos.y * 3.0;
      pos.x  = fract(pos.x / 6.0);

      if (pos.x < 0.3333) mask.rgb = (bgr == 1.0) ? vec3(mask.r, mask.g, mLight) : vec3(mLight, mask.g, mask.b);
      else if (pos.x < 0.6666) mask.g = mLight;
      else mask.rgb = (bgr == 1.0) ? vec3(mLight, mask.g, mask.b) : vec3(mask.r, mask.g, mLight);
   }

   return mask;
}

void main()
{
    vec2 uv = GetCoordinates().xy;
    vec2 tex_size = GetResolution();
    vec2 inv_tex_size = GetInvResolution();

    // --- ÉTAPE 1 : Image Adjustment (Netteté / Sharpen, Contraste, Saturation, Luminance) ---
    // Récupération des paramètres
    float sharpen = GetOption(ia_SHARPEN);
    float luminance = GetOption(ia_luminance);
    float monitor_gamma = GetOption(ia_monitor_gamma);
    float contrast = GetOption(ia_contrast);
    float saturation = GetOption(ia_saturation);
    float bright_boost = GetOption(ia_bright_boost);

    // Échantillonnage avec filtre de netteté (Pass 0 de image-adjustment)
    vec3 col = SampleLocation(uv).rgb;
    if (sharpen > 0.0) {
        vec3 dx = SampleLocation(uv + vec2(inv_tex_size.x, 0.0)).rgb - SampleLocation(uv - vec2(inv_tex_size.x, 0.0)).rgb;
        vec3 dy = SampleLocation(uv + vec2(0.0, inv_tex_size.y)).rgb - SampleLocation(uv - vec2(0.0, inv_tex_size.y)).rgb;
        col -= sharpen * (dx + dy);
    }

    // Ajustements de luminance, contraste et boost
    col = col * luminance + bright_boost;
    col = (col - 0.5) * contrast + 0.5;

    // Ajustement de la saturation
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luma), col, saturation);
    col = clamp(col, 0.0, 1.0);

    // --- ÉTAPE 2 : Dotmask & Gamma Lottes (Pass 1) ---
    // Conversion linéaire selon le gamma du moniteur configuré
    col = pow(max(col, 0.0), vec3(monitor_gamma));

    float sMask = GetOption(shadowMask);
    float bgr = GetOption(BGR);
    float dm_strength = GetOption(DOTMASK_STRENGTH);
    float mDark = GetOption(maskDark);
    float mLight = GetOption(maskLight);

    if (sMask == 0.0) 
    {
        // Dotmask simple de type cgwg
        float mask = 1.0 - dm_strength;
        vec2 win_coord = uv * GetWindowResolution();
        float mod_factor = win_coord.x;
        vec3 dotMaskWeights = mix(vec3(1.0, mask, 1.0),
                                  vec3(mask, 1.0, mask),
                                  floor(mod(mod_factor, 2.0)));
        col *= dotMaskWeights;
    }
    else 
    {
        // Masques complexes Lottes (Aperture-grille / Shadow mask)
        vec2 fragCoord = uv * GetWindowResolution();
        col *= Mask(floor(1.000001 * fragCoord + vec2(0.5, 0.5)), sMask, bgr, mDark, mLight);
    }

    // Retour au gamma standard sRGB pour l'affichage écran (1.0 / 2.2)
    col = pow(max(col, 0.0), vec3(1.0 / 2.2));

    SetOutput(vec4(col, 1.0));
}