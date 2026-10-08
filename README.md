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

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x192.
- **Objective:** Fractional Scaling (Rule 2) with zero vertical cropping to respect the rigid HUD, combined with a horizontal Nostalgia Stretch (Scenario A) to minimize pillarboxing.

**Mathematical Logic (Scenario A & Rule 2)**

- **Y-Axis (Vertical):** 
  - The Master System's 192-line active window leaves absolutely zero croppable margin. Every line contains critical UI data or gameplay.
  - A 3x integer scale yields 576 pixels (leaving a massive 64px of dead black space vertically).
  - A 4x integer scale yields 768 pixels (forcing a 128px crop that would completely obliterate the HUD).
  - *Fractional Calculation:* We abandon integer scaling. The raw 192 lines are fractionally scaled to perfectly fill the 640 pixels of the KPA screen height (a ~3.333x scale). 
- **Vertical Crop (Auto-Centered):**
  - Overflow: 0 pixels (640 - 640).
  - By leaving the Y-offset at `0`, the 640p image perfectly aligns with the physical screen. 
  - *Verdict:* 100% of the screen height is utilized, and 100% of the HUD remains untouched.
- **X-Axis (Horizontal):** 
  - A mathematically perfect 1:1 Pixel Aspect Ratio based on the 640p viewport height requires a width of **853 pixels**. 
  - *Nostalgia Stretch (The Cheat):* To eat up the side pillarboxes without committing an Aspect Ratio Crime, we apply a precise 5% stretch. 853 * 1.05 = **896 pixels**.
  - This optimally fills the width while keeping sprite distortion entirely imperceptible.
- **Offsets:** We use `0` for both X and Y, allowing the 0.5 Anchor Bias to perfectly auto-center the 896x640 viewport, naturally leaving two symmetrical 32-pixel black bars on the sides.

**Configuration Rules (GUI Method)**

To apply these settings directly through the RetroArch interface, navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow fractional stretching and custom heights).
2. **Aspect Ratio:** `Custom` (This exposes the manual viewport coordinates below).
3. **Custom Aspect Ratio (X Position):** `0` (Maintains perfect auto-centering).
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896`
6. **Custom Aspect Ratio (Height):** `640`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`mastersystem.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Nintendo Entertainment System (`nes`) & NEC PC Engine (`pcengine`)

Since both the NES and PC Engine share a native 240-line vertical resolution and benefit from identical horizontal treatment, their configuration doctrines are unified. 

**Core Selection & Preparation**

Before setting the RetroArch Viewport, you must ensure both cores send the full, uncropped raw video signal to RetroArch so our mathematical auto-centering works perfectly.
- **NES (Mesen):** Open Quick Menu > Core Options > Video. Set `Left/Right/Top/Bottom Overscan` to `None`. Set `Aspect Ratio` to `No stretching` (or `Auto`). *Recommended:* Enable `Remove sprite limit` to fix historical flickering.
- **PC Engine (Beetle PCE):** Open Quick Menu > Core Options > Video. Ensure any core-specific cropping options (like `Crop Overscan` or custom `Initial/Last Scanline` ranges) are disabled to output the full raw 240-line image.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x240 (NES) / Dynamically shifting x240 (PC Engine).
- **Objective:** Fractional Scaling (Rule 2) capitalizing on symmetric auto-centering to seamlessly crop the universal 8-line vertical overscan garbage on both systems, combined with a unified horizontal Cathodic Correction (Scenario B) to tame the PCE's shifting resolutions and perfect the NES aspect ratio.

**Mathematical Logic (Scenario B & Rule 2)**

- **Y-Axis (Vertical):** 
  - Both consoles output 240 native lines, with the top 8 and bottom 8 lines traditionally acting as an overscan buffer. The pristine "action zone" is 224 lines.
  - *Fractional Calculation:* We apply a ~2.857x scale to make these 224 lines perfectly fill the 640p KPA physical screen.
  - Applying this scale to the full 240-line signal gives a total viewport height of **686 pixels** (240 * 2.857).
- **Vertical Crop (Auto-Centered):**
  - Overflow: 46 pixels (686 - 640).
  - By leaving the Y-offset at `0`, the 0.5 Anchor Bias centers the 686p image symmetrically.
  - Top crop: 23 physical pixels (exactly ~8 native lines).
  - Bottom crop: 23 physical pixels (exactly ~8 native lines).
  - *Verdict:* A mathematical miracle for both systems. The auto-centering perfectly slices off the 8-line vertical overscan garbage without decapitating HUDs.
- **X-Axis (Horizontal) & The Resolution Lock:** 
  - For the NES, a perfect PAR width is 732px, while the historical 4:3 stretch is 915px. The Cathodic Correction midpoint is **824 pixels**.
  - For the PC Engine, horizontal resolution dynamically changes on the fly (e.g., switching from 256 to 336). If unconstrained, the emulator will violently stretch and shrink the screen.
  - *Unified Solution:* We lock the width for both systems to **824 pixels**. This gives the NES its perfect nostalgic stretch while forcing all PCE horizontal modes into a single, stable, geometrically pleasing frame.
- **Offsets:** We use `0` for both X and Y to let RetroArch perfectly auto-center the fixed 824x686 viewport.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `824`
6. **Custom Aspect Ratio (Height):** `686`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration Files (`nes.cfg` & `pcengine.cfg`)**
*(If you prefer manual file editing, place this identical block in both config override files).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "824"
custom_viewport_height = "686"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Arcade (FinalBurn Neo) / Neo-Geo / CPS (`fbneo`)

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 224p Vertical (Horizontal resolution wildly varies: 256, 320, 384).
- **Objective:** Fractional Scaling (Rule 2) with absolute zero vertical cropping to protect extreme-edge UI elements, combined with an auto-centered horizontal 4:3 base expanded by a 5% Nostalgia Stretch.

**Mathematical Logic (Nostalgia Stretch & Rule 2)**

- **Y-Axis (Vertical):** 
  - Arcade hardware like the Neo-Geo (MVS) and Capcom Play System (CPS-1/2/3) push vital UI elements (health bars, credit counters) to the absolute extreme edges of their 224-line active output. Cropping even a single line is destructive.
  - *Fractional Calculation:* We abandon integer scaling. The raw 224 active lines are fractionally stretched to perfectly fill the 640 pixels of the KPA physical screen (a ~2.857x scale). 
- **Vertical Crop (Zero Margin Auto-Centered):**
  - Overflow: 0 pixels (640 - 640).
  - By leaving the Y-offset at `0`, the 640p image perfectly matches the physical screen height. 
  - *Verdict:* 100% of the screen height is utilized, and 100% of the HUD is mathematically preserved across thousands of heterogeneous arcade boards.
- **X-Axis (Horizontal) & The 5% Expansion:** 
  - Arcade boards generated wildly different native widths (e.g., 256px for early classics, 320px for Neo-Geo, 384px for CPS), but all operators adjusted their CRT monitor potentiometers to squish or stretch the image into a standard 4:3 physical box.
  - On a 640p height, a strict 4:3 arcade aspect ratio yields a width of **853 pixels**.
  - *Nostalgia Stretch:* To eat up the side pillarboxes without committing an Aspect Ratio Crime, we apply a precise 5% expansion beyond the historical 4:3 frame. 853 * 1.05 = **896 pixels**.
  - This perfectly unifies all varying arcade resolutions into a single, beautiful standard that flatters the 3:2 screen while respecting CRT proportions.
- **Offsets:** We use `0` for both X and Y, allowing the 0.5 Anchor Bias to perfectly auto-center the unified 896x640 viewport.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow fractional stretching and custom heights).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896`
6. **Custom Aspect Ratio (Height):** `640`

*(Note: Absolutely ensure **Crop Overscan** is set to `OFF`. Arcade hardware does not generate standard console overscan garbage; the raw signal is the intended active area. Automated cropping will mutilate extreme-edge UI).*

**Configuration File (`fbneo.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Sony PlayStation 1 (`psx`) & Sega Saturn (`saturn`)

Both 32-bit pioneers operate under identical display philosophies. They heavily rely on 3D geometry authored specifically for 4:3 televisions, and they notoriously switch resolutions on the fly.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** Dynamically shifting 240p (Gameplay) and 480i (Menus/FMVs), with wildly varying horizontal resolutions (e.g., 320, 368, 512, 640).
- **Objective:** Fractional Scaling (Rule 2) using a rigid, fixed Viewport to trap and neutralize the violent internal resolution shifting, combined with a 4:3 base expanded by a gentle 5% Nostalgia Stretch to preserve 3D geometry.

**Mathematical Logic (Nostalgia Stretch & Rule 2)**

- **Y-Axis (Vertical) & The Resolution Lock:** 
  - Games like *Chrono Cross*, *Resident Evil*, or *Silent Hill* constantly swap between 240p for gameplay and 480i for menus. If left dynamic, the emulator will glitch, resize, or drop signal during these transitions.
  - *Fractional Fixed Height:* By locking the Custom Viewport strictly to the KPA's physical **640 pixels** of height, RetroArch forces both 240p and 480i signals to scale seamlessly into the exact same unmoving vertical space. 
- **Vertical Crop (Zero Margin Auto-Centered):**
  - Overflow: 0 pixels.
  - Offsets: By leaving the Y-offset at `0`, the image perfectly matches the physical screen. No cropping occurs, which is vital as 32-bit games rarely used consistent overscan garbage zones.
- **X-Axis (Horizontal) & 3D Geometry:** 
  - Unlike 16-bit 2D sprites, 32-bit 3D models (wheels in *Gran Turismo*, spheres, architecture) were mathematically projected to look correct on a 4:3 Display Aspect Ratio (DAR). Over-stretching ruins 3D proportions instantly.
  - On a 640p height, a geometrically flawless 4:3 width is **854 pixels**.
  - *Nostalgia Stretch:* To reduce pillarboxing without blatantly turning 3D wheels into ovals, we apply the same 5% expansion used for our Arcade doctrine: 854 * 1.05 = **896 pixels**.
- **Offsets:** We use `0` for both X and Y, allowing the 0.5 Anchor Bias to perfectly auto-center the unified 896x640 viewport.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow the rigid fractional box).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896`
6. **Custom Aspect Ratio (Height):** `640`

*(Note: Ensure **Crop Overscan** is set to `OFF`. The fixed Custom Viewport acts as an absolute container; automatic cropping will disrupt the stability of the 480i menu transitions).*

**Configuration Files (`psx.cfg` & `saturn.cfg`)**
*(If you prefer manual file editing, place this identical block in both config override files).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Nintendo 64 (`n64`)

**Core Selection & Preparation**

Before setting the RetroArch Viewport, ensure the core (e.g., Mupen64Plus-Next or ParaLLEl N64) is outputting the raw, untampered video signal.
- Open Quick Menu > Core Options.
- Ensure any internal aspect ratio settings are set to `Original` or `4:3` (strictly avoid widescreen hacks or "Adjust" settings), and any core-level overscan cropping is disabled. The Custom Viewport will handle all geometry mathematically.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 240p / 480i (Standard 320x240, dynamically switching during menus).
- **Objective:** Fractional Scaling (Rule 2) capitalizing on the N64's generous vertical margins for auto-centered symmetric cropping, combined with a horizontal Nostalgia Stretch (Scenario A) that almost entirely fills the physical screen.

**Mathematical Logic (Scenario A & Rule 2)**

- **Y-Axis (Vertical) & Breathing Room:** 
  - The N64 features a massive 10-line croppable margin at both the top and bottom. The strict UI footprint sits safely compressed between lines 10 and 229.
  - *Fractional Calculation:* To integrate our standard 4-line breathing room, we want to crop exactly 6 native lines. We scale the remaining 228 lines to perfectly fit the 640p screen (640 / 228 = ~2.807x scale).
  - Applying this scale to the full 240 native lines gives us a total viewport height of **674 pixels** (240 * 2.807).
- **Vertical Crop (Auto-Centered):**
  - Overflow: 34 pixels (674 - 640).
  - By leaving the Y-offset at `0`, the 0.5 Anchor Bias centers the 674p image symmetrically.
  - Top crop: 17 physical pixels (exactly ~6 native lines).
  - Bottom crop: 17 physical pixels (exactly ~6 native lines).
  - *Verdict:* The auto-centering automatically slices off the worst 6 lines of overscan. The screen starts exactly at native line 6, leaving a flawless 4-line padding before the HUD begins at line 10.
- **X-Axis (Horizontal):** 
  - A mathematically perfect 4:3 aspect ratio based on the 674p height requires a width of **899 pixels** (674 * 4/3). 
  - *Nostalgia Stretch (The Cheat):* Applying our standard 5% stretch to eat up the pillarboxes yields **944 pixels** (899 * 1.05). 
  - This produces a phenomenal result for the KPA: 944 pixels covers almost the entirety of the 960px screen, maximizing real estate while keeping 3D geometric distortion strictly within acceptable limits.
- **Offsets:** We use `0` for both X and Y. The auto-centering of the 944x674 viewport naturally creates two razor-thin, symmetrically perfect 8-pixel black borders on the left and right sides.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow custom fractional dimensions).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `944`
6. **Custom Aspect Ratio (Height):** `674`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`n64.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "944"
custom_viewport_height = "674"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

L'Amiga, avec son imposant signal vidéo PAL de 256 lignes, s'intègre avec une élégance absolue dans notre doctrine d'auto-centrage. Ton ancienne configuration avait déjà identifié les mathématiques parfaites (660 pixels de haut pour rogner 4 lignes), mais elle nécessitait de forcer manuellement les coordonnées.

En confiant le centrage à RetroArch (X et Y à 0), le débordement de 20 pixels est coupé en deux de manière parfaitement symétrique (10 pixels en haut, 10 en bas). À notre échelle fractionnelle, ces 10 pixels physiques correspondent très exactement aux 4 lignes natives que nous voulions sacrifier.

Voici la section définitive pour l'Amiga, épurée et optimisée :

```markdown
### Commodore Amiga (`amiga` / `puae`)

**Core Selection & Preparation (PUAE)**

The Amiga is a complex microcomputer, and the PUAE core contains its own internal zooming and cropping mechanics. To ensure our RetroArch Custom Viewport works perfectly, we must feed it the raw PAL signal.
- Open Quick Menu > Core Options > Video.
- Ensure any `Zoom`, `Crop`, or `Auto-Crop` settings are set to `None` or `Disabled`. The core must output the full 256-line PAL matrix without internal tampering.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256p (Standard PAL 320x256 resolution).
- **Objective:** Fractional Scaling (Rule 2) capitalizing on symmetric auto-centering to effortlessly tame the tall European PAL video signal, combined with a horizontal Nostalgia Stretch (Scenario A).

**Mathematical Logic (Scenario A & Rule 2)**

- **The PAL Challenge:** Unlike NTSC consoles that output 224 or 240 lines, the Amiga natively outputs a taller 256-line PAL signal. Attempting an integer scale of 3x would result in a 768-pixel height, requiring a massive 128-pixel crop that would obliterate the UI of almost every game.
- **Y-Axis (Vertical) & Breathing Room:** 
  - According to our HUD footprint doctrine, major Amiga action titles and centered pinball tables keep their dashboards safely between lines 8 and 247 (a 240-line active zone).
  - *Fractional Calculation:* We integrate our standard 4-line native breathing room at the top and bottom, setting our target display window to 248 lines. We fractionally scale these 248 lines to perfectly fit the 640p KPA screen (640 / 248 = ~2.58x scale).
  - Applying this scale to the full 256 native lines gives us a total viewport height of **660 pixels** (256 * 2.58).
- **Vertical Crop (Auto-Centered):**
  - Overflow: 20 pixels (660 - 640).
  - By leaving the Y-offset at `0` and relying on RetroArch's default `0.5` Anchor Bias, the 660p image centers itself symmetrically.
  - Top crop: 10 physical pixels (exactly ~4 native lines).
  - Bottom crop: 10 physical pixels (exactly ~4 native lines).
  - *Verdict:* The auto-centering flawlessly slices off the top and bottom 4 lines. The screen edge starts perfectly at native line 4, leaving exactly 4 lines of breathing room before the HUD begins at line 8. 
- **X-Axis (Horizontal):** 
  - Because Amiga games were designed for 4:3 CRT monitors, the base mathematically perfect 4:3 aspect ratio calculated from our 660p height requires a width of **880 pixels** (660 * 4/3). 
  - *Nostalgia Stretch (The Cheat):* To eat up the pillarboxes, we apply our standard 5% stretch to the 880px width: 880 * 1.05 = **924 pixels**.
  - This beautifully fills the KPA screen while completely preserving the roundness of sprites within our tolerance threshold.
- **Offsets:** We use `0` for both X and Y. The auto-centering of the 924x660 viewport naturally creates two unobtrusive, symmetrical 18-pixel black bars on the left and right sides.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow custom fractional dimensions).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `924`
6. **Custom Aspect Ratio (Height):** `660`

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`amiga.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "924"
custom_viewport_height = "660"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### 6th Gen & Modern 4:3 Systems (`dreamcast`, `ps2`, `gc`, `wii`)

**Core Selection & Preparation**

By the 6th generation, consoles output pristine digital or high-quality analog signals (480i/480p) with UI elements pushed to the physical edges.
- Ensure any core-specific widescreen (16:9) hacks are disabled if you intend to use this 4:3 CRT doctrine.
- Ensure the core's internal aspect ratio is set to output its native 4:3 frame to allow RetroArch's Custom Viewport to handle the final stretch.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 480i / 480p (Standard 4:3).
- **Objective:** Fractional Scaling (Rule 2) with absolutely zero vertical crop, leveraging the built-in UI safe zones of modern 3D engines, combined with an auto-centered horizontal Nostalgia Stretch (Scenario A).

**Mathematical Logic (Scenario A & Rule 2)**

- **The 480p Reality:** The concept of analog overscan garbage essentially disappeared in this era. The strict HUD footprint covers the entire 480-line signal. Cropping is forbidden.
- **Y-Axis (Vertical):** 
  - Integer scaling is physically impossible (480 x 2 = 960, which overflows the 640p screen massively).
  - *Fractional Calculation:* We scale the raw 480 native lines to perfectly fill the 640p physical height (640 / 480 = ~1.333x scale).
- **Vertical Crop (Zero Margin Auto-Centered):**
  - Overflow: 0 pixels.
  - By leaving the Y-offset at `0`, the 640p image perfectly matches the physical screen height. 
  - *Verdict:* The entire 480-line frame is preserved. Modern 3D engines have internal padding, so the UI breathes naturally on its own without requiring us to inject custom margins.
- **X-Axis (Horizontal):** 
  - A mathematically perfect 4:3 aspect ratio based on the 640p height requires a width of **853 pixels**.
  - *Nostalgia Stretch (The Cheat):* We apply our standard 5% stretch to eat up the pillarboxes: 853 * 1.05 = **896 pixels**.
  - *Note on 3D graphics:* Because these consoles rely on polygonal 3D models with dynamic cameras rather than static 2D pixel art, the brain is even less sensitive to a 5% horizontal stretch (the "Aspect Ratio Crime" is heavily mitigated). This 896px width beautifully balances 4:3 nostalgia with the KPA's 3:2 screen.
- **Offsets:** We use `0` for both X and Y. The 0.5 Anchor Bias perfectly auto-centers the 896x640 viewport, naturally leaving two symmetrical 32-pixel black bars on the left and right sides.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` (Must be disabled globally to allow custom fractional dimensions).
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896`
6. **Custom Aspect Ratio (Height):** `640`

*(Note: **Widescreen Hacks Alternative:** If you choose to enable 16:9 widescreen hacks within the emulator cores, you must abandon this 4:3 config. A native 16:9 image on the KPA requires filling the full 960px width, resulting in a 540px height and leaving 50px black bars on the top and bottom. Set Width to 960 and Height to 540).*

**Configuration File (`dreamcast.cfg` / `ps2.cfg` / `gc.cfg` / `wii.cfg`)**
*(If you prefer manual file editing, place this identical block in your config override folders).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```

## Real-World Display Metrics (Surface Area vs. Perceived Size)

When dealing with mixed aspect ratios, measuring screen size by diagonal alone is mathematically misleading. A 3.5-inch 3:2 screen does not display a 4:3 image the same way a 3.5-inch 4:3 screen would. To truly evaluate our configurations, we must look at two distinct metrics: the **Visible Surface Area** (how much of the KPA screen is physically lit up) and the **Perceived Sprite Size** (the equivalent 4:3 display required to render sprites at this exact physical scale).

For reference, the Konkr Pocket Advance features a **3.5-inch, 3:2 screen**:
- Physical Height: ~1.94 inches (4.93 cm)
- Physical Width: ~2.91 inches (7.40 cm)
- **Total Physical Surface Area:** ~5.65 sq inches (**36.48 cm²**)

### 1. Visible Surface Utilization

Because every configuration in our doctrine is engineered to perfectly fill 100% of the KPA's 640-pixel vertical height, the physical surface area utilization is directly proportional to the horizontal width we defined. This table shows how much of your actual console screen is being used and precisely quantifies the remaining pillarboxing.

| System / Configuration | Visible Pixels | Side Black Bar % | Target Aspect Ratio | Surface Coverage | Physical Area (cm²) | Resulting Diagonal |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Konkr Pocket Advance (Max)** | 960 x 640 | **0.0 %** | 1.50 (3:2) | **100 %** | 36.48 cm² | 3.50" |
| **Mega Drive** | 960 x 640 | **0.0 %** | 1.50 (3:2) | **100 %** | 36.48 cm² | 3.50" |
| **N64** | 944 x 640 | **0.8 %** | 1.48 (59:40) | **98.3 %** | 35.87 cm² | 3.46" |
| **Amiga** | 924 x 640 | **1.9 %** | 1.44 (~13:9) | **96.3 %** | 35.11 cm² | 3.41" |
| **Arcade / SMS / PS1 / Saturn / 6th Gen** | 896 x 640 | **3.3 %** | 1.40 (7:5) | **93.3 %** | 34.04 cm² | 3.34" |
| **Super Nintendo** | 832 x 640 | **6.7 %** | 1.30 (13:10) | **86.7 %** | 31.61 cm² | 3.18" |
| **NES / PC Engine** | 824 x 640 | **7.1 %** | 1.29 (~9:7) | **85.8 %** | 31.31 cm² | 3.16" |

*(Note: The "Side Black Bar %" represents the width of a single black bar—half of the total unlit space—relative to the 960-pixel physical width).*

### 2. Perceived Sprite Size (The 4:3 Equivalent)

The table above only tells half the story. Because we purposefully crop the top and bottom margins (pushing them outside the physical bezel), the game is rendered at a much larger scale than the KPA screen can fully display. 

To evaluate the true "Perceived Size" of the gameplay, we must calculate the surface area of the **Full Viewport** (including the hidden overscan areas, but preserving our horizontal stretch). This theoretical area tells us how big a screen would need to be to display our zoomed-in image in its entirety. By converting this theoretical area into a standard 4:3 diagonal, we reveal the ultimate benefit of this doctrine: **how big the sprites actually look to your eyes.**

| System | Full Scaled Viewport (incl. crop) | Viewport Ratio | Theoretical Surface (cm²) | Equivalent 4:3 Screen Diagonal |
| :--- | :--- | :--- | :--- | :--- |
| **N64** | 944 x 674 | 1.40 (7:5) | 37.78 cm² | **3.49"** |
| **Mega Drive** | 960 x 652 | 1.47 (~59:40) | 37.16 cm² | **3.46"** |
| **Amiga** | 924 x 660 | 1.40 (7:5) | 36.21 cm² | **3.42"** |
| **Arcade / SMS / PS1 / Saturn / 6th Gen** * | 896 x 640 | 1.40 (7:5) | 34.04 cm² | **3.32"** |
| **NES / PC Engine** | 824 x 686 | 1.20 (~6:5) | 33.56 cm² | **3.29"** |
| **Super Nintendo** | 832 x 672 | 1.24 (~11:9) | 33.20 cm² | **3.27"** |

*\* Since Arcade, Master System, PS1, Saturn, and 6th-gen consoles utilize a Zero Margin configuration (no vertical cropping), their visible surface and full viewport surface are perfectly identical.*

**The 3:2 Cheat Code:**
Look closely at the N64 and Mega Drive. The Konkr Pocket Advance only has a 3.5" diagonal. However, because the 3:2 aspect ratio is physically wider, it allows us to aggressively zoom in vertically while still capturing the near-full horizontal width. The result? **Playing N64 on the 3.5" KPA provides sprites that are physically as large as if you were playing on a ~3.5" standard 4:3 screen.** 

Even the systems with the heaviest Cathodic Correction (Super Nintendo, NES) deliver sprites equivalent to a ~3.3" 4:3 screen, completely negating the usual letterboxing penalty associated with playing 4:3 content on a 3:2 display.
