# Glimmer

![](/assets/glimmer-banner.png)

Glimmer is a Minecraft shaderpack designed to be simple and performant without looking like it.

## Features
- 'Potato', 'Toaster', 'Integrated Graphics' and 'Dedicated Graphics' presets, designed to run on anything from your fridge to a NASA supercomputer.
- Complete LabPBR 1.3 compliance.
- Shadows, using either the shadow map or approximated from the lightmap.
- Screen space reflections and refractions.
- Procedural 2D clouds.
- Temporal filtering to reduce noise at low sample counts.
- Bloom

## Compatibility
- OpenGL 4.3+ - MacOS is *not supported*, nor is the Raspberry Pi. Most modern GPUs (integrated or dedicated) should work fine.
- Iris 1.6+, Optifine is *not supported*.

## Acknowledgements
- Andrew Hilmer, for his [Shadertoy implementation](https://www.shadertoy.com/view/slSXRW) of Sébastien Hillaire's ['A Scalable and Production Ready Sky and Atmosphere Rendering Technique'](https://github.com/sebh/UnrealEngineSkyAtmosphere)
- [Belmu](https://github.com/BelmuTM) - Reference code for SSR
- [Emin](https://github.com/EminGT) - Shadow bias calculation from [Complementary](https://github.com/ComplementaryDevelopment/ComplementaryReimagined)
- As always, the members of the ShaderLABS Discord server who have helped me get this far learning how to do all this
- Many other people, there are links scattered throughout the code