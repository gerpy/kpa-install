# Shaders on the KPA

## Shaders for Retroarch

### CRT Shaders

For the KPA, the shaders need to be robust to non integer scaling with a modest 640p resolution. They also need to run on the mid range processor and not drain the battery too much. The `crt-guest-advance-fast` shader runs on the KPA with easy to emulate platforms but at the expense of heat and battery. I was unable to get balanced scanlines out of `hyllian` and I have focused on the `easymode` familly instead :

- `easymode-halation` for 8-16bit systems to get the enhanced color gradients, de-dethering and organic look
- the more clinical regular `easymode` to smooth 32-64bit 3D a bit while retaining details and not emphasing the poor textures contrasting with ugly upsclaed renders

I also use a super simple mask shader to provide Dreamcast a more organic look.

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

Other parameters are tuned so that the global luminance and colors roughly match the input picture, to ensure homogeneity between platforms. Thonk about enabling color corrections in core for best results. 

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

