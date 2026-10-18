> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes, as well as to assist with some of the mathematical calculations and code.

# Shaders on the KPA

> All the files mentioned below can be found in [my custom shader collection directory](https://github.com/gerpy/kpa-install/tree/main/shaders).

## Shaders for RetroArch

### CRT Shaders

For the KPA, shaders need to handle non-integer scaling gracefully on a modest 640p screen. They also need to run smoothly on its mid-range processor without draining the battery too quickly. The `crt-guest-advanced-fast` shader runs fine on easy-to-emulate platforms, but at the expense of heat and battery life. Since I was unable to get balanced scanlines out of `hyllian`, I focused on the `easymode` family instead:

- `easymode-halation` for 8/16-bit systems, to get enhanced color gradients, de-dithering, and an organic look.
- The more clinical regular `easymode` to slightly smooth out 32/64-bit 3D graphics while retaining detail—avoiding the jarring contrast between low-res textures and overly sharp upscaled polygons.

I also use a very simple mask shader preset, `crt-noscan.slangp`, to give the Dreamcast a more organic look. It relies on the stock `dotmask.slang` (for the shadow mask) and `image-adjustment.slang` (for controlled bilinear smoothing and color/luminance compensation). To work properly, `crt-noscan.slangp` must be placed in the root of RetroArch's shader folder, alongside `noscan-pipeline.slangp` and `crt-noscan.params` (the latter is easily tweakable to adjust the look).

Following the same modular structure, my other presets are:

- The super lightweight `crt-easy.slangp` paired with `crt-easy.params` for tweaking (based on the regular stock `crt-easymode`).
- The reasonably lightweight `crt-halation.slangp` paired with `crt-halation.params` for tweaking (based on `crt-easymode-halation`).

### LCD Shaders

Some consoles had backlit screens and others front lit screens. The front lit screen have a light back that reflects the front light, and shaders with light grid lines make more senses. Other consoles have a backlit screen and in that case, dark grid lines are more accurate. 

| Console | Original Screen Technology | Emulation Grid / Lighting Style |
| :--- | :--- | :--- |
| **Game Boy (GB / DMG)** | Unlit passive LCD (reflective) | **Light grid** (simulates ambient light / reflective background) |
| **Game Boy Color (GBC)** | Unlit reflective LCD | **Light grid** (simulates ambient light) |
| **Game Boy Advance (GBA Original)** | Unlit reflective LCD (very dim) | **Light grid** (plus gamma/brightness correction) |
| **Game Boy Advance SP (AGS-001)** | Front-lit LCD | **Neutral / Light grid** (front-light simulation) |
| **Game Boy Advance SP (AGS-101)** | Backlit LCD | **Dark grid** (standard backlit display) |
| **WonderSwan (Mono / Color / Crystal)** | Unlit reflective STN/TFT LCD | **Light grid** (reflective background) |
| **Neo Geo Pocket Color (NGPC)** | Unlit reflective STN LCD | **Light grid** (reflective background) |
| **PlayStation Portable (PSP)** | Backlit TFT LCD | **Dark grid** (standard backlit display) |
| **Nintendo DS (Phat / Lite)** | Backlit TFT LCD | **Dark grid** (standard backlit display) |

Hence, I have 2 shaders families :

- `lcd-dark` and `lcd-nds` and `lcd-psp` provide a dark grid. The shaders are all based on `lcd1x` and the parameters are factorized in `lcd-dark.params`. I didn't choose `lcd-grid-v2` for dark grids because it is too heavy for the KPA. And I was not convinced by the usefullness of the RGB separation of `lcd3x` on the small and low res KPA screen. 
- `lcd-light` provide a light grid. The shader is based on `simpletex` with the parameters in `lcd-light.params`. The paper background is didabled because on the low res KPA screen, it looks gross. 

Other parameters are tuned so that the global luminance and colors roughly match the input picture, to ensure homogeneity between platforms. Thonk about enabling color corrections in core for best results. To do so, the LCD shaders also use the following files : `lcd-dark.params` and `lcd-light.params`.

### Nintendo DS

The Nintendo DS is a special case since the `MelonDS DS` core cannot output a layout with both screens (one large and one thumbnail) in an integer scale, thus ruining balanced grid shaders. So we need to prepend a shader that takes a flow with screens on top of eachother, splits both screens and rearranges them in different layout. For the KPA :

- The viewport needs to be setup to `960`x`576` (video options of Retroarch, save with a core override)
- The core needs to be setup with a `top/bottom` or `bottom/top` screen layout (nothing else)

The following files in [https://github.com/gerpy/kpa-install/tree/main/shaders|the shaders reporitory] need to be placed in the `shaders` folder of Retroarch :
- `lcd-dark.params` (with the grid parameters from `lcd1x.slangp`)
- `lcd-nds.slangp`
- `nds-layout-gap.slang`
- `nds-pipeline-color.slangp`
- `nds-pipeline-raw.slangp`

## Shaders for standalone emulators

### Dolphin

Built-in shaders don't help much. I have asked Gemini to adapt my above slang shader to the synthetic single pass glsl shader `crt-dolphin.glsl`.

### ARMSX2

ARMSX2 is supposed to run Retroarch shaders. It needs further testing but so far, I 'm just trying with my above `crt-noscan.slangp`, to import in ARMSX2. If it doesn't work, I'll also ask Gemini to synthetise the required files in one single `crt-armsx2.slangp` preset with a corresponding `crt-armsx2.slang` shader.

### MelonDS

There is a built-in **`LCD`** postprocessing video shader but is darkens the picture way too much. I stand with the Retroarch `MelonDS DS` core and custom grid shaders.

