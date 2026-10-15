> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes, as well as to assist with some of the mathematical calculations.

# Installation Preparation for a Konkr Pocket Advance

## RetroArch Scaling for LCD Systems

Because grid shaders often can't deal decently with non integer scaling, we use integer scaling for every handheld system. Platforms up to GBA are 4x, NDS is 3x and PSP is 2x. Just set the following and you are done :
- **Integer Scale:** `On`
- **Integer Scale Axis:** `Y`
- **Aspect Ratio:** `Core Provided`

**The NDS exception:**

The exception is NDS. Displaying both screen on the KPA make the screens so tiny that it is unplayable. So better display on screen large and a small vignete for the second one. Unfortunately, the `Melon DS DS` core options to balance both screens are very limited and lead to non intsger scaling on both screens.

NDS 256x192 screens display at 3x but there is wasted real estate if you display only that. So the preferred layout is to display one main large screen at 3x on the left, and a thumbnail of the second screen on the right, in the remaining space. I like to spare a small black separation line between both displays. But `Melon DS DS` can't do any of this that so I had to develop a custom shader that takes a top/bottom or bottom/top layout from the core, splits it into two seperate screens and displays them it as I want. The shader preset adds a `lcd1x` grid because that's the whole point. There is one version with NDS corrected collors, and one with raw colors from the core.

To make this work, we need an NDS core override for scaling and set the viewport as such :

- **Integer Scale:** `OFF`
- **Aspect Ratio:** `Custom`
- **Custom Aspect Ratio (Width):** `960` (Justification: fill the whole width to maximize the thumbnail size)
- **Custom Aspect Ratio (Height):** `576` (Justification: 3x the NDS vertical resolution of 192)

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].

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

> More details on the [https://github.com/gerpy/kpa-install/blob/main/scaling.md|dedicated page].

### Real-World Display Metrics (Surface vs. Perceived Size)

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

## Shaders for the KPA

### CRT Shaders

The KPA doesn't have a high resolution wrt decent shaders standards, and its processor isn't strong enough to calculate complex shaders. A small resolution is not a big deal when you integer scale but unfortunately, as one may see above, many systems are scaled in a non integer way. So one needs to find and carefuly setup shaders that are known to be robust wrt fractional scaling :

- I have tried my best with `hyllian` but I failed at finding decent parameters that show a nice look and zero to very little moire an artifacts
- I had good results with `crt-guest-advanced-fast` despite the 640 vertical resolution of the KPA. However, even in its `fast` version, `guest` is too heavy, be to older and easy to emulate older platforms. But even so, it draine too much battery to justify the look.

My non negocialble prerequisite is to make things properly, which means :

- **Scanlines** have to correspond to native pixel lines and not with the device screen (many shaders "cheat" and it is ugly once you notice it)
- **Masks** however have to take the device screen as a reference
- Scanlines make no sense past 240p (NTSC).

I don't like overcooked shaders but I want them to help increasing perceived color palettes of 2D games, smooth dithering a bit and lower aliasing in 3D games. With such tastes in mind, considering the processing power, the KPA screen resolution and size, as well as the non integer scalings, I did my best with the `easymode` suite (regular and `halation`). The `halation` version is too heavy with N64 (Parallel) or with the PS1 Swannstation core at 2x, but the regular `crt-easymode` is just fine. For 2D platforms, `halation` is a must to get a decent look. I have ony tinkered with parameters to find decent settings. And I have to admit that I'm impressed by what it is possible to achieve with only 640 lines. 

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].

### LCD Shaders

For LCD plaforms, I don't think that advanced grid shaders with RGB separation matter on the KPA screen, so I keep it simple with `lcd1x` (dark grid for backlit handhelds) and `simpletex` (for earlier handhelds such as GB for instance). All I did is tweaking parameters to roughly match the colors from the core, without heavy darkening or enlihting. 

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].
