// **Author's Note:** The scaling approach, editorial choices, and overall display doctrine presented in this guide are entirely my own. Because English is not my native language, I utilized Gemini strictly to translate my notes, format the document, and assist with verifying/performing some calculation details.//

# Retro Display Optimization for the Konkr Pocket Advance (KPA)

> Platforms originally featuring LCD screens (Game Boy, GBC, GBA, Game Gear, Neo Geo Pocket Color, WonderSwan, etc.) are deliberately excluded from these complex fractional calculations. For these systems, you must simply use standard **Integer Scaling** with Crop Overscan set to `OFF`. This strict integer pixel mapping is mandatory to allow LCD grid shaders to render the screen matrix perfectly, without introducing moiré patterns or scaling artifacts.

The approach documented here aims to optimize retro emulation rendering specifically for the **Konkr Pocket Advance (KPA)**. This device features a 3:2 aspect ratio screen with a resolution of 960x640 pixels. Because this format is wider and shorter than the standard 4:3 CRT, it requires surgical configuration to maximize display space. The goal is to utilize as much of the screen as possible while preserving the geometric integrity of the original pixel art, avoiding excessive distortion, and guaranteeing flawless scanline rendering via CRT shaders.

To achieve this, the setup relies on the strict definition of the **Viewport**. In the context of emulation (such as in RetroArch), the viewport is the exact rectangular area of your physical screen where the game is drawn. This frame is defined by an origin point (X and Y coordinates) and absolute dimensions (width and height in pixels). By forcing a custom viewport for each console, we can intentionally crop the vertical overscan—hiding empty borders, visual garbage, or less useful background elements at the top and bottom of the original video signal. Simultaneously, we can apply a calculated, subtle horizontal stretch. This dual approach of vertical cropping and slight horizontal widening allows us to perfectly control the scaling to fit the KPA's wider constraints and maximize screen real estate, without ever cutting into the game's critical UI.

## HUDs Reference Table

**The "Breathing Room" Concept**
Before looking at the data, it is crucial to distinguish between the *Croppable Margin* (the absolute maximum overscan we can hide) and the actual crop we apply. If we were to crop 100% of the available margin, the game's UI would be pressed flush against the physical plastic bezel of the KPA, creating a suffocating, unnatural look. To prevent this, our viewport calculations intentionally preserve a **Breathing Room** to gracefully frame the HUD. 

The exact amount of breathing room applied depends strictly on the system's generation and design philosophy:

* **Zero Margin Systems (Arcade, Neo-Geo, Master System) = 0 lines.** These systems were designed entirely edge-to-edge, with UI elements intentionally touching the absolute physical limits of the screen. Injecting padding here would require artificially shrinking the image and adding letterboxing, which goes against our goal.
* **Classic 2D & Early 3D Consoles (NES, SNES, Mega Drive, PC Engine, PS1, Saturn, N64, Amiga) = ~3 to 4 native lines.** This is the standard sweet spot. For integer-scaled systems (Mega Drive, SNES), the rigid math naturally leaves about 3 lines of uncropped overscan. For fractionally scaled systems, we deliberately inject exactly **4 native lines** of padding top and bottom before calculating the final viewport.
* **6th Generation & Modern 4:3 (Dreamcast, PS2, GameCube, Wii) = 0 injected lines.** By the 128-bit 480p era, the concept of raw analog overscan garbage vanished. Modern 3D engines already incorporated internal TV safe zones, meaning the UI breathes naturally within its own 480-line frame without us needing to force artificial padding.

This reference table maps the strict vertical footprint of user interfaces (HUDs) across major retro CRT systems. Instead of relying on theoretical NTSC overscan standards, this data is derived from an empirical visual analysis of extensive game libraries. It establishes the actual useful pixel window and defines safe cropping margins—optimized at a 95% compatibility threshold by deliberately excluding statistical outliers (such as atypically deep RPG menus). This pragmatic framework maximizes screen real estate and scaling potential on modern aspect ratios while guaranteeing zero loss of critical gameplay information.

| Console | Calculated Useful Pixels | HUD Footprint (Limit) | Croppable Margin | Synthesized Justification |
| :--- | :--- | :--- | :--- | :--- |
| **NES / Famicom** | Line 0 to 239 | Line 8 to 223 | Top: 8 px<br>Bot: 16 px | Action platformers avoid the top 8px and bottom 16px. Rare text-heavy RPGs descending to line 235 are sacrificed (5% rule) to secure the 16px bottom margin. |
| **Sega Master System** | Line 0 to 191 | Line 0 to 191 | Top: 0 px<br>Bot: 0 px | Hardcoded 192-line active window. HUDs strictly stick to the absolute top (line 0) and bottom (line 191) pixels. Zero sacrifice possible. |
| **Sega Mega Drive** | Line 0 to 223 | Line 8 to 215 | Top: 8 px<br>Bot: 8 px | Standard V28 mode limits rendering to 224 lines. Action games leave 8px safe areas. Deep RPG text boxes (reaching 222) are sacrificed for a universal 8px symmetric crop. |
| **Super Nintendo** | Line 0 to 223 | Line 8 to 215 | Top: 8 px<br>Bot: 8 px | 224-line default rendering. Standard HUDs fit within 8-215. Deep RPG menus (reaching 221) are cropped to guarantee a clean 8px symmetric margin. |
| **PC Engine** | Line 0 to 239 | Line 8 to 223 | Top: 8 px<br>Bot: 16 px | Shmups and platformers safely use lines 8-223. Outlier RPGs with massive text interfaces (reaching 232) are excluded to maintain the 16px bottom crop. |
| **Neo-Geo (AES/MVS)** | Line 0 to 223 | Line 0 to 223 | Top: 0 px<br>Bot: 0 px | Sprite-only rendering utilizes all 224 active lines. Health bars and credit counters are pushed to the absolute edges (0 and 223). Zero margin. |
| **CPS-1/2/3** | Line 0 to 223 | Line 0 to 223 | Top: 0 px<br>Bot: 0 px | Arcade hardware generating a 384x224 grid. Fighting games and beat 'em ups push health bars, super meters, and names to the extreme top (line 0) and bottom (line 223) boundaries. Zero margin. |
| **Commodore Amiga** | Line 0 to 255 | Line 8 to 247 | Top: 8 px<br>Bot: 8 px | Despite the tall 256-line PAL window, major action titles keep dashboards within 8-247. Full-screen pinball games center their scoreboards, naturally respecting this safe area. |
| **Sony PlayStation** | Line 0 to 239 | Line 8 to 231 | Top: 8 px<br>Bot: 8 px | Standard 240-line rendering. 2D/3D action games safely sit within 8-231. Heavy RPG sub-menus reaching 238 are trimmed to ensure an 8px symmetric crop. |
| **Sega Saturn** | Line 0 to 239 | Line 8 to 231 | Top: 8 px<br>Bot: 8 px | Arcade conversions stay within 8-231. Outlier tactical RPGs pushing menus to 237 are sacrificed to secure the 8px symmetric margin. |
| **Nintendo 64** | Line 0 to 239 | Line 10 to 229 | Top: 10 px<br>Bot: 10 px | Hardware anti-aliasing and safe areas compress most HUDs tightly between 10-229. Rare UI exceptions (reaching 235) are excluded to lock in a massive 10px symmetric margin. |

## Viewport Definition Doctrine

This doctrine governs the mathematical and geometric calculation of display viewports. The objective is to maximize the utilization of a 960x640 pixel screen while guaranteeing the absolute preservation of the user interface (HUD), the proper functioning of CRT shaders, and the strict control of geometric distortion (the "Aspect Ratio Crime").

### I. The Vertical Axis: Scaling Rules

Vertical management takes precedence. It dictates scanline sharpness and UI preservation.

**Rule 1: Integer Scaling Priority (The Standard)**

* **Application Condition:** Applies whenever an integer multiplier (e.g., x3) can display the entirety of the HUD Limit with reasonable breathing room, requiring only a moderate crop of the Technical Limit's useless margins.
* **CRT Alignment Constraint:** To ensure flawless scanline rendering by shaders, the first displayed screen line must perfectly match the start of a native CRT line. Therefore, the vertical offset (the viewport's Y coordinate) **must strictly be an exact multiple of the scaling multiplier** (e.g., for a 3x scale, Y = 0, 3, 6, 9...).
* **Assumed Asymmetry & Natural Padding:** Top and bottom spaces are balanced as best as possible, but never at the expense of the CRT alignment constraint. Fortunately, the rigid math of integer scaling usually prevents us from cropping the full overscan margin, naturally leaving a few lines intact to serve as breathing room. If the native HUD is off-center, the final viewport will be asymmetrical. This imbalance is an accurate reflection of the source material, not a configuration flaw.

**Rule 2: Fractional Scaling (The Alternative)**

* **Application Condition:** Applies when Integer Scaling amputates the HUD or, conversely, leaves massive, unresolvable black bars (e.g., the Master System's 192-line window).
* **Constraint Release:** Since the native pixel grid is broken (requiring shader interpolation), the requirement to align the Y coordinate to an integer multiple is voided.
* **Manual Breathing Room Injection:** Because we have total control over the scale, we must consciously avoid over-cropping. If we stretch the exact HUD footprint to fit the screen height, the UI will hit the physical bezel. Therefore, we mathematically inject a standard ~4-line native padding into our target window *before* calculating the fractional multiplier.
* **Pure Centering:** The viewport is defined to perfectly balance this top and bottom padding down to the exact screen pixel, centered around a potentially off-center HUD.

### II. The Horizontal Axis: Geometric Mastery

Integer scaling is never forced on the horizontal axis. Width is fractionally adjusted to find the exact sweet spot between filling the 3:2 screen and visual tolerance for sprite distortion—the Aspect Ratio Crime.

**Scenario A: The Original Square Pixel (Healthy 1:1 PAR)**

* **Target:** Consoles designed with square pixels in mind (e.g., Mega Drive, PS1).
* **Application:** If the 1:1 PAR naturally fills the width with the vertical crop applied (Mega Drive), no modification is made. If the 1:1 PAR generates side pillarboxes, a moderate widening cheat (a "Nostalgia Stretch" of ~5%) is applied. This eats up empty space without alerting the brain to the distortion of circular sprites.

**Scenario B: Cathodic Correction (Historical Stretching)**

* **Target:** Consoles with non-square pixels that suffered stretching on period CRT TVs (e.g., SNES, drawn in 8:7 but played in 4:3).
* **Application:** The historical 4:3 render is a geometric heresy (circles becoming 16% stretched ovals in the SNES case for instance). The viewport width is set to a **middle ground**. In this specific case, we can actually exceed the standard threshold of an "Aspect Ratio Crime." Because our visual memory is accustomed to the massive 4:3 distortion, any reduction in that stretch registers psychologically as a geometric improvement. We aim for an exact midpoint between the 4:3 distortion and perfect circles, using the standard Aspect Ratio Crime limit not as a ceiling, but as the absolute minimum width.

**Scenario C: Under-Compression (Historical Compression)**

* **Target:** Arcade systems with very wide resolutions (e.g., CPS-1/2/3 at 384x224), where artists drew deliberately wide sprites so they would look round once mechanically compressed into 4:3 by the arcade monitor.
* **Application:** To adapt to the 3:2 screen (which is wider than a 4:3 display), we apply an **under-compression**. Instead of squishing the image all the way down to get perfect circles (which would generate massive vertical pillarboxes), we squish it slightly less. We allow a visual cheat towards width, tolerating a minute horizontal ovalization, to maximize the physical occupation of the screen.
