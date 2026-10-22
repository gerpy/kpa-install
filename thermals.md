The KPA permits to setup a custom fan curve with _(temperature, % fan)_ points. I have conducted tests to discover adequate points and shape the curve. Each point corresponds to a use case such as heavy use, moderate use, light use, each leading to a different power draw and thus a different amount to dissipate and thus a different adequate fan speed. The more controled the tests, the best. Fortunately, the KPA permits to limit CPU and GPU frequencies, thus bounding the drawn power.

I'm using the [https://play.google.com/store/apps/details?id=org.ai.throttling&hl=fr](Burnout Benchmark) app to test because it is the only one letting to enable both CPU and GPU burn at the same time, on just one or te other. I have tested the following setting, each time with 3 or 4 constant fan speeds :

1. 1/2 GPU only (global drawn power similar to easy 2D games with shaders)
2. Full GPU only (global drawn power similar to demanding 2D games with shaders) 
3- Off GPU and CPU with performance cores at 774MHz (global drawn power similar to demanding 3D gaming)
4. 1/2 GPU and CPU with performance cores at 774MHz (global drawn power similar to high end PS2/GC games)
5. Full GPU with performance cores at 774MHz 
6. Throttling point (about 99°C) requiring to max security and a 100% fan speed, the point of other points beeing to avoid getting there while not beeing too noisy

Emulators don't saturate GPUs and CPUs because they cannot run ecery single core full speed as a dedicated torture tool sur an Burnout Throttle does, hence the limited CPU performance cores and GPU settings. I have tested several fan speeds 30 min for each use case and recordded temperatures (CPU/GPU and battery) to discover the lowest fan speed that a) has an asymptotic shape ensuring that the temperature is under control at this point and b) the battery temperature doesn't explode.

Graphical interpretations and interpolations lead me to consider these points, based or raw experiments :

1. a
2. b
3. c
4. 88°C $\rightarrow$ 62%
5. 93°C $\rightarrow$ 78%
6. 97°C $\rightarrow$ 95%

The KPA permits to define 6 points at a resolution of _($5°C$, 5%)_, the first one for 40°C and the last one for 100°C. The better match I could find with these 6 points, allowing for curve smoothing, is :

1. 40°C $\rightarrow$ 5%
2. b
3. c
4. 90°C $\rightarrow$ 65%
5. 95°C $\rightarrow$ 80%
6. 100°C $\rightarrow$ 100%




