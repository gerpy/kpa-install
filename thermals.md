# KPA Thermals

> These are my own tests conducted on my personal unit, in my own home, at my typical ambient temperature. I am not responsible for any damage to your device—proceed at your own risk. That being said, I took care to push the fan speed to 100.0% before reaching any critical throttling thresholds.

![KPA settings](images/kpa-fan-settings.png "KPA settings")

## Test setup

The KPA allows users to define a custom fan curve using six _(temperature, % fan speed)_ coordinates. I conducted empirical tests to find the optimal points and shape the most efficient curve. Each point corresponds to a specific use case—ranging from light to heavy workloads—which translates to different power draws and varying amounts of heat to dissipate.

The more controlled the tests, the better. Fortunately, the KPA allows limiting both CPU and GPU frequencies, effectively capping the maximum power draw for each scenario.

I used the [Burnout Benchmark](https://play.google.com/store/apps/details?id=org.ai.throttling&hl=en) app because it is one of the few tools that allows enabling CPU and GPU stress tests either simultaneously or independently. I tested the following configurations, recording thermal data across 3 or 4 constant fan speeds per scenario:

1. **CPU Off / GPU 420 MHz** (~2.0 W net power draw): Similar to easy 2D games.
2. **CPU Off / GPU 806 MHz** (~3.5 W net power draw): Similar to more demanding 2D games with `halation` shaders (e.g., SF-III FBNeo).
3. **CPU 774 MHz / GPU Off** (~4.8 W net power draw): CPU-heavy 3D emulation with `easy` shaders.
4. **CPU 774 MHz / GPU 420 MHz** (~5.5 W net power draw): High-end 3D emulation with `easy` shaders (e.g., God of War on AetherSX2).
5. **CPU 774 MHz / GPU 806 MHz** (~6.4 W net power draw): Maximum GPU load (e.g., GameNative).
6. **Maximum SoC Load** (> 7.0 W): The throttling threshold (around 99.0°C), requiring a 100.0% fan speed as an absolute safety net.

Emulators rarely saturate the SoC completely like a dedicated synthetic torture tool does. Limiting the CPU performance cores and GPU clock speeds mimics realistic, sustained heavy gaming loads. I ran each configuration for 30.0 minutes at various fixed fan speeds, recording the SoC and battery temperatures to find the lowest fan speed that ensures:
a) An asymptotic temperature curve (indicating the SoC is thermally stabilized).
b) As safe internal battery temperatures as possible.

## Test results

> **Note:** My results demonstrate that even when the SoC temperature appears stabilized, heat can accumulate within the chassis beyond a certain power draw. When the shell can no longer dissipate this soak naturally, the battery temperature rises to unsafe levels (better keep it below 45.0°C IMO). Therefore, it is best to run the most demanding games in relatively shorter sessions.

**The 30.0% physical fan floor:** Comparing 30.0-minute runs between 5.0% and 30.0% across multiple workloads reveals identical temperature trajectories, identical noise levels, and an invariant idle current (-0.19 A). As shown below on the ~4.5 W CPU-only workload, the 10.0% and 30.0% target curves superimpose throughout the entire 30.0-minute test (both ending at 88.5°C on the SoC and 40.2°C vs. 39.9°C on the battery). While the overlay displays simulated RPM values proportional to the software target (~507.0 RPM at 10.0% vs. ~1494.3 RPM at 30.0%), the fan physically spins at a constant minimum floor of 30.0% (~1500.0 RPM) for any setting at or below 30.0%, as is typical for small brushless motors that cannot reliably start below 20.0–30.0%.

![10% vs 30% Fan Speed Comparison](images/kpa-10-vs-30.png "10.0% vs 30.0% Fan Speed Thermal Growth")

To determine the true thermal capacity for each configuration, I tested several constant fan speeds over 30.0-minute runs (grey dashed lines below) and calculated the warming slope (°C/h) between 15.0 and 30.0 minutes to isolate the **equilibrium points** (blue stars). 

For the four high-power workloads above 30.0%, these equilibrium points are strictly derived from the empirical inflection points where the SoC warming slope hits its floor and battery heating is contained. For the first two workloads (~2.0 W and ~3.5 W), which are fully stabilized by the 30.0% physical floor, their software coordinates (`14.0%` and `28.0%`) are manually placed on a virtual lead-in ramp below 30.0%:

| Workload Target | Net Power | Calculated SoC Equilibrium | Internal Battery Temp (Arrival) | Thermal Status & Derivation Notes |
| :--- | :---: | :---: | :---: | :--- |
| **CPU Off / GPU 420 MHz** | ~2.0 W | **46.0°C @ 14.0%** *(30.0% eff.)* | 33.0°C | Fully stable at the 30.0% physical floor (0.0°C/h SoC slope; manual virtual % ramp). |
| **CPU Off / GPU 806 MHz** | ~3.5 W | **66.5°C @ 28.0%** *(30.0% eff.)* | 36.8°C | Mean of 10.0% and 25.0% runs (+5.0°C/h SoC slope); stabilized by the 30.0% floor. |
| **CPU 774 MHz / GPU Off** | ~4.8 W | **85.0°C @ 50.0%** | 41.9°C | Empirical inflection point (+10.0°C/h SoC slope vs. +14.2°C/h at 35.0%). |
| **CPU 774 MHz / GPU 420 MHz** | ~5.5 W | **87.4°C @ 64.0%** | 44.2°C | Asymptotic SoC slope (+3.9°C/h) with a 0.8°C safety margin below 45.0°C on battery. |
| **CPU 774 MHz / GPU 806 MHz** | ~6.4 W | **93.5°C @ 78.0%** | 47.7°C | Asymptotic SoC slope (~+4.5°C/h) with 5.0°C margin below micro-throttling; internal Ohm heating on battery. |
| **Maximum SoC Load** | > 7.0 W | **100.0°C @ 100.0%** | > 48.0°C | Safety shield. |

*(I didn't test a 0.0% fanless setting since I plan to always keep the 30.0% baseline airflow active).*

![Empirical Study and Equilibrium Points](images/kpa-empirical-study.png "Empirical Data & Equilibrium Points")

## Custom fan curve

The KPA firmware allows defining 6 points at 5.0°C and 5.0% intervals, locked at 40.0°C and 100.0°C. 

Rather than forcing the KPA curve to pass through every calculated equilibrium point—which would require a steep `+5.8 %/°C` jump between `85.0°C @ 50.0%` (EQ 3) and `87.4°C @ 64.0%` (EQ 4) followed by an abrupt flattening, causing noticeable fan hunting—I prioritized a smooth, convex progression of slopes (`+0.7` $\rightarrow$ `+0.8` $\rightarrow$ `+1.5` $\rightarrow$ `+2.5` $\rightarrow$ `+5.0 %/°C`):

* **Below 30.0% (`40.0°C @ 10.0%` to `75.0°C @ 35.0%`):** Acts as a gentle geometric ramp that keeps the fan physically clamped at 30.0% up to `68.3°C`, exiting the 30.0% floor at a mild `+0.8 %/°C` angle before reaching the exact **EQ 3** coordinate at `(85.0°C, 50.0%)`.
* **Intentional trade-off on EQ 4 and EQ 5 (`85.0°C @ 50.0%` to `95.0°C @ 75.0%`):** This linear `+2.5 %/°C` segment passes slightly below **EQ 4** (`56.0%` vs. `64.0%` at `87.4°C`) and **EQ 5** (`71.3%` vs. `78.0%` at `93.5°C`). Consequently, under a ~5.5 W load, the console stabilizes at **`89.0°C @ 60.0%`** (instead of `87.4°C @ 64.0%`), and under a ~6.4 W load, at **`94.6°C @ 74.0%`** (instead of `93.5°C @ 78.0%`). Because the SoC warming slope is already locked at its minimum floor (`+3.9` to `+4.0°C/h`) above `55.0%` (for 5.5 W) and `70.0%` (for 6.4 W), accepting this `+1.1°C` to `+1.6°C` higher SoC equilibrium eliminates sudden acoustic surges while keeping the battery under `45.0°C` (`44.7°C`) at 5.5 W.

| KPA Node | Temp (°C) | Fan Speed (%) | Segment Slope & Relationship to Equilibrium Points |
| :---: | :---: | :---: | :--- |
| **1** | **40.0°C** | **10.0%** | Baseline (physically clamped at 30.0%). |
| **2** | **55.0°C** | **20.0%** | `+0.7 %/°C` (Virtual ramp passing through EQ 1 at 46.0°C / 14.0%; physically clamped at 30.0%). |
| **3** | **75.0°C** | **35.0%** | `+0.8 %/°C` (Passes EQ 2 at 66.5°C / 28.6% at 30.0% eff., then smoothly exits the 30.0% floor at 68.3°C). |
| **4** | **85.0°C** | **50.0%** | `+1.5 %/°C` (Matches **EQ 3** at 85.0°C / 50.0% exactly, with a smooth slope transition). |
| **5** | **95.0°C** | **75.0%** | `+2.5 %/°C` (Smoothed ramp passing slightly below **EQ 4** and **EQ 5**, stabilizing them at 89.0°C / 60.0% and 94.6°C / 74.0%). |
| **6** | **100.0°C** | **100.0%** | `+5.0 %/°C` (Matches **EQ 6**; absolute safety ceiling). |

![Custom fan curve projection](images/kpa-custom-fan-curve.png "Final KPA Curve Projection")
