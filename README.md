> **NOTHING TESTED YET : STILL WAITING FOR MY KPA**

# Installation preparation for a Konkr Pocket Advance

> The recommendations and technical choices presented here are my own, and I may have made mistakes or oversights. Because English is not my native language, I used Gemini to translate, structure, and format my personal notes into this.

The KPA has an unusual 3:2 aspect ratio screen which a 640p resolution (960x640), which offers nice possibilities beyond plain integer scaled GBA.

## Retroarch Scaling

### SNES and Megadrive (224p)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 224p (e.g., SNES, Megadrive).
* **Objective:** 4:3 display combining strict vertical integer scaling (3x) and perfect CRT shader compatibility.

**Mathematical Logic**

* **Y-Axis (Vertical):** 224 x 3 = 672 pixels. Results in a 32-pixel overflow relative to the screen height (672 - 640).
* **X-Axis (Horizontal):** 672 x (4/3) = 896 pixels (non-integer multiplier).

**Configuration Rules**

1. **Disable Crop Overscan (Global and Core Options):** Essential to ensure the core sends the full raw 224-line signal to RetroArch without altering the base resolution.
2. **Disable Global Integer Scaling:** Mandatory to allow the non-integer horizontal scale needed to maintain the 4:3 proportions (the vertical axis is manually forced to an integer).
3. **Vertical Adjustment (Y-Offset) Calibrated for Shaders:** To avoid vertical shimmering and asymmetrical scanlines, the offset must align the game's pixel grid with the shader's grid. The negative Y value must be a multiple of the vertical scale factor (3x). A `-15` pixel offset crops exactly 5 full native lines at the top of the screen.

**Configuration File (.cfg)**
Since the RetroArch UI locks the Y value to a minimum of 0, the negative offset must be injected by manually editing the override file. The `aspect_ratio_index = "23"` value forces RetroArch to use the *Custom* coordinate block.

```ini
aspect_ratio_index = "23"
custom_viewport_width = "896"
custom_viewport_height = "672"
custom_viewport_x = "32"
custom_viewport_y = "-15"
video_scale_integer = "false"
video_crop_overscan = "false"
```

**Override Location (Content Directory Override)**
The text file must match the exact name of the targeted ROM folder and be placed in the corresponding core's subfolder:
`RetroArch/config/[Core_Name]/[ROM_Folder_Name].cfg`
*(Practical example for the Snes9x core and a ROM folder named `snes`: `RetroArch/config/Snes9x/snes.cfg`)*

### NES (not really 240p)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p Raw Output (NES).
* **Objective:** 4:3 display perfectly filling the screen horizontally, maintaining strict vertical integer scaling (3x), and ensuring perfect CRT shader alignment.

**Mathematical Logic & The "224p Safe Zone" Justification**
While the NES hardware outputs exactly 240 lines, developers designed games around a **224-line "Safe Zone"**. The top 8 and bottom 8 lines were intended to be hidden by the plastic bezels of 1980s CRT televisions (overscan) and often contain visual garbage, solid colors, or sprite pop-in artifacts.

* **Y-Axis (Vertical):** 240 x 3 = 720 pixels. This creates an 80-pixel overflow relative to your 640p screen height.
* **X-Axis (Horizontal):** 720 x (4/3) = 960 pixels. This perfectly fills the 960px width of your screen with zero black borders.
* **The Cropping Math (-39 Offset):** To align the CRT shader grid, the vertical offset must be a multiple of the 3x scale. A `-39` pixel offset at the top crops exactly 13 native lines (39 / 3 = 13).
* **Why this crop is perfect:** Of those 13 cropped lines, **8 are the intended overscan garbage**. You are only cropping **5 "useful" lines** from the 224p safe zone. Cropping these 5 additional lines perfectly simulates the physical bezel overlap of a vintage CRT TV. It allows you to maintain the 3x integer scale and CRT shaders on a 640p screen without losing any critical UI elements (which were placed safely toward the center).

**Configuration Rules**

1. **Disable Crop Overscan (Global and Core Options):** Crucial for NES cores (like Mesen, FCEUmm, or Nestopia) which often artificially hide 8 lines by default. The core must output the raw 240 lines so your manual `-39` math applies correctly from the absolute top edge.
2. **Disable Global Integer Scaling:** Mandatory so RetroArch allows the non-integer 4:3 horizontal scale (960px) and lets the vertical 720px overflow the physical screen.
3. **Vertical Adjustment (Y-Offset):** Must be exactly `-39`.

**Configuration File (.cfg)**
Since the RetroArch UI locks the Y value to a minimum of 0, the negative offset must be injected by manually editing the override file. The `aspect_ratio_index = "23"` value forces RetroArch to use the *Custom* coordinate block.

```ini
aspect_ratio_index = "23"
custom_viewport_width = "960"
custom_viewport_height = "720"
custom_viewport_x = "0"
custom_viewport_y = "-39"
video_scale_integer = "false"
video_crop_overscan = "false"
```

### Master system (192p)

For the Master System (192p) on a 640p display, vertical integer scaling forces unacceptable compromises:

* **Why not 4x:** Scaling to 768 pixels creates a 128-pixel vertical overflow. Cropping 16 native lines from both the top and bottom routinely destroys essential HUD elements like health bars, scores, and menus.
* **Why not 5x:** Scaling to 960 pixels creates a massive 320-pixel overflow. This amputates exactly one-third of the game's total visual area (32 native lines top and bottom), rendering games completely unplayable.

**Conclusion:** Since a 3x scale leaves large black borders and 4x/5x destroy vital gameplay information, strict vertical integer scaling is unviable. The most practical solution is to adopt **non-integer scaling** to fill the screen height. Because non-integer scales permanently break CRT shader alignment, you must disable scanlines entirely and apply a `sharp-bilinear-simple` interpolation shader across both axes to smooth out the resulting scrolling artifacts.

### PS1 & N64 (240p)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 240p Native 1x (with dynamic hardware shifts to 224p or 480i depending on the game).
* **Objective:** 4:3 display maximizing screen space without losing any critical UI elements, strictly at 1x native resolution.

**Mathematical Logic & Constraints**

* **Zero Crop Tolerance:** Unlike 8/16-bit games, 5th-generation 3D titles (PS1/N64) push critical HUD elements (minimaps, ammo counters, text boxes) to the absolute edges of the 240-line framebuffer.
* **Why not strict 3x (720p):** Scaling vertically to 720p creates an 80-pixel overflow. Cropping 26 native lines (13 top, 13 bottom) to fit the 640p physical screen will heavily amputate vital gameplay information.
* **The Dynamic Resolution Conflict:** PS1 and N64 games frequently switch internal resolutions on the fly (e.g., jumping from 240p during gameplay to 480i in inventory menus). Hardcoded `custom_viewport` coordinates will break entirely during these shifts, instantly throwing the image off-center.

**Configuration Rules**

1. **Abandon Custom Viewports:** Because of dynamic resolution switching and zero crop tolerance, you cannot use fixed coordinate overrides.
2. **Disable Global Integer Scaling:** Allow RetroArch to dynamically scale the image to fill the maximum physical height of your screen (640p) while automatically maintaining the correct width for a 4:3 ratio (853p).
3. **Enforce 4:3 Aspect Ratio:** Lock the aspect ratio globally so RetroArch handles the geometry automatically, ignoring the physical 3:2 screen ratio.
4. **Enable Crop Overscan:** Because we have abandoned strict integer math and fixed viewports, altering the base resolution no longer breaks any shader alignment. Enabling this safely removes the baked-in black borders common in PS1/N64 games (especially PAL regions), allowing the emulator to stretch the actual useful gameplay area to fully utilize your 640p screen height.

**Configuration File (.cfg)**
This relies on standard RetroArch scaling behavior rather than custom coordinate overrides. The `aspect_ratio_index = "0"` value forces RetroArch to strictly use the standard 4:3 aspect ratio.

```ini
aspect_ratio_index = "0"
video_scale_integer = "false"
video_crop_overscan = "true"
```

### Dreamcast & PS2 & GameCube (480i/480p)

**Target Display Settings**

* **Screen:** 960x640 (3:2 ratio).
* **Source:** 480i / 480p Native 1x (typically rendering at 640x480).
* **Objective:** 4:3 display maximizing screen space strictly at 1x native resolution, utilizing non-integer scaling to fill the display height.

**Mathematical Logic & Constraints**

* **The Integer Trap:** A 1x vertical integer scale (480p) leaves massive black borders (160 pixels of empty space vertically on your 640p screen). A 2x scale (960p) creates a 320-pixel overflow, amputating exactly one-third of the game screen. Therefore, strict integer scaling is mathematically unviable if you want a playable, full-sized image.
* **The Non-Integer Fit (1.33x):** Scaling the 480-line source to fit your 640-pixel screen height requires a 1.33x non-integer multiplier. To maintain a 4:3 aspect ratio, the width scales to approximately 853 pixels, leaving small pillar-boxes (black bars) on the left and right sides of your 960px screen.
* **Dynamic Resolutions (PS2 especially):** Just like the 5th generation, the PS2 is notorious for constantly shifting internal hardware resolutions (e.g., 512x448, 640x448, 640x480, or 1080i in menus). Hardcoded viewport coordinates cannot be used without breaking the image alignment during these shifts.

**Configuration Rules**

1. **Abandon Custom Viewports:** Due to dynamic resolution switching and the impossibility of integer scaling, you must rely on RetroArch's automated aspect ratio geometry.
2. **Disable Global Integer Scaling:** Mandatory. This allows the emulator to apply the 1.33x multiplier to stretch the 480p image to the absolute maximum physical height of your screen (640p).
3. **Enforce 4:3 Aspect Ratio:** Lock the aspect ratio globally. RetroArch will automatically calculate the 853px width based on the 640p height, preserving correct geometry for 6th-generation 3D titles.
4. **Enable Crop Overscan:** Safe and recommended to use. This automatically trims the baked-in black borders often present in these games (especially PAL region PS2 titles), maximizing the usable screen estate before the non-integer stretch is applied.

**Configuration File (.cfg)**
This relies on standard RetroArch scaling behavior rather than custom coordinate overrides. The `aspect_ratio_index = "0"` value forces RetroArch to strictly use the standard 4:3 aspect ratio block.

## Universal CRT Shader Strategy

### Non-integer safe

A universal shader strategy for a 640p screen relies on two fundamental rendering behaviors built into high-quality modern CRT shaders, allowing a single preset to seamlessly handle both 240p and 480p systems.

**Separation of Mask and Scanlines**
Modern algorithms project scanlines onto the game's native coordinates (following the game's internal resolution), but project the phosphor/shadow mask onto the screen's absolute physical coordinates (the viewport). This ensures the RGB pixel grid remains perfectly uniform and locked to your physical screen, preventing distortion regardless of whether the game uses strict integer or dynamic non-integer scaling.

**The 480p Scanline Cancellation**
To properly display black scanline gaps over a 480-line source, a display requires at least 960 physical vertical pixels. On a 640p screen (a 1.33x scale for 480p content), there is physically no room to draw these gaps. Advanced shaders detect this mathematical limit and naturally compress the scanlines. The result is an automatic transition: you get thick, authentic scanlines for 240p games, and a smooth, scanline-free "VGA PC monitor" look for 480p systems (Dreamcast, PS2) without ever changing the shader preset.

#### Option 1: `crt-easymode.slangp`

The standard baseline for clean, straightforward CRT emulation on modern handhelds.

**Pros:**
* Uses excellent vertical anti-aliasing to subtly adjust scanline opacity on non-integer scales, completely eliminating vertical shimmering and banding.
* Very lightweight and requires virtually zero configuration out-of-the-box.
* Delivers a highly sharp, defined pixel-art image.

**Cons:**
* Lacks any bloom or glow effect, which can make the image look slightly clinical or "dry" compared to a real glowing phosphor tube.
* Does not actively blend dithering patterns (checkerboard meshes used for transparencies in Mega Drive and PS1 games remain fully visible).

#### Option 2: `crt-guest-advanced-fast.slangp`

The industry gold standard for CRT accuracy and comprehensive visual features.

**Pros:**
* Features a highly accurate, adjustable bloom/halation module that simulates tube glow without crushing colors or washing out the image.
* Includes excellent built-in, togglable options specifically designed to blend dithering and composite artifacts (fixing waterfalls and transparent shadows).
* The scanline interpolation algorithm handles dynamic non-integer scaling (PS1/N64) flawlessly.

**Cons:**
* Heavier performance cost than the other options (though the `fast` variant mitigates this for most mid-range handhelds).
* The sheer volume of adjustable parameters in the shader menu can be overwhelming to dial in initially.

#### Option 3: `crt-hyllian-glow.slangp`

A mathematically precise alternative balancing sharpness with a highly controlled glow pass.

**Pros:**
* The Hyllian algorithm was mathematically engineered specifically around solving non-integer scaling artifacts, ensuring absolute stability during vertical scrolling.
* Delivers an incredibly sharp base image, complemented by a soft, lightweight glow pass that adds organic warmth without blurring the pixels.

**Cons:**
* The standard glow version does not blend dithering patterns at all. (If dithering blending is a strict priority, you must manually swap to the `crt-hyllian-sgenpt-mix.slangp` variant instead).
* The glow pass slightly softens the raw razor-sharp edges compared to the purely digital look of `easymode`.

```ini
aspect_ratio_index = "0"
video_scale_integer = "false"
video_crop_overscan = "true"
```

## Upscaling with fake 240p scanlines

#### The Resolution Conflict

For 5th-generation 3D consoles (PS1, N64), many users prefer to increase the core's internal resolution to 2x (480p) to achieve clean, anti-aliased polygons, while still maintaining the vintage aesthetic of thick 240p scanlines to hide low-resolution textures.

However, if the emulator outputs a 480p signal, standard CRT shaders will attempt to draw 480 scanlines. As established, a 640p display lacks the physical pixels to render 480 scanlines, causing the shader to naturally compress and cancel them out, resulting in a smooth "VGA Monitor" look that ruins the intended 240p illusion.

#### The Solution: Decoupling Geometry from the CRT Grid

To solve this, the 3D geometry (rendered at 480p) must be separated from the CRT scanline grid (which must be mathematically forced to a 240p density). You need a shader capable of rendering scanlines at "half-frequency"—drawing one thick scanline for every two native 3D lines—while still utilizing vertical anti-aliasing to survive the non-integer stretch to your 640p physical screen.

#### Adapting the Non-Integer Safe Shaders**

**Option 1: The Unified Solution (`crt-guest-advanced-fast.slangp`)**
This is the optimal path for total visual consistency across your entire library. You can use the exact same shader preset for your 480p 3D games as your 240p 2D games, retaining the exact same glow, mask, and dithering behavior.
* **How to apply:** Load the standard `crt-guest-advanced-fast` preset. Open the **Shader Parameters** menu and locate the setting named **`High resolution scanlines`** (or `Scanline Mode`). Changing this parameter forces the algorithm to ignore the 480p input resolution and project a thick, uniform 240p scanline grid over the upscaled 3D models.

**Option 2: The Dedicated Variant (`crt-hyllian-3d.slangp`)**
The standard `crt-hyllian-glow` shader is hardcoded to match its input resolution and cannot be toggled via parameters. To get half-frequency scanlines using the Hyllian algorithm, you must switch to its dedicated 3D sister preset.
* **How to apply:** Load the `crt-hyllian-3d.slangp` preset. It utilizes the same excellent non-integer anti-aliasing math to prevent vertical shimmering on a 640p screen, but is hardcoded to project a 240p grid over 480p sources. The trade-off is that this specific 3D preset lacks the pre-configured glow pass, resulting in a much sharper, clinical image compared to your 2D setup.

#### Final Recommendation

If maintaining a cohesive art direction (consistent bloom, shadow mask, and dithering logic) between your 16-bit 2D library and your upscaled 32-bit 3D library is the priority, **`crt-guest-advanced-fast`** is the definitive choice. By utilizing its internal `High resolution scanlines` parameter via a Core Override for DuckStation and Mupen64Plus, you achieve upscaled 3D polygons masked by perfectly aligned, non-integer safe 240p scanlines.
