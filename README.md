> **NOTHING TESTED YET : STILL WAITING FOR MY KPA**

# Installation Preparation for a Konkr Pocket Advance

> The recommendations and technical choices presented here are my own, and I may have made mistakes or oversights. Because English is not my native language, I used Gemini to translate, structure, and format my personal notes into this document.

## Retroarch Scaling for CRT systems

The Konkr Pocket Advance (KPA) features an unusual 3:2 aspect ratio screen with a 640p resolution (960x640). While this is the absolute perfect format for pixel-perfect Game Boy Advance emulation, it also opens up fantastic possibilities for 8-bit, 16-bit, and 32-bit home consoles—provided you configure it correctly. 

Because 3:2 is wider and shorter than the classic 4:3 CRT TV standard, playing legacy content with default settings usually results in massive black borders (pillarboxing) or poorly scaled scanlines. To solve this and maximize screen real estate, I use a dual-optimization approach: combining a surgical **vertical overscan crop** (hiding empty borders, visual garbage, or less useful background elements at the top and bottom of the original video signal) with a calculated **horizontal stretch** (filling the screen without crossing into visually offensive distortion).

The theoretical foundation, geometric rules, and the empirical HUD mapping that dictate these configurations are fully detailed in my companion document:
👉 **[KPA Viewport Doctrine & HUD Footprint Reference](scaling-approach.md)**

While the companion document explains the *why* and the *rules*, **this document provides the practical implementation**. Below, you will find the precise Viewport coordinates (X, Y, Width, Height) and shader recommendations tailored for each system, along with a brief justification for the chosen compromise.

*(Note on nomenclature: For consistency and ease of integration into modern frontends, all system directories and names listed below strictly follow the **ES-DE (EmulationStation Desktop Edition)** naming convention).*

### Sega Mega Drive / Genesis (`megadrive`)

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 320x224 (Standard V28 mode).
- **Objective:** Fractional Scaling (Rule 2) maximizing vertical height through an auto-centered 2-line micro-crop, combined with a mathematically pristine 3.1% horizontal Nostalgia Stretch (Scenario A) to fill the KPA screen.

**Mathematical Logic (Scenario A & Rule 2)**

- **Y-Axis (Vertical):** 
  - Integer Scaling (3x) forces an 11-line crop, which systematically decapitates UI elements on the extreme top and bottom edges.
  - *Fractional Calculation:* We abandon integer scaling. Empirical testing reveals the Mega Drive safely tolerates a maximum symmetric micro-crop of **2 native lines** before critical text is amputated. 
  - The total height of the 224-line source at this maximized fractional scale is defined as **652 pixels**.
- **Vertical Crop (Auto-Centered):**
  - By leaving the Y-offset at `0` and relying on RetroArch's default `0.5` Anchor Bias, the 652p image centers itself automatically within the 640p physical screen.
  - Top crop: 6 physical pixels (exactly 2 native lines).
  - Bottom crop: 6 physical pixels (exactly 2 native lines).
  - *Verdict:* 100% of the screen height is utilized. The symmetric 2-line sacrifice pushes the maximum amount of overscan off-screen, enlarging the sprites to their absolute limit while leaving top-anchored text menus and bottom-anchored HUDs perfectly intact.
- **X-Axis (Horizontal):** 
  - A mathematically perfect 1:1 Pixel Aspect Ratio based on the 652p viewport height requires a width of **931 pixels**. 
  - *Nostalgia Stretch (The Cheat):* Stretching the 931px width to hit the full **960 pixels** results in a minimal **3.1% stretch**.
  - The geometry aligns flawlessly: the Mega Drive image fills the entire 3:2 screen edge-to-edge with an imperceptible level of distortion.
- **Offsets:** We use `0` for both X and Y, allowing the 0.5 Anchor Bias to perfectly auto-center the 960x652 viewport.

**Configuration Rules (GUI Method)**

To apply these settings directly through the RetroArch interface, navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow fractional stretching and custom heights).
2. **Aspect Ratio:** `Custom` (This exposes the manual viewport coordinates below).
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `960`
6. **Custom Aspect Ratio (Height):** `652`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`megadrive.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "960"
custom_viewport_height = "652"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Super Nintendo / Super Famicom (`snes`)

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x224 (Standard output).
- **Objective:** Integer Scaling (Rule 1) on the vertical axis for pristine sharpness, combined with horizontal Cathodic Correction (Scenario B) to hit the exact midpoint between perfect circles and nostalgic 4:3 stretching.

**Mathematical Logic (Scenario B & Rule 1)**

- **Y-Axis (Vertical):** 
  - 224 x 3 = 672 pixels. The native 224 height multiplied by a perfect 3x integer scale creates a 32-pixel overflow relative to the KPA's 640p physical height.
- **Vertical Crop (Auto-Centered):** 
  - By leaving the Y-offset at `0` and relying on RetroArch's default `0.5` Anchor Bias, the image centers itself automatically.
  - Top crop: 16 physical pixels (~5.3 native lines).
  - Bottom crop: 16 physical pixels (~5.3 native lines).
  - *Verdict:* Nintendo's historical certification guidelines forced developers to leave a strict 8-line safe margin at the top and bottom. This symmetric 5.3-line crop effortlessly hides the overscan while leaving nearly 3 lines of natural breathing room before the HUD begins. 100% of the UI is safely preserved.
- **X-Axis (Horizontal):** 
  - A mathematically perfect 1:1 Pixel Aspect Ratio (PAR) based on the 3x scale height is **768 pixels** (256 x 3). 
  - The historical 4:3 aspect ratio stretched this width to **896 pixels** (672 * 4/3), creating massive geometric distortion.
  - *Cathodic Correction:* We calculate the exact midpoint between the perfect PAR and the historical stretch: (768 + 896) / 2 = **832 pixels**.
  - This width produces an 8.3% stretch, purposely exceeding the 5% Aspect Ratio Crime threshold to satisfy our visual memory of the SNES, while heavily mitigating the severe oval distortion seen on original CRT hardware.
- **Offsets:** We use `0` for both X and Y, allowing the 0.5 Anchor Bias to perfectly center the 832x672 viewport on the screen.

**Configuration Rules (GUI Method)**

To apply these settings directly through the RetroArch interface, navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally. Since our 672p target height overflows the 640p screen, leaving this ON forces RetroArch's "Smart" scale to crush the image down to 2x. Disabling it allows our custom coordinates to enforce the 3x height).
2. **Aspect Ratio:** `Custom` 
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `832`
6. **Custom Aspect Ratio (Height):** `672`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`snes.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "832"
custom_viewport_height = "672"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Sega Master System (`mastersystem`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 256x192.
* **Objective:** Fractional Scaling (Rule 2) combined with a horizontal Nostalgia Stretch (Scenario A). The goal is to avoid the massive letterboxing of a 3x scale without amputating the rigid HUD.

**Mathematical Logic (Scenario A & Rule 2)**

* **Y-Axis (Vertical):** The Master System's 192-line active window leaves zero croppable margin (Top: 0px, Bot: 0px). 
  * A 3x integer scale yields 576 pixels (leaving 64px of dead black space vertically).
  * A 4x integer scale yields 768 pixels (forcing a 128px crop that would completely destroy the HUD).
  * *Solution:* We break the integer rule and apply a fractional scale to perfectly fit the screen height (192 lines scaled up to **640 pixels**, which is exactly ~3.333x). The HUD remains 100% untouched.
* **X-Axis (Horizontal):** 
  * The native 256x192 resolution is mathematically a perfect 4:3 ratio with square pixels (1:1 PAR). Scaled vertically to 640p, the perfect 4:3 width is **853 pixels**.
  * *Nostalgia Stretch:* To eat up the side pillarboxes without committing an Aspect Ratio Crime, we apply a ~5% stretch. 853 * 1.05 = **896 pixels**.
* **X-Offset & Y-Offset:** 
  * X = (960 - 896) / 2 = `32`.
  * Y = (640 - 640) / 2 = `0`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** By definition of Rule 2, we abandon CRT integer alignment. We rely on the shader's internal interpolation (anti-aliasing) to draw scanlines over the fractionally scaled 640p vertical axis.
2. **Disable Global Integer Scaling:** Mandatory to allow the custom fractional coordinates to take effect.
3. **Zero Crop Oversight:** Ensure no overscan cropping is active, as every single one of the 192 native lines contains critical UI data.

**Configuration File (`mastersystem.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "32"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Nintendo Entertainment System (`nes`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 256x240.
* **Objective:** Fractional Scaling (Rule 2) with a balanced breathing room for the HUD, hiding the worst scrolling artifacts while applying horizontal Cathodic Correction.

**Mathematical Logic (Scenario B & Rule 2)**

* **Y-Axis (Vertical) & Breathing Room:** 
  * The strictly useful HUD footprint sits between lines 8 and 223 (216 active lines). 
  * To avoid gluing the UI to the bezel, we add a **4-line native breathing room** at the top. The bottom naturally gets a similar padding. Our target display window is now 224 lines.
  * *Fractional Calculation:* We scale these 224 lines to perfectly fit the 640p screen (640 / 224 = ~2.857x scale).
  * Applying this scale to the full 240 native lines gives us a total viewport height of **686 pixels** (240 * 2.857).
* **Vertical Crop (Asymmetric):**
  * We have an overflow of 46 pixels (686 - 640).
  * Top crop: 11 physical pixels (exactly ~4 native lines). We set Y-offset to `-11`.
  * The top screen edge now starts at native line 4, leaving exactly 4 lines of breathing room before the HUD starts at line 8.
  * Bottom crop automatically becomes the remainder: 35 pixels (~12 native lines). The bottom screen edge stops at line 228, leaving a 5-line breathing room below the HUD (which ends at 223).
  * *Verdict:* The UI breathes perfectly, and the worst 4 lines of top artifacts and 12 lines of bottom garbage are safely hidden.
* **X-Axis (Horizontal):** 
  * PAR 1:1 Width at this scale: 256 * 2.857 = **731 pixels**.
  * 4:3 Historical Width at this scale: 686 * (4/3) = **915 pixels**.
  * *Cathodic Correction:* Midpoint between 731 and 915 = **823 pixels**. 
* **X-Offset:** (960 - 823) / 2 = 68.5. We use an X offset of `68`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely on the shader's internal interpolation.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Breathing Room Implemented:** The -11 Y-offset is meticulously chosen to hide half of the overscan garbage while preserving the other half to gracefully frame the HUD.

**Configuration File (`nes.cfg`)**

```ini
aspect_ratio_index = "23"
custom_viewport_width = "823"
custom_viewport_height = "686"
custom_viewport_x = "68"
custom_viewport_y = "-11"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### NEC PC Engine / TurboGrafx-16 (`pcengine`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p (Horizontal varies: 256, 320, 336).
* **Objective:** Fractional Scaling (Rule 2) with exact same vertical breathing room as the NES, combined with horizontal Cathodic Correction to unify the console's variable resolutions.

**Mathematical Logic (Scenario B & Rule 2)**

* **Y-Axis (Vertical) & Breathing Room:** 
  * Identical to the NES. The safe HUD window is 216 lines. Adding breathing room gives a 224-line target window, resulting in a ~2.857x scale.
  * 240 total native lines * 2.857x = **686 pixels** total viewport height.
* **Vertical Crop (Asymmetric):**
  * Top crop: 11 physical pixels (~4 native lines). Y-offset is `-11`.
  * The bottom crop organically becomes the 35-pixel remainder, hiding the 12 worst garbage lines while keeping a 5-line padding below the HUD.
* **X-Axis (Horizontal):** 
  * To unify the dynamically shifting horizontal resolutions, we lock the width to the exact same Cathodic Correction midpoint calculated for the base 256x240 mode of the NES: **823 pixels**.
* **X-Offset:** We use an X offset of `68`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** Integer CRT alignment is abandoned in favor of perfect screen height utilization.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Unified Horizontal Viewport:** Forcing the width to 823px prevents the emulator's viewport from wildly resizing during gameplay when the internal dot clock changes.

**Configuration File (`pcengine.cfg`)**

```ini
aspect_ratio_index = "23"
custom_viewport_width = "823"
custom_viewport_height = "686"
custom_viewport_x = "68"
custom_viewport_y = "-11"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Arcade (FinalBurn Neo) / Neo-Geo / CPS (`fbneo`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 224p Vertical (Horizontal resolution wildly varies: 256, 320, 384).
* **Objective:** Fractional Scaling (Rule 2) with zero vertical cropping, combined with a unified horizontal "Under-Compression" (Scenario C) to tame the chaotic arcade resolutions into a single, beautiful standard.

**Mathematical Logic (Scenario C & Rule 2)**

* **Y-Axis (Vertical):** 
  * A 3x integer scale requires 672 pixels, which forces a 32-pixel crop on the 640p screen.
  * Our HUD footprint analysis strictly forbids this: Arcade hardware like the Neo-Geo (LSPC) and Capcom Play System (CPS-1/2/3) push vital UI elements (health bars, credit counters) to the absolute extreme edges (Line 0 and Line 223). Cropping even a single line is destructive.
  * *Fractional Calculation:* We abandon integer scaling. The raw 224 active lines are fractionally stretched to perfectly fill the 640 pixels of the KPA screen (a ~2.857x scale). Zero crop is applied.
* **Vertical Crop (Zero Margin):** 
  * Top crop: 0 pixels. Y-offset is `0`.
  * Bottom crop: 0 pixels. 
  * *Verdict:* 100% of the screen height is utilized, and 100% of the HUD is mathematically preserved.
* **X-Axis (Horizontal):** 
  * Arcade boards generated wildly different widths (256px, 320px, 384px) but all operators adjusted their CRT monitor potentiometers to squish or stretch the image into a standard 4:3 box.
  * On a 640p height, a strict 4:3 arcade aspect ratio is 853px wide. 
  * *Under-Compression (The Cheat):* Instead of crushing wide sprites (CPS) down to 853px or heavily stretching narrow ones, we set a unified compromise width of **896 pixels**. 
  * Why 896px? It slightly under-compresses CPS games (giving them a bit more room to breathe on the 3:2 screen), applies a gentle nostalgic stretch to 256px games, and provides a near-perfect 1:1 Pixel Aspect Ratio for Neo-Geo (320px) games. It is the ultimate unified Arcade width.
* **X-Offset:** (960 - 896) / 2 = 32. We use an X offset of `32`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** Integer CRT alignment is abandoned. We rely entirely on the shader's interpolation to handle the scanlines over the 640p height.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Zero Crop Oversight:** Absolutely no overscan cropping is allowed, preserving the extreme edges of the arcade HUDs.

**Configuration File (`fbneo.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "32"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Sony PlayStation (`psx`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p (Standard 320x240 resolution).
* **Objective:** Fractional Scaling (Rule 2) with a perfectly balanced vertical breathing room for the HUD, combined with a horizontal Nostalgia Stretch (Scenario A).

**Mathematical Logic (Scenario A & Rule 2)**

* **Y-Axis (Vertical) & Breathing Room:** 
  * The strict HUD footprint sits between lines 8 and 231 (224 active lines). 
  * To avoid gluing the UI to the physical bezel, we add a **4-line native breathing room** at the top and bottom. Our target display window is now 232 lines (from line 4 to 235).
  * *Fractional Calculation:* We scale these 232 lines to perfectly fit the 640p screen (640 / 232 = ~2.758x scale).
  * Applying this scale to the full 240 native lines gives us a total viewport height of **662 pixels** (240 * 2.758).
* **Vertical Crop (Symmetric):**
  * We have an overflow of 22 pixels (662 - 640). We divide this equally.
  * Top crop: 11 physical pixels (exactly 4 native lines). Y-offset is `-11`.
  * Bottom crop: 11 physical pixels.
  * *Verdict:* The screen starts at native line 4. The HUD begins at native line 8. The UI has a perfect, comfortable 11-pixel physical breathing room on the KPA screen.
* **X-Axis (Horizontal):** 
  * A mathematically perfect 4:3 aspect ratio based on our new 662p height requires a width of **883 pixels** (662 * 4/3). 
  * *Nostalgia Stretch (The Cheat):* Stretching 883px to the full 960px width would require an 8.7% stretch, bordering on an Aspect Ratio Crime. To stay true to our ~5% doctrine, we stretch 883px by exactly 5%, resulting in **927 pixels**. (Let's round to an even **928 pixels** for symmetry).
  * This leaves a very thin, unobtrusive 16-pixel black bar on each side, perfectly balancing maximum screen real estate and geometric integrity.
* **X-Offset:** (960 - 928) / 2 = 16. We use an X offset of `16`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely on the shader's internal interpolation to draw the scanlines over the 662p fractionally scaled vertical axis.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Breathing Room Implemented:** The -11 Y-offset is specifically calculated to crop only half of the overscan garbage, purposefully leaving the other half to frame the HUD.

**Configuration File (`psx.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "928"
custom_viewport_height = "662"
custom_viewport_x = "16"
custom_viewport_y = "-11"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Sega Saturn (`saturn`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p (Horizontal varies: mostly 320 or 352).
* **Objective:** Fractional Scaling (Rule 2) with a perfectly balanced vertical breathing room for the HUD, combined with a horizontal Nostalgia Stretch (Scenario A). 

**Mathematical Logic (Scenario A & Rule 2)**

* **The 32-Bit Unification:** The Sega Saturn shares the exact same 240p vertical output structure and the same 8-line safe croppable margin as the Sony PlayStation. Because of this, we can mathematically mirror the PS1 configuration. This has a massive secondary benefit: just like the PC Engine, the Saturn often switches horizontal resolutions (from 320 to 352, and sometimes 704 for high-res menus). By locking a fixed viewport based on a 4:3 ratio, we elegantly unify all these modes into a single, stable display.
* **Y-Axis (Vertical) & Breathing Room:** 
  * The strict HUD footprint sits between lines 8 and 231. 
  * We integrate a **4-line native breathing room** at the top and bottom. Our target display window is 232 lines.
  * *Fractional Calculation:* Scaling these 232 lines to perfectly fit the 640p screen (640 / 232 = ~2.758x scale).
  * 240 native lines * 2.758x = **662 pixels** total viewport height.
* **Vertical Crop (Symmetric):**
  * Overflow: 22 pixels (662 - 640). 
  * Top crop: 11 physical pixels (exactly 4 native lines). Y-offset is `-11`.
  * Bottom crop: 11 physical pixels. 
  * *Verdict:* The UI breathes beautifully with an 11-pixel physical padding on both the top and bottom edges of the KPA screen.
* **X-Axis (Horizontal):** 
  * A mathematically perfect 4:3 aspect ratio based on the 662p height requires a width of **883 pixels** (662 * 4/3). 
  * *Nostalgia Stretch (The Cheat):* We apply the exact same 5% stretch as the PS1 to eat up the pillarboxes without crossing into an Aspect Ratio Crime. 883 * 1.05 = **927 pixels** (rounded to an even **928 pixels**).
  * This unifies 320px arcade ports (like *Street Fighter Alpha 3*) and 352px exclusives (like *Panzer Dragoon*) into a single, cohesive, wide screen experience with only minimal 16px black bars on the sides.
* **X-Offset:** (960 - 928) / 2 = 16. We use an X offset of `16`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely on the shader's internal interpolation.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Unified Horizontal Viewport:** Locks the wildly varying Saturn resolutions (320 / 352 / 704) into a stable frame that won't resize itself mid-game.

**Configuration File (`saturn.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "928"
custom_viewport_height = "662"
custom_viewport_x = "16"
custom_viewport_y = "-11"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Nintendo 64 (`n64`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p (Standard 320x240, with some interlaced 480i menus handled dynamically by the core).
* **Objective:** Fractional Scaling (Rule 2) capitalizing on the N64's unusually large vertical margins to provide perfect HUD breathing room, combined with a horizontal Nostalgia Stretch (Scenario A) that almost entirely fills the screen.

**Mathematical Logic (Scenario A & Rule 2)**

* **Y-Axis (Vertical) & Breathing Room:** 
  * According to our HUD doctrine, the Nintendo 64 has a massive 10-line croppable margin. The strict UI footprint sits tightly compressed between lines 10 and 229. 
  * We integrate our standard **4-line native breathing room** at the top and bottom. This means we want our display window to cover lines 6 to 233, resulting in a target display window of 228 lines.
  * *Fractional Calculation:* We scale these 228 lines to perfectly fit the 640p screen (640 / 228 = ~2.807x scale).
  * Applying this scale to the full 240 native lines gives us a total viewport height of **674 pixels** (240 * 2.807).
* **Vertical Crop (Symmetric):**
  * We have an overflow of 34 pixels (674 - 640). 
  * Top crop: 17 physical pixels (~6 native lines). Y-offset is `-17`.
  * Bottom crop: 17 physical pixels.
  * *Verdict:* By cropping 6 native lines, we safely eliminate the overscan garbage, and the screen starts exactly at line 6. This leaves a flawless 4-line padding before the HUD starts at line 10.
* **X-Axis (Horizontal):** 
  * A mathematically perfect 4:3 aspect ratio based on the 674p height requires a width of **899 pixels** (674 * 4/3). 
  * *Nostalgia Stretch (The Cheat):* Applying our standard 5% stretch to eat up the pillarboxes yields **944 pixels** (899 * 1.05). 
  * This is a fantastic result for the KPA: 944 pixels covers almost the entirety of the 960px screen, leaving an incredibly thin, nearly imperceptible 8-pixel black border on each side. It maximizes screen real estate while keeping sprite distortion strictly within the acceptable limits.
* **X-Offset:** (960 - 944) / 2 = 8. We use an X offset of `8`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely on the core's internal rendering or the shader's interpolation. (Note: N64 emulation often utilizes hardware rendering depending on the core, but forcing these viewport coordinates ensures the geometry remains bound to our CRT doctrine rules).
2. **Disable Global Integer Scaling:** Mandatory.
3. **Breathing Room Implemented:** The -17 Y-offset leverages the N64's generous 10-line safe area to crop the absolute worst 6 lines of overscan while maintaining perfect UI padding.

**Configuration File (`n64.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "944"
custom_viewport_height = "674"
custom_viewport_x = "8"
custom_viewport_y = "-17"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Commodore Amiga (`amiga` / `puae`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 256p (Standard PAL 320x256 resolution).
* **Objective:** Fractional Scaling (Rule 2) to compress the tall European PAL video signal into the 640p screen, utilizing the 8-line croppable margin to inject our standard breathing room, combined with a horizontal Nostalgia Stretch (Scenario A).

**Mathematical Logic (Scenario A & Rule 2)**

* **The PAL Challenge:** Unlike NTSC consoles that output 224 or 240 lines, the Amiga natively outputs a taller 256-line PAL signal. Attempting an integer scale of 3x would result in 768 pixels, requiring a massive 128-pixel crop that would obliterate the UI of almost every game. 
* **Y-Axis (Vertical) & Breathing Room:** 
  * According to our HUD footprint doctrine, major Amiga action titles and centered pinball tables keep their dashboards safely between lines 8 and 247 (240 active lines).
  * We integrate our **4-line native breathing room** at the top and bottom. This sets our target display window to 248 lines (from line 4 to 251).
  * *Fractional Calculation:* We scale these 248 lines to perfectly fit the 640p screen (640 / 248 = ~2.58x scale).
  * Applying this scale to the full 256 native lines gives us a total viewport height of **660 pixels** (256 * 2.58).
* **Vertical Crop (Symmetric):**
  * We have an overflow of 20 pixels (660 - 640). We divide this equally.
  * Top crop: 10 physical pixels (~4 native lines). Y-offset is `-10`.
  * Bottom crop: 10 physical pixels.
  * *Verdict:* The screen edge starts perfectly at native line 4, leaving exactly 4 lines of breathing room before the HUD begins at line 8. The Amiga's tall PAL resolution is perfectly tamed.
* **X-Axis (Horizontal):** 
  * Because Amiga games were designed for 4:3 CRT monitors, the base mathematically perfect 4:3 aspect ratio calculated from our 660p height requires a width of **880 pixels** (660 * 4/3). 
  * *Nostalgia Stretch (The Cheat):* To eat up the pillarboxes, we apply our standard 5% stretch to the 880px width. 880 * 1.05 = **924 pixels**.
  * This beautifully fills the KPA screen, leaving only two unobtrusive 18-pixel black bars on the sides, while completely preserving the roundness of sprites within our tolerance threshold.
* **X-Offset:** (960 - 924) / 2 = 18. We use an X offset of `18`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely entirely on the shader's internal interpolation to draw scanlines over the 660p fractionally scaled vertical axis.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Breathing Room Implemented:** The -10 Y-offset perfectly hides half of the 8-line overscan margin, leaving the remaining 4 lines to naturally frame the UI.

**Configuration File (`amiga.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "924"
custom_viewport_height = "660"
custom_viewport_x = "18"
custom_viewport_y = "-10"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### 6th Gen & Modern 4:3 Systems (`dreamcast`, `ps2`, `gc`, `wii`)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 480i / 480p (Standard 4:3).
* **Objective:** Fractional Scaling (Rule 2) with absolutely zero vertical crop, leveraging the built-in UI safe zones of modern 3D engines, combined with our standard Nostalgia Stretch (Scenario A).

**Mathematical Logic (Scenario A & Rule 2)**

* **The 480p Reality:** By the 6th generation, UI elements were pushed much closer to the physical edges of the screen, and the concept of analog overscan garbage essentially disappeared. The strict HUD footprint covers the entire 480-line signal. Cropping is forbidden.
* **Y-Axis (Vertical):** 
  * Integer scaling is physically impossible (480 x 2 = 960, overflowing the 640p screen massively).
  * *Fractional Calculation:* We scale the raw 480 native lines to perfectly fill the 640p height (640 / 480 = 1.333x scale).
* **Vertical Crop (Zero Margin):**
  * Top crop: 0 pixels. Y-offset is `0`.
  * Bottom crop: 0 pixels.
  * *Verdict:* The entire 480-line frame is preserved. Modern 3D engines have internal padding, so the UI breathes naturally on its own without requiring us to inject custom margins.
* **X-Axis (Horizontal):** 
  * A mathematically perfect 4:3 aspect ratio based on the 640p height requires a width of **853 pixels**.
  * *Nostalgia Stretch (The Cheat):* We apply our standard 5% stretch to eat up the pillarboxes. 853 * 1.05 = **896 pixels**.
  * Note on 3D graphics: Because these consoles rely on polygonal 3D models with dynamic cameras rather than static 2D pixel art, the brain is even less sensitive to a 5% horizontal stretch (the "Aspect Ratio Crime" is heavily mitigated). This 896px width beautifully balances 4:3 nostalgia with the KPA's 3:2 screen, leaving only two 32-pixel black bars.
* **X-Offset:** (960 - 896) / 2 = 32. We use an X offset of `32`.

**Configuration Rules**

1. **Fractional Scaling Accepted:** We rely completely on the emulator core's internal upscaling or the shader's interpolation.
2. **Disable Global Integer Scaling:** Mandatory.
3. **Widescreen Hacks Alternative:** If you use 16:9 widescreen hacks within the emulator cores, you must abandon this 4:3 config. A native 16:9 image on the KPA requires filling the 960px width, resulting in a 540px height (leaving 50px black bars on the top and bottom).

**Configuration File (`dreamcast.cfg` / `ps2.cfg` / `gc.cfg` / `wii.cfg`)**
*(Place this in your config override folder. The `aspect_ratio_index = "23"` forces RetroArch to use the Custom coordinate block).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "32"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```
## Real-World Display Metrics (Surface Area vs. Perceived Size)

When dealing with mixed aspect ratios, measuring screen size by diagonal alone is mathematically misleading. A 3.5-inch 3:2 screen does not display a 4:3 image the same way a 3.5-inch 4:3 screen would. To truly evaluate our configurations, we must look at two distinct metrics: the **Visible Surface Area** (how much of the KPA screen is physically lit up) and the **Perceived Sprite Size** (the equivalent 4:3 display required to render sprites at this exact physical scale).

For reference, the Konkr Pocket Advance features a **3.5-inch, 3:2 screen**:
* Physical Height: ~1.94 inches (4.93 cm)
* Physical Width: ~2.91 inches (7.40 cm)
* **Total Physical Surface Area:** ~5.65 sq inches (**36.48 cm²**)

### 1. Visible Surface Utilization

Because every configuration in our doctrine is engineered to perfectly fill 100% of the KPA's 640-pixel vertical height, the physical surface area utilization is directly proportional to the horizontal width we defined. This table shows how much of your actual console screen is being used.

| System / Configuration | Visible Pixels | Target Aspect Ratio | Surface Coverage | Physical Area (cm²) | Resulting Diagonal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Konkr Pocket Advance (Max)** | 960 x 640 | 1.50 (3:2) | **100 %** | 36.48 cm² | 3.50" |
| **Mega Drive** | 960 x 640 | 1.50 (3:2) | **100 %** | 36.48 cm² | 3.50" |
| **N64** | 944 x 640 | 1.47 (59:40) | **98.3 %** | 35.87 cm² | 3.46" |
| **PS1 / Saturn** | 928 x 640 | 1.45 (29:20) | **96.7 %** | 35.26 cm² | 3.42" |
| **Amiga** | 924 x 640 | 1.44 (~13:9) | **96.2 %** | 35.11 cm² | 3.41" |
| **Arcade / Master System / 6th Gen** | 896 x 640 | 1.40 (7:5) | **93.3 %** | 34.04 cm² | 3.34" |
| **Super Nintendo** | 832 x 640 | 1.30 (13:10) | **86.7 %** | 31.61 cm² | 3.18" |
| **NES / PC Engine** | 823 x 640 | 1.28 (~9:7) | **85.7 %** | 31.27 cm² | 3.16" |

### 2. Perceived Sprite Size (The 4:3 Equivalent)

The table above only tells half the story. Because we purposefully crop the top and bottom margins (pushing them outside the physical bezel), the game is rendered at a much larger scale than the KPA screen can fully display. 

To evaluate the true "Perceived Size" of the gameplay, we must calculate the surface area of the **Full Viewport** (including the hidden overscan areas, but preserving our horizontal stretch). This theoretical area tells us how big a screen would need to be to display our zoomed-in image in its entirety. By converting this theoretical area into a standard 4:3 diagonal, we reveal the ultimate benefit of this doctrine: **how big the sprites actually look to your eyes.**

| System | Full Scaled Viewport (incl. crop) | Viewport Ratio | Theoretical Surface (cm²) | Equivalent 4:3 Screen Diagonal |
| :--- | :--- | :--- | :--- | :--- |
| **Mega Drive** | 960 x 672 | 1.42 (~10:7) | 38.30 cm² | **3.52"** |
| **N64** | 944 x 674 | 1.40 (7:5) | 37.78 cm² | **3.49"** |
| **PS1 / Saturn** | 928 x 662 | 1.40 (7:5) | 36.48 cm² | **3.43"** |
| **Amiga** | 924 x 660 | 1.40 (7:5) | 36.21 cm² | **3.42"** |
| **Arcade / SMS / 6th Gen** * | 896 x 640 | 1.40 (7:5) | 34.04 cm² | **3.32"** |
| **NES / PC Engine** | 823 x 686 | 1.20 (~6:5) | 33.52 cm² | **3.29"** |
| **Super Nintendo** | 832 x 672 | 1.23 (~11:9) | 33.20 cm² | **3.27"** |

*\* Since Arcade, Master System, and 6th-gen consoles utilize a Zero Margin configuration (no vertical cropping), their visible surface and full viewport surface are perfectly identical.*

**The 3:2 Cheat Code:**
Look closely at the Mega Drive. The Konkr Pocket Advance only has a 3.5" diagonal. However, because the 3:2 aspect ratio is physically wider, it allows us to aggressively zoom in vertically while still capturing the full horizontal width. The result? **Playing Mega Drive on the 3.5" KPA provides sprites that are physically as large as if you were playing on a 3.52" standard 4:3 screen.** 

Even the systems with the heaviest Cathodic Correction (Super Nintendo) deliver sprites equivalent to a ~3.3" 4:3 screen, completely negating the usual letterboxing penalty associated with playing 4:3 content on a 3:2 display.
