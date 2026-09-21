# UI Assets V1 production library

This branch-only library is generated for the M12 V05 visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `tables/`: frozen common geometry JSON, silhouette mask, and edge overlay masters.
- `source/`: generator provenance and style-reference notes only, including the generated remediation direction board.

## Generation and export

V05 production uses the accepted V04 visual masters plus Codex image-generation source atlases for the new visual families. Technical post-processing is limited to crops, resizes, alpha masks, composites, metadata, contact sheets, and evidence assembly; Pillow/procedural primitives are not used as final primary artwork. The owner-supplied logo, mandatory reference boards, and frozen table geometry/mask are preserved exactly. The table skins are derived from the shared 720x1280 alpha polygon defined by `tables/table_geometry_v1.json`; only the clipped material treatment changes per island.

`V05_ASSET_REGEN_STATUS.csv` records one validation row for each of the 398 manifest assets. `v05_sources/` contains the three visual source atlases used for technical extraction, while the contact sheets and `docs/evidence/m12/v05/` provide builder evidence.

`tools/ui_assets/generate_assets.py` is retained as historical tooling and is not the V05 final-art generator.

`tools/ui_assets/validate_assets.py` checks manifest coverage, PNG decoding, dimensions, alpha expectations, table canvas/mask equality, preserved logo/mask/geometry blobs, front-corner/rear-width geometry, untouched protected paths, and remediation scope restrictions.

The global, island, table, screen, semantic-icon, and major-screen contact sheets are audit evidence, not runtime integration. `source/style_reference_board*.png` are visual direction references only. Runtime table/play-area and logo replacement remain deferred to UIA-M14.
