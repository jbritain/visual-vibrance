```
---Buffers---
    0: Main Scene Colour          
    1: Encoded Normal, Sky Lightmap, Block ID
    2: Bloom Colour
    3: Unused
    4: History buffer

---Passes---
    setup           : Compute transmittance LUT for atmosphere
    setup1          : Compute multiple scattering LUT for atmosphere

    prepare         : Compute sky view LUT

    deferred        : Render sky

    composite       : Water & water fog
    composite5      : Fog
    composite90-98  : Bloom
    composite99     : Temporal filter

    

```