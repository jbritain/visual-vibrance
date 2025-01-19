# Glimmer

> [!NOTE]
> This branch is intended to test a script I created called Viewport, designed to streamline the organisation of shader passes. 

![](/assets/glimmer-banner.png)

Glimmer is a Minecraft shaderpack designed to be simple and performant without looking like it.

[![modrinth](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/available/modrinth_vector.svg)](https://modrinth.com/mod/glimmer-shaders)
[![discord](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/social/discord-plural_vector.svg)](https://discord.gg/b9SHNcvs6c)
[![curseforge](https://cdn.jsdelivr.net/npm/@intergrav/devins-badges@3/assets/cozy/available/curseforge_vector.svg)](https://legacy.curseforge.com/minecraft/shaders/glimmer-shaders)

## Features
- 'Potato', 'Toaster', 'Integrated Graphics' and 'Dedicated Graphics' presets, designed to run on anything from your fridge to a NASA supercomputer.
- Complete LabPBR 1.3 compliance.
- Distant Horizons support!
- 'Infinite Ocean', adding water stretching out of render distance.
- Shadows, using either the shadow map or approximated from the lightmap.
- Screen space reflections and refractions.
- Procedural 2D clouds.
- Temporal filtering to reduce noise at low sample counts.
- Bloom.

## Compatibility
- OpenGL 4.3+ - MacOS is *not supported*, nor is the Raspberry Pi. Most modern GPUs (integrated or dedicated) should work fine.
- Iris 1.6+, Optifine is *not supported*.

## Acknowledgements
- Andrew Hilmer, for his [Shadertoy implementation](https://www.shadertoy.com/view/slSXRW) of Sébastien Hillaire's ['A Scalable and Production Ready Sky and Atmosphere Rendering Technique'](https://github.com/sebh/UnrealEngineSkyAtmosphere)
- [Belmu](https://github.com/BelmuTM) - Reference code for SSR
- [Emin](https://github.com/EminGT) - Shadow bias calculation from [Complementary](https://github.com/ComplementaryDevelopment/ComplementaryReimagined)
- [NinjaMike](https://github.com/NinjaMike) - Directional lightmapping method
- [sixthsurge](https://github.com/sixthsurge) - A decent amount of code reference from [Photon](https://github.com/sixthsurge/photon)
- [Null](https://github.com/Null-MC/) - Help porting in the atmospheric scattering code
- [BuilderB0y](https://github.com/builderb0y) from whom I shamelessly stole the idea of an infinite ocean plane
- As always, the members of the ShaderLABS Discord server who have helped me get this far learning how to do all this
- Many other people, there are links scattered throughout the code

## Get in touch
If you have an issue with Glimmer or just want to chat, you can [join my Discord server](https://discord.gg/b9SHNcvs6c) or find me in `#jbritains-shaderpacks` in the [shaderLABS Discord server](https://discord.gg/RpzWN9S).
