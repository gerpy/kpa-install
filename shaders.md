# Shaders on the KPA

## Shaders for Retroarch

### CRT Shaders

### LCD Shaders



### Nintendo DS

The Nintendo DS is a special case since the `MelonDS DS` core cannot output a layout with both screens (one large and one thumbnail) in an integer scale, thus ruining balanced grid shaders. So we need to prepend a shader that takes a flow with screens on top of eachother, splits both screens and rearranges them in different layout. For the KPA :

- The viewport needs to be setup to `960`x`576` (video options of Retroarch, save with a core override)
- The core needs to be setup with a `top/bottom` or `bottom/top` screen layout (nothing else)

The following files in [https://github.com/gerpy/kpa-install/tree/main/shaders|the shaders reporitory] need to be placed in the `shaders` folder of Retroarch :
- `lcd-dark.params` (with the grid parameters from `lcd1x.slangp`)
- `lcd-nds-color.slangp` (the preset that needs to be loaded if you want color correction)
- `lcd-nds-raw.slangp` (the preset that needs to be loaded if you don't want color correction)
- `nds-layout-gap.slang`
- `nds-pipeline-color.slangp`
- `nds-pipeline-raw.slangp`

## Shaders for standalone emulators

### Dolphin

Built-in shaders don't help much. Clownacy has ported GLSL shaders for the standalone Dolphin emulator:  
https://clownacy.wordpress.com/2023/06/30/porting-crt-shaders-from-retroarch-to-dolphin/. The latest versions are found in this repo: https://github.com/dolphin-emu/dolphin/tree/master/Data/Sys/Shaders/.

The shaders are `crt-pi.glsl` and `crt-lottes-fast.glsl`. They are supposed to expose parameters to the Dolphin UI, but Dolphin on Android lacks the parameters tweaking feature as on Windows. Therefore, the shaders need manual edits of default values for optimal rendering.

Scanlines produce a lot of moiré/banding artifacts on non integer scales devices, to the point that the shaders become unusable. Plus there shouldn't be visible scanlines for 480p content in a first place. To remove scanlines as well as curvature, the shaders need to be modified in an editor by changing their default values. These are modified **`crt-lottes-fast.glsl`** :

- With **mask #1** (aperture grille) : [crt_lottes_fast_mask1.glsl](https://github.com/gerpy/rpm-install/blob/main/Dolphin%20Shaders/crt_lottes_fast_mask1.glsl)

- With **mask #2** (shadow mask) : [crt_lottes_fast_mask3.glsl](https://github.com/gerpy/rpm-install/blob/main/Dolphin%20Shaders/crt_lottes_fast_mask3.glsl)

Shadow masks do a good job at smoothing while aperture grids produce a sharper image.  I chose **mask #2** here. The `crt-pi.glsl` mask is just an aperture grid with scanlines, without added value over `crt-lottes-fast.glsl` IMO.

### NetherSX2

The built-in Triangle and Lottes shaders scale well. Others produce banding/moiré artifacts. I choose **`Lottes`**, which resembles Dolphin's mask #2.

### ARMSX2

ARMSX2 is supposed to run Retroarch shaders. I'll try to run something light just with a grid and no scanline, just as Dreamcast in Retroarch.

### MelonDS

There is a built-in **`LCD`** postprocessing video shader but is darkens the picture way too much. I stand with the Retroarch `MelonDS DS` core and custom grid shaders.

