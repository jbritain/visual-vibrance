```
---Buffers---
    0: Main Scene Colour          
    1: Encoded Normal, Sky Lightmap, Block ID
    2: Bloom Colour

---Passes---
    setup       : Compute transmittance LUT for atmosphere
    setup1      : Compute multiple scattering LUT for atmosphere

    prepare     : Compute sky view LUT

    deferred    : Render sky

    composite   : Water & water fog

    

```