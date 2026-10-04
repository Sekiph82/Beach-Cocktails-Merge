# UI Assets V1 production library

This branch-only library is generated for the M12 V05 visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `campaign/islands/<island>/`: five map/completion PNGs plus an island-specific R04 source and byte-identical runtime gameplay surface.
- `tables/`: historical V1/V2 geometry JSON only; the split-table PNG masters were retired when R04 became the gameplay-screen authority.
- `source/`: generator provenance and style-reference notes only, including the generated remediation direction board.

## Generation and export

The owner-selected R04 gameplay surface for each island is the single gameplay-screen art authority. The generic runtime image is a byte-identical copy of that island's `gameplay_surface_v07_r04.png`; each image is SHA-bound to its `playable_geometry_r04.json`. The former V2 split-table production contract is historical for this screen.

`V05_ASSET_REGEN_STATUS.csv` is historical V05 evidence. `v05_sources/` contains visual source atlases used for technical extraction, while retained contact sheets and `docs/evidence/m12/v05/` provide historical builder evidence.

`tools/ui_assets/generate_assets.py` is retained as historical tooling and is not the V05 final-art generator.

Run `tools/ui_assets/prepare_gameplay_surface_r04.py`, `tools/ui_assets/rebuild_asset_catalog_r04.py`, and `tools/ui_assets/validate_assets.py` to prepare and verify the R04 image/profile/evidence set. The validator requires the per-island R04 source/runtime pair, profile hashes, shared gameplay boundary, measurement/debug/footprint evidence, and an island image inventory without retired split gameplay layers.

The global, island, screen, semantic-icon, and major-screen contact sheets are historical audit evidence, not runtime integration. `source/style_reference_board*.png` are visual direction references only.
