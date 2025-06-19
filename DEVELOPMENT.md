```
---Buffers---
    0: Main Scene Colour
    1: Encoded Normal, Sky Lightmap, Block ID
    2: Bloom Colour
    3: History buffer
    4: Godrays
    5: Rain mask
    6: Combined depth buffer for SSR
    7: Sky LUT for rough reflections

---Passes---
    prepare1        : Generate sky reflection LUT
    prepare2        : Compute skylight colour & Generate mipmaps for sky reflection LUT




    shadowcomp      : Floodfill propagation

    deferred        : Render sky
    deferred1       : Distant Horizons SSAO

    composite       : Generate combined depth buffer
    composite1      : Water & water fog

    composite3      : Godrays mask
    composite4      : Godrays
    composite5      : Fog

    composite50     : Exposure

    composite80-88  : Bloom
    composite89     : Temporal filter

    composite90     : FXAA
```

Glimmer makes use of a primarily forward rendered pipeline, with the exception of water, which is done deferred. Likewise, fog is also handled in a deferred manner.

A modified version of block_wrangler is used to manage block IDs - if you need to modify them, see `scripts/block_properties.py`.
