> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes, as well as to assist with some of the mathematical calculations.

# Installation Preparation for a Konkr Pocket Advance

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

More details on the [dedicated page|https://github.com/gerpy/kpa-install/blob/main/scaling.md].



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
