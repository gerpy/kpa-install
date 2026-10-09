# Installation Preparation for a Konkr Pocket Advance

> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes.

## RetroArch Scaling for CRT Systems

The Konkr Pocket Advance (KPA) features a 3:2 aspect ratio screen (960x640). While perfect for the Game Boy Advance, playing standard 4:3 legacy consoles with default settings results in massive black borders (pillarboxing). 

To maximize screen real estate, the following configurations rely on a dual approach:
1. **Vertical Overscan Cropping:** Surgically cutting unused top and bottom margins to enlarge the image, while strictly ensuring all in-game UI elements and HUDs remain fully visible.
2. **Horizontal Stretching:** Expanding the width to fill the screen without crossing into visually offensive distortion (avoiding "Aspect Ratio Crimes" with a 5% threshold).

**The Historical Stretch Exception:**
For specific platforms that already suffered from severe horizontal stretching on original CRT televisions (such as the NES or SNES), we deliberately exceed our standard stretch limits to fill the KPA screen. However, this is designed as an *improvement* over the original hardware: by targeting a sweet spot exactly halfway between the flawed historical 4:3 Display Aspect Ratio (DAR) and the mathematically perfect 1:1 Pixel Aspect Ratio (PAR), we reduce the original geometric distortion while still flattering our visual memory.

### Quick Reference Summary

For all systems below, the following baseline settings are **strictly mandatory** to ensure the auto-centering math works correctly:
- **Integer Scale:** `OFF`
- **Aspect Ratio:** `Custom`
- **Custom Aspect Ratio (X Position):** `0`
- **Custom Aspect Ratio (Y Position):** `0`
- **Crop Overscan:** `OFF` *(Must be verified in both RetroArch's global Video settings and the Quick Menu > Core Options).*

| System | Target Folder(s) | Viewport Width | Viewport Height |
| :--- | :--- | :--- | :--- |
| **Mega Drive / Genesis** | `megadrive` | **960** | **640** |
| **Super Nintendo** | `snes` | **832** | **672** |
| **Master System** | `mastersystem` | **896** | **640** |
| **NES & PC Engine** | `nes`, `pcengine` | **824** | **686** |
| **Arcade (FBNeo)** | `fbneo` | **896** | **640** |
| **PS1 & Saturn** | `psx`, `saturn` | **896** | **640** |
| **Nintendo 64** | `n64` | **944** | **674** |
| **Commodore Amiga** | `amiga` | **924** | **660** |
| **6th Gen & Modern 4:3** | `dreamcast`, `ps2`, `gc`, `wii` | **896** | **640** |

Below are the detailed configuration rules and files tailored for each system. *(Note: System directories strictly follow the ES-DE naming convention).*

### Sega Mega Drive / Genesis (`megadrive`)

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 320x224 (Standard V28 mode).
- **Objective:** Fractional Scaling with zero vertical cropping (0 lines cut top or bottom) to safely accommodate all game HUDs, combined with an exact 5% horizontal stretch to perfectly fill the screen edge-to-edge.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `960` *(Justification: The geometrically perfect 1:1 width at this height is 914px. Stretching it to 960px hits exactly the 5% stretch tolerance limit, filling the screen without noticeable distortion).*
6. **Custom Aspect Ratio (Height):** `640` *(Justification: Matches the physical screen height perfectly, preserving all 224 native lines for games that require the absolute top/bottom edges).*

*(Note: Ensure **Crop Overscan** is set to `OFF` in both the global Video settings and Quick Menu > Core Options).*

**Configuration File (`megadrive.cfg`)**
*(If you prefer manual file editing, place this in your config override folder).*

```ini
aspect_ratio_index = "23"
custom_viewport_width = "960"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_scale_integer = "false"
video_crop_overscan = "false"
```
### Super Nintendo / Super Famicom (`snes`)

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x224 (Standard output).
- **Objective:** Integer Scaling on the vertical axis for pristine sharpness, cropping ~5.3 native lines at the top and bottom to seamlessly hide overscan. This is combined with an 8.3% horizontal stretch (the exact midpoint between a perfect 1:1 pixel aspect ratio and the historical 4:3 stretch) to mitigate the original hardware's geometric distortion.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` *(Justification: Must be disabled globally. Since our 672p target height overflows the 640p screen, leaving this ON forces RetroArch to crush the image down to 2x. Disabling it allows our custom coordinates to enforce the 3x height).*
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `832` *(Justification: The mathematically perfect 1:1 width is 768px, while the historical 4:3 width is 896px. 832px is the exact midpoint, producing an 8.3% stretch that improves upon the original hardware's severe oval distortion while flattering our visual memory).*
6. **Custom Aspect Ratio (Height):** `672` *(Justification: Enforces a perfect 3x vertical integer scale. The 32-pixel overflow auto-centers to crop ~5.3 native lines top and bottom, which falls perfectly within Nintendo's historical 8-line overscan safe zone, preserving 100% of the UI).*

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

**Core Preparation**

Ensure your emulator core (e.g., Genesis Plus GX) is passing the raw, unmodified video signal to RetroArch by disabling any `Hide Borders` or `Overscan Mask` settings. *(Note: To hide the scrolling glitches present on the edges of certain games without destroying our geometry, save a Game Preset using the `Overscan mask` parameters available in your CRT shaders, such as `crt-guest-advanced-fast`).*

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x192 (Raw, unaltered signal).
- **Objective:** Fractional Scaling with absolutely zero vertical cropping (0 lines cut top or bottom) to respect the rigid UI, combined with an exact 5% horizontal stretch to minimize pillarboxing.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF` *(Justification: A 3x integer scale yields a 576px height, leaving massive 64px black bars, while a 4x scale forces a 128px crop that would obliterate the HUD. Fractional scaling is mandatory).*
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896` *(Justification: The mathematically perfect 4:3 width for a 640p height is 853px. Adding our maximum 5% stretch tolerance yields 896px, eating up the pillarboxing while keeping sprite distortion entirely imperceptible).*
6. **Custom Aspect Ratio (Height):** `640` *(Justification: Utilizes 100% of the screen height. Since the Master System's 192-line active window contains critical data from edge to edge, we apply exactly 0 lines of vertical overscan crop).*

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

**Core Preparation**

Ensure both cores send the full, uncropped raw video signal to RetroArch so our mathematical auto-centering works perfectly.
- **NES (Mesen):** Open Quick Menu > Core Options > Video. Set `Left/Right/Top/Bottom Overscan` to `None`. Set `Aspect Ratio` to `No stretching` (or `Auto`). *Recommended:* Enable `Remove sprite limit` to fix historical flickering. *(Note: To hide the scrolling glitches present on the edges of certain NES games without destroying our geometry, save a Game Preset using the `Overscan mask` parameters available in your CRT shaders, exactly like the Master System).*
- **PC Engine (Beetle PCE):** Open Quick Menu > Core Options > Video. Ensure any core-specific cropping options (like `Crop Overscan` or custom `Initial/Last Scanline` ranges) are disabled to output the full raw 240-line image.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256x240 (NES) / Dynamically shifting x240 (PC Engine).
- **Objective:** Fractional Scaling cropping exactly ~8 native lines at the top and bottom to seamlessly hide the universal overscan garbage. This is combined with a 12.5% horizontal stretch (the midpoint between 1:1 PAR and historical 4:3 DAR) to perfect the NES aspect ratio while taming the PCE's shifting resolutions.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `824` *(Justification: For the NES, the perfectly square 1:1 width is 732px, while the historical 4:3 stretch is 915px. 824px is the exact midpoint, producing a 12.5% stretch that flatters nostalgic memory without the extreme CRT distortion. For the PC Engine, locking to this single fixed width forces all its wildly shifting internal horizontal resolutions into one stable, geometrically pleasing frame).*
6. **Custom Aspect Ratio (Height):** `686` *(Justification: Scaling the 240 native lines to 686px ensures the pristine 224-line "action zone" perfectly fills the 640p screen height. The 46-pixel overflow auto-centers to slice off exactly 8 lines of vertical garbage at the top and bottom without decapitating HUDs).*

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
- **Objective:** Fractional Scaling with absolutely zero vertical cropping (0 lines cut top or bottom) to safely protect extreme-edge UI elements across heterogeneous arcade boards, combined with a unified 4:3 base expanded by an exact 5% horizontal stretch to minimize pillarboxing.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896` *(Justification: Arcade boards output wildly different native widths, but CRT operators historically squished or stretched them into a standard 4:3 monitor. A strict 4:3 width at 640p height is 853px. Adding our 5% stretch tolerance yields 896px, unifying all chaotic resolutions into one stable, aesthetically pleasing frame).*
6. **Custom Aspect Ratio (Height):** `640` *(Justification: Matches the physical screen height perfectly. Because arcade hardware like the Neo-Geo pushes vital UI elements to the absolute extreme edges of the video signal, zero lines are cropped to guarantee 100% HUD preservation across thousands of unpredictable games).*

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

Both 32-bit pioneers operate under identical display philosophies. They heavily rely on 3D geometry authored specifically for 4:3 televisions, and notoriously switch resolutions on the fly.

**Core Preparation (Sega Saturn)**

If using the Saturn core, ensure its internal aspect ratio is set to `1:1 PAR` (or `10:7 DAR`). This forces the core to output the raw, un-stretched pixel matrix so RetroArch can apply our single, mathematically precise horizontal stretch without applying a destructive double-stretch.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** Dynamically shifting 240p (Gameplay) and 480i (Menus/FMVs).
- **Objective:** Fractional Scaling with absolutely zero vertical cropping (0 lines cut top or bottom) to safely contain dynamic resolution shifts, combined with a 4:3 base expanded by an exact 5% horizontal stretch to minimize pillarboxing while preserving 3D geometry.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896` *(Justification: 32-bit 3D models were mathematically projected for 4:3 displays. Over-stretching instantly ruins proportions, turning wheels into ovals. A flawless 4:3 width at 640p is 854px. Adding our maximum 5% stretch tolerance yields 896px, gracefully reducing pillarboxing without visibly compromising 3D integrity).*
6. **Custom Aspect Ratio (Height):** `640` *(Justification: Games like Resident Evil or Chrono Cross constantly swap between 240p gameplay and 480i menus. Locking the viewport strictly to the KPA's physical 640px height forces all varying signals into a single, unmoving container, preventing resizing glitches or signal drops during transitions. Zero lines are cropped).*

*(Note: Ensure **Crop Overscan** is set to `OFF`. The fixed Custom Viewport acts as an absolute container; automatic cropping would disrupt the stability of menu transitions).*

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

**Core Preparation**

Before setting the RetroArch Viewport, ensure the core (e.g., Mupen64Plus-Next or ParaLLEl N64) is outputting the raw, untampered video signal.
- Open Quick Menu > Core Options > Video.
- Ensure any internal aspect ratio settings are set to `Original` or `4:3` (strictly avoid widescreen hacks or "Adjust" settings), and any core-level overscan cropping is disabled. The Custom Viewport must handle all geometry.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 240p / 480i (Standard 320x240, dynamically switching during menus).
- **Objective:** Fractional Scaling cropping exactly ~6 native lines at the top and bottom to eliminate overscan garbage while preserving perfect UI breathing room, combined with an exact 5% horizontal stretch to almost entirely fill the physical screen without severe 3D distortion.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `944` *(Justification: A mathematically perfect 4:3 aspect ratio based on our 674p cropped height requires 899px. Adding our maximum 5% stretch tolerance yields 944px. This covers almost the entirety of the 960px screen, leaving razor-thin 8-pixel black borders while keeping 3D geometric distortion strictly within acceptable limits).*
6. **Custom Aspect Ratio (Height):** `674` *(Justification: The N64 features a massive 10-line croppable margin. Scaling the raw 240 lines to 674px creates a 34-pixel overflow. This perfectly auto-centers to slice off exactly 6 lines of vertical garbage top and bottom, safely leaving a flawless 4-line padding before the HUD begins).*

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

### Commodore Amiga (`amiga` / `puae`)

**Core Preparation (PUAE)**

The Amiga is a complex microcomputer, and the PUAE core contains its own internal zooming and cropping mechanics. To ensure our RetroArch Custom Viewport works perfectly, we must feed it the raw PAL signal.
- Open Quick Menu > Core Options > Video.
- Ensure any `Zoom`, `Crop`, or `Auto-Crop` settings are set to `None` or `Disabled`. The core must output the full 256-line PAL matrix without internal tampering.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 256p (Standard PAL 320x256 resolution).
- **Objective:** Fractional Scaling cropping exactly ~4 native lines at the top and bottom to seamlessly tame the tall European PAL video signal, combined with an exact 5% horizontal stretch over the 4:3 base to minimize pillarboxing.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `924` *(Justification: Amiga games were designed for 4:3 monitors. The perfect 4:3 width for our 660p height is 880px. Adding our maximum 5% stretch tolerance yields 924px, beautifully filling the KPA screen and leaving only unobtrusive 18-pixel black bars).*
6. **Custom Aspect Ratio (Height):** `660` *(Justification: Unlike NTSC consoles, the Amiga natively outputs a tall 256-line PAL signal. Scaling this to 660px creates a 20-pixel overflow. This auto-centers to flawlessly slice off exactly 4 lines of vertical overscan top and bottom, leaving perfect breathing room before the HUD begins at line 8).*

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

**Core Preparation**

By the 6th generation, consoles output pristine digital or high-quality analog signals with UI elements pushed to the physical edges.
- Ensure any core-specific widescreen (16:9) hacks are disabled if you intend to use this 4:3 doctrine.
- Ensure the core's internal aspect ratio is set to output its native 4:3 frame to allow RetroArch's Custom Viewport to handle the final stretch.

**Target Display Settings**

- **Screen:** 960x640 (3:2 ratio).
- **Source:** 480i / 480p (Standard 4:3).
- **Objective:** Fractional Scaling with absolutely zero vertical cropping (0 lines cut top or bottom) to safely preserve modern HUDs, combined with an exact 5% horizontal stretch over the 4:3 base to minimize pillarboxing while maintaining 3D geometry.

**Configuration Rules (GUI Method)**

Navigate to **Settings > Video > Scaling** and configure the parameters in this exact sequence:

1. **Integer Scale:** `OFF`
2. **Aspect Ratio:** `Custom`
3. **Custom Aspect Ratio (X Position):** `0`
4. **Custom Aspect Ratio (Y Position):** `0`
5. **Custom Aspect Ratio (Width):** `896` *(Justification: A mathematically perfect 4:3 aspect ratio at 640p height requires an 853px width. Adding our maximum 5% stretch tolerance yields 896px. Because these consoles rely on dynamic 3D cameras, the brain is very forgiving of this slight expansion, beautifully balancing 4:3 nostalgia with the KPA screen by leaving only two symmetrical 32-pixel black bars).*
6. **Custom Aspect Ratio (Height):** `640` *(Justification: Matches the physical screen height perfectly. The concept of analog overscan garbage essentially disappeared in this era, so we scale the 480 native lines directly to the 640p height to preserve the entire frame with exactly 0 lines cropped).*

*(Note: **Widescreen Hacks Alternative:** If you enable 16:9 widescreen hacks within the emulator cores, you must abandon this 4:3 config. A native 16:9 image on the KPA requires filling the full 960px width, resulting in a 540px height with 50px black bars on the top and bottom).*

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

## Real-World Display Metrics (Surface vs. Perceived Size)

Because we are using a 3.5-inch 3:2 screen (960x640) to display primarily 4:3 legacy content, measuring the image by its standard physical diagonal is mathematically misleading. By pushing vertical overscan margins outside the physical bezel, we enlarge the rendered image beyond the hardware's limits.

This unified table breaks down two critical realities:
1. **The Displayed Surface:** What you actually see lit up on your physical KPA screen.
2. **The Underlying Canvas (The Cheat Code):** The full size of the rendered game window (including the hidden cropped lines). By converting this underlying area into an **Equivalent 4:3 Diagonal**, you can see the true benefit of this doctrine: *how big the sprites actually look to your eyes* compared to playing on a standard 4:3 handheld.

| System | Displayed AR | Displayed Diagonal | Screen Surface | Underlying AR (incl. crop) & Stretch | Underlying Diagonal | Equivalent 4:3 Diagonal |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Mega Drive** | 1.50 (3:2) | **3.50"** | 100% | 1.50 (3:2) + 5.0% stretch | 3.50" | **3.43"** |
| **N64** | 1.48 (~59:40) | **3.46"** | 98.3% | 1.40 (7:5) + 5.0% stretch | 3.52" | **3.49"** |
| **Amiga** | 1.44 (~13:9) | **3.41"** | 96.3% | 1.40 (7:5) + 5.0% stretch | 3.44" | **3.42"** |
| **SMS / Arc / 32-bit / 6th** | 1.40 (7:5) | **3.34"** | 93.3% | 1.40 (7:5) + 5.0% stretch | 3.34" | **3.32"** |
| **Super Nintendo** | 1.30 (13:10) | **3.18"** | 86.7% | 1.24 (~11:9) + 8.3% stretch | 3.24" | **3.27"** |
| **NES & PC Engine** | 1.29 (~9:7) | **3.16"** | 85.8% | 1.20 (6:5) + 12.5% stretch | 3.25" | **3.29"** |

**The Verdict:** 
Even though the Konkr Pocket Advance is a 3:2 device, this scaling doctrine effectively neutralizes the aspect ratio penalty. By utilizing the screen's extra width to safely zoom in and crop vertical garbage, systems like the N64 render 3D models at a size equivalent to a **3.49-inch 4:3 screen**. Even heavily letterboxed systems like the Super Nintendo achieve sprites as large as they would be on a ~3.27-inch 4:3 device.
