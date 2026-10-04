# What to Do If the Gameplay Surface Changes — V07-R04

**Current technical authority:** `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`

**Per-island machine-readable authority:** `assets/ui_assets/campaign/islands/<island>/playable_geometry_r04.json`

**Runtime boundary and physics:** accepted R11 implementation in `scripts/game_manager.gd` and `scripts/drink.gd`

## Current workflow

1. Keep the owner's frozen `gameplay_surface_v07_r04.png` for each island.
2. Derive that island's `gameplay_surface.png` as a byte-identical copy; never reuse another island's art.
3. Calibrate and measure against the exact image SHA-256 at 720x1280.
4. Record the per-island measurements and unchanged shared playable boundary in `playable_geometry_r04.json`.
5. Generate the geometry-debug and twelve-level collider-footprint overlays from that exact image.
6. Run `python tools/ui_assets/prepare_gameplay_surface_r04.py`, `python tools/ui_assets/rebuild_asset_catalog_r04.py`, `python tools/ui_assets/validate_assets.py`, and the focused R04 Godot probe.
7. Preserve the accepted rear-edge safety margin, zero added side clearance, R11 rails, collider radii, physics, scoring, and progression behavior.

The table, its edge treatment, and contact shadows are integrated into the R04 surface. There is no separate table, overlay, or shadow asset to align. The five independent island-map/completion images remain `complete_badge.png`, `map_background.png`, `map_title.png`, `theme_badge.png`, and `world_icon.png`.

The superseded V2 split-table documents and calibration scripts are historical evidence only. They must not be used to generate, validate, or bind current gameplay artwork.
