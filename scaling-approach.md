> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes.

# Retro Display Optimization Doctrine

This doctrine defines a universal methodology for displaying retro content (historically designed for 4:3 CRTs or atypical ratios) on modern screens with varying aspect ratios (16:9, 16:10, 3:2, etc.). The goal is neither sterile mathematical perfection nor blind screen-filling, but rather optical optimization: maximizing the perceived size of sprites while strictly preserving the integrity of the interface (HUD) and prohibiting any visually shocking distortion ("Aspect Ratio Crimes").

### 1. The Hierarchy of Priorities

The creation of a display profile is governed by three absolute priorities, in order of importance:
1.  **HUD Integrity:** No gameplay information or interface element may be truncated by cropping, regardless of technical margins (overscan). Aesthetic considerations always yield to UI usability constraints.
2.  **Maximization of the Vertical Axis (The Optical "Cheat Code"):** The image must fill the physical screen from top to bottom as much as the HUD permits. The vertical axis dictates the overall zoom level: the more useless vertical margins (overscan) are pushed out of frame, the larger the underlying image becomes, thereby increasing the perceived diagonal size of the sprites.
3.  **Constrained Horizontal Expansion:** Fill the width of the screen as much as possible to limit black bars (pillarboxing), but stop strictly at the geometric tolerance thresholds defined below.

### 2. Adjustment Levers

*   **Strict Integer Scaling (LCD Handhelds):** This is the golden rule for LCD handhelds. Consoles historically featuring LCD screens (Game Boy, GBA, Game Gear, etc.) require perfect Integer Scaling (with no cropping). This is the only method that allows LCD grid shaders to be applied without generating moiré patterns. Integer Scaling is always preferred when the screen ratio permits it without excessive screen real estate loss.
*   **Fractional Scaling (Home Consoles & Other Cases):** Integer Scaling can sometimes hinder vertical optimization by generating massive black borders or forcing destructive crops. Therefore, the doctrine authorizes the use of **Fractional Scaling**. Any potential sub-pixel artifacts are generally smoothed out by the application of CRT shaders (which tolerate fractional scaling much better than grid shaders).
*   **Symmetrical Auto-Centering:** Hardware coordinates (in RetroArch) must default to perfectly centered (`X=0, Y=0`). Any fractional image overflow beyond the physical screen is thus mathematically cut in half (half at the top, half at the bottom), guaranteeing a perfectly symmetrical crop.
*   **Asymmetrical Offsets:** Offsets (`X` and `Y` shifts) are not forbidden, but they must be justified. They are only applied when the original console's hardware specifications dictate an asymmetrical display (e.g., an off-center overscan by default).

### 3. Horizontal Doctrine and Distortion Thresholds

Horizontal adjustments rely on two scenarios, each applying a strict limit to stretching:

*   **The Nostalgia Threshold (Max Tolerance: 5%)**
    *   *Targets:* Systems based on an intended 4:3 render, 3D geometry, or a historically accurate Pixel Aspect Ratio (PAR) (Arcade, Mega Drive, Master System, PS1, Saturn, N64, 128-bit consoles).
    *   *Rule:* The horizontal stretch applied to eat up lateral black bars must **never exceed 5%** of the mathematically perfect width (1:1). This limit is visually imperceptible to the brain (especially on 3D models or behind a CRT mask) and fully preserves geometric integrity (car wheels remain round).
*   **Cathodic Correction (The 8/16-bit Exception)**
    *   *Targets:* Systems historically subjected to severe hardware crushing on 4:3 televisions due to atypical resolutions (e.g., NES, Super Nintendo).
    *   *Rule:* The target width aims for the **midpoint** between sterile mathematical perfection (1:1 PAR) and extreme historical distortion (4:3 DAR). This stretch (usually between 8% and 12%) exceeds the 5% rule but acts as a deliberate correction: it flatters visual memory while mitigating the original hardware flaw (spheres are no longer crushed ovals). A margin of opportunity allows for slight deviations from this exact midpoint if it helps fill the screen better without causing shocking distortion.

### 4. Vertical Doctrine and Cropping Tolerances (Overscan Crop)

Cropping is not a configuration flaw; it is the primary zooming tool. It obeys strict limits based on HUD mapping. Each console tolerates a different level of cropping depending on how its games were coded:

*   **Zero Tolerance (0 Lines):** If UI elements touch the extreme edges of the screen, cropping is strictly forbidden.
    *   **Arcade (Neo Geo, CPS, etc.):** Absolute zero tolerance. Score counters or health bars are often glued down to the pixel at the display limits.
    *   **Master System:** Zero tolerance, as the edges of the 256x192 image often contain vital HUD elements.
    *   **Mega Drive / Genesis:** Zero tolerance. Even though 224 lines are standard, many games (especially PAL releases) utilize the extra margins.
    *   **32-bit Consoles (PS1/Saturn):** Zero tolerance, in order to stabilize dynamic resolutions (alternating between 240p and 480i) within a fixed geometric frame.
*   **Overscan and the "Breathing Room" Rule:** When cropping safety margins containing visual artifacts (garbage pixels) to zoom the image, the cut must never touch the HUD. You must leave approximately **4 native lines of "breathing room"** between the physical edge of the screen and the beginning of textual or graphical interface elements.
    *   **NES / PC Engine:** High tolerance. You can often crop **~8 lines** symmetrically (top and bottom) with zero consequence to the HUD, effortlessly eliminating standard overscan garbage.
    *   **Super Nintendo (SNES):** Medium tolerance. You can comfortably crop **~5 lines**, which generally aligns with the safe overscan zone respected by developers (limiting the risk of amputating interfaces).
    *   **Amiga:** Low/Medium tolerance. You can crop **~4 lines** on a full PAL signal (256 lines) without interfering with typical HUDs (which usually begin around line 8).
    *   **Nintendo 64:** High tolerance, due to generous margins (often **~6 lines** or more) imposed by early 3D geometry safe zones, making it easy to crop without UI loss.

### 5. Signal Purity and Managing Exceptions

*   **Refusal of Double Processing:** The primary display manager (e.g., RetroArch's Custom Viewport) is the sole geometric arbiter. Emulation cores have a strict obligation to output the raw, un-stretched, and un-cropped pixel matrix. All internal core adjustments (Stretch, Widescreen hacks, Force 4:3, Auto-crop) must be disabled.
*   **Non-Destructive Glitch Masking:** Scrolling artifacts or glitched edge columns (common on NES or Master System) never justify asymmetrical hardware cropping (which would destroy the geometric auto-centering grid). They must be visually hidden by the CRT Shader overlay (using options like `Overscan Mask` or `Black Border`), guaranteeing a clean image without altering the display mathematics.
