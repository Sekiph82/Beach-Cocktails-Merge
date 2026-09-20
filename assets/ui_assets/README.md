# UI Assets V1 production library

This branch-only library is generated for the `ui-assets` visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `tables/`: frozen common geometry JSON, silhouette mask, and edge overlay masters.
- `source/`: generator provenance and style-reference notes only.

## Generation and export

`tools/ui_assets/generate_assets.py` creates original raster art with Pillow using a deterministic seed, shared typography/material helpers, and the ten locked theme palettes. The owner-supplied logo is copied from the local source after checkerboard-background removal only; no logo artwork is regenerated. The table skins are rasterized from one shared 720x1280 alpha polygon defined by `tables/table_geometry_v1.json`.

`tools/ui_assets/validate_assets.py` checks manifest coverage, PNG decoding, dimensions, alpha expectations, table canvas/mask equality, front-corner/rear-width geometry, untouched protected paths, and V01 scope restrictions.

The four contact sheets are audit evidence, not runtime integration. Runtime table/play-area and logo replacement remain deferred to UIA-M14.
