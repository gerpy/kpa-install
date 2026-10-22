The KPA permits to setup a custom fan curve with _(temperature, % fan)_ points. I have conducted tests to discover adequate points and shape the curve. Each point corresponds to a use case such as heavy use, moderate use, light use, each leading to a different power draw and thus a different amount to dissipate and thus a different adequate fan speed. The more controled the tests, the best. Fortunately, the KPA permits to limit CPU and GPU frequencies, thus bounding the drawn power.

I'm using the [https://play.google.com/store/apps/details?id=org.ai.throttling&hl=fr](Burnout Benchmark) app to test because it is the only one letting to enable both CPU and GPU burn at the same time, on just one or te other. I have tested the following setting, each time with 3 or 4 constant fan speeds :

- Throttling point (about 99°C) requiring to max security and a 100% fan speed, the point of other points beeing to avoid getting there while not beeing too noisy
- Full GPU with performance cores at 774MHz 
- 1/2 GPU and CPU with performance cores at 774MHz (global drawn power similar to high end PS2/GC games)
- Off GPU and CPU with performance cores at 774MHz (global drawn power similar to demanding 3D gaming)
- Full GPU only (global drawn power similar to demanding 2D games with shaders) 
- 1/2 GPU only (global drawn power similar to easy 2D games with shaders)

Emulators don't saturate GPUs and CPUs because they cannot run ecery single core full speed as a dedicated torture tool sur an Burnout Throttle does, hence the limited CPU performance cores and GPU settings. I have tested several fan speeds 30 min for each use case and recordded temperatures (CPU/GPU and battery) to discover the lowest fan speed that a) has an asymptotic shape ensuring that the temperature is under control at this point and b) the battery temperature doesn't explode.

