# UI Assets V1 production library

This branch-only library is generated for the `ui-assets` visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `tables/`: frozen common geometry JSON, silhouette mask, and edge overlay masters.
- `source/`: generator provenance and style-reference notes only, including the generated remediation direction board.

## Generation and export

`tools/ui_assets/generate_assets.py` creates original raster art with Pillow using explicit semantic pictogram, island landmark, material-skin, screen-composition, and effect renderers. The owner-supplied logo is copied from the local source after checkerboard-background removal only; no logo artwork is regenerated. The table skins are rasterized from one shared 720x1280 alpha polygon defined by `tables/table_geometry_v1.json`; only the clipped material treatment changes per island.

`tools/ui_assets/validate_assets.py` checks manifest coverage, PNG decoding, dimensions, alpha expectations, table canvas/mask equality, preserved logo/mask/geometry blobs, front-corner/rear-width geometry, untouched protected paths, and remediation scope restrictions.

The global, island, table, screen, semantic-icon, and major-screen contact sheets are audit evidence, not runtime integration. `source/style_reference_board*.png` are visual direction references only. Runtime table/play-area and logo replacement remain deferred to UIA-M14.
