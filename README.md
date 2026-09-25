> **NOTHING TESTED YET : STILL WAITING FOR MY KPA**

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

## NES (not really 240p)

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

## Master system (192p)

For the Master System (192p) on a 640p display, vertical integer scaling forces unacceptable compromises:

* **Why not 4x:** Scaling to 768 pixels creates a 128-pixel vertical overflow. Cropping 16 native lines from both the top and bottom routinely destroys essential HUD elements like health bars, scores, and menus.
* **Why not 5x:** Scaling to 960 pixels creates a massive 320-pixel overflow. This amputates exactly one-third of the game's total visual area (32 native lines top and bottom), rendering games completely unplayable.

**Conclusion:** Since a 3x scale leaves large black borders and 4x/5x destroy vital gameplay information, strict vertical integer scaling is unviable. The most practical solution is to adopt **non-integer scaling** to fill the screen height. Because non-integer scales permanently break CRT shader alignment, you must disable scanlines entirely and apply a `sharp-bilinear-simple` interpolation shader across both axes to smooth out the resulting scrolling artifacts.

