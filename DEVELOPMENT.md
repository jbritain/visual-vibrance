```
---Buffers---
    0: Main Scene Colour          
    1: Encoded Normal, Sky Lightmap, Block ID
    2: Bloom Colour
    3: History buffer
    4: Godrays
    5: Rain mask

---Passes---
    setup           : Compute transmittance LUT for atmosphere
    setup1          : Compute multiple scattering LUT for atmosphere

    prepare         : Compute sky view LUT
    prepare1        : Compute skylight colour by taking several hemisphere samples

    shadowcomp      : Floodfill propagation

    deferred        : Render sky
    deferred1       : Distant Horizons SSAO

    composite       : Water & water fog

    composite4      : Godrays
    composite5      : Fog
    
    composite90-98  : Bloom
    composite99     : Temporal filter
```

Glimmer makes use of a primarily forward rendered pipeline, with the exception of water, which is done deferred. Likewise, fog is also handled in a deferred manner.

A modified version of block_wrangler is used to manage block IDs - if you need to modify them, see `scripts/block_properties.py`.