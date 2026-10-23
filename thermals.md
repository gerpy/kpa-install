# KPA Thermals

> These are my own tests conducted on my personal unit, in my own home, at my typical ambient temperature. I am not responsible for any damage to your device—proceed at your own risk. That being said, I took care to push the fan speed to 100% before reaching any critical throttling thresholds.

## Test setup

The KPA allows users to define a custom fan curve using six _(temperature, % fan speed)_ coordinates. I conducted empirical tests to find the optimal points and shape the most efficient curve. Each point corresponds to a specific use case—ranging from light to heavy workloads—which translates to different power draws and varying amounts of heat to dissipate.

The more controlled the tests, the better. Fortunately, the KPA allows limiting both CPU and GPU frequencies, effectively capping the maximum power draw for each scenario.

I used the [Burnout Benchmark](https://play.google.com/store/apps/details?id=org.ai.throttling&hl=en) app because it is one of the few tools that allows enabling CPU and GPU stress tests either simultaneously or independently. I tested the following configurations, recording thermal data across 3 or 4 constant fan speeds per scenario:

1. **CPU Off / GPU 420 MHz** (~2.0 W net power draw): Similar to easy 2D games.
2. **CPU Off / GPU 806 MHz** (~3.5 W net power draw): Similar to demanding 2D games with heavy CRT shaders (e.g., SF-III FBNeo).
3. **CPU 774 MHz / GPU Off** (~4.8 W net power draw): CPU-heavy emulation (e.g., Sega Saturn).
4. **CPU 774 MHz / GPU 420 MHz** (~5.5 W net power draw): High-end 3D emulation (e.g., God of War on AetherSX2).
5. **CPU 774 MHz / GPU 806 MHz** (~6.4 W net power draw): Maximum GPU load (e.g., PC ports).
6. **Maximum SoC Load** (>7.0 W): The throttling threshold (around 99°C), requiring a 100% fan speed as an absolute safety net.

Emulators rarely saturate the SoC completely like a dedicated synthetic torture tool does. Limiting the CPU performance cores and GPU clock speeds mimics realistic, sustained heavy gaming loads. I ran each configuration for 30 minutes at various fixed fan speeds, recording the SoC and battery temperatures to find the lowest fan speed that ensures:
a) An asymptotic temperature curve (indicating the SoC is thermally stabilized).
b) Safe internal battery temperatures.

## Test results

> **Note:** My results demonstrate that even when the SoC temperature appears stabilized, heat can accumulate within the chassis beyond a certain power draw. When the shell can no longer dissipate this soak naturally, the battery temperature rises to unsafe levels (I advise keeping it below 45°C). Therefore, it is best to run the most demanding games in relatively shorter bursts.

Based on these raw 30-minute stress tests, analyzing the exact thermal slopes (°C/h) leads to the following underlying **equilibrium points** (the sweet spots where the SoC stabilizes without over-ventilating and generating useless noise):

| Workload Target | Net Power | Ideal SoC Equilibrium | Internal Battery Temp (Arrival) | Thermal Status & Notes |
| :--- | :---: | :---: | :---: | :--- |
| **1. Light 2D** | ~2.00 W | **46°C @ 5%** *(or 7%)* | 33.0°C | Fully stable, perfectly silent. |
| **2. 2D + Shaders** | ~3.48 W | **66°C @ 21%** | 36.7°C | Fully stable, very quiet. |
| **3. CPU Heavy** | ~4.76 W | **85°C @ 50%** | 41.9°C | Stable, safe battery limits. |
| **4. PS2 / GC** | ~5.52 W | **88.6°C @ 61%** | 44.6°C | SoC stabilized, battery nearing 45°C limit. |
| **5. GPU Ceiling** | ~6.35 W | **94°C @ 77%** | 47.8°C | SoC stable, but battery overheats (internal $I^2R$ heating). |
| **6. Anti-Throttling** | >7.00 W | **100°C @ 100%** | >48.0°C | Safety shield to prevent micro-throttling drops at 98.5°C. |

*(I didn't test a strictly fanless setup at 0% since I plan to always keep a gentle baseline airflow).*

![Empirical Study and Equilibrium Points](kpa-empirical-study.png "Empirical Data & Equilibrium Points")

## Custom fan curve

The KPA firmware allows defining exactly 6 points at 5°C and 5% intervals, hard-locked at 40°C for the first node and 100°C for the last. 

To project our physical equilibrium points onto this strict grid without creating erratic fan behaviors (i.e., avoiding unnecessary bumps and maintaining a perfectly smooth, convex progression), the mathematically optimal coordinates are:

| KPA Node | Temp (°C) | Fan Speed (%) | Progression (Segment Slope) |
| :---: | :---: | :---: | :--- |
| **1** | **40°C** | **5%** | Baseline |
| **2** | **50°C** | **10%** | `+0.50 %/°C` (Matches the 46°C / 7% sweet spot) |
| **3** | **65°C** | **20%** | `+0.67 %/°C` (Matches the 66°C / 21% sweet spot) |
| **4** | **85°C** | **50%** | `+1.50 %/°C` (Matches the 85°C / 50% sweet spot exactly) |
| **5** | **95°C** | **80%** | `+3.00 %/°C` (Matches the 88°C and 94°C sweet spots) |
| **6** | **100°C** | **100%** | `+4.00 %/°C` (Absolute safety ceiling) |

![Custom fan curve projection](kpa-custom-fan-curve.png "Final KPA Curve Projection")
