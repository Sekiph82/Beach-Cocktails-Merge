# Gameplay Surface Contract V07-R04

Status: **OWNER-DIRECTED TECHNICAL AUTHORITY — 2026-10-04**
Supersedes for gameplay-screen visuals: `TABLE_GEOMETRY_CONTRACT_V2.md` and `TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`.

## 1. One authority per island

Each island has its own frozen R04 source at:

`assets/ui_assets/campaign/islands/<island>/gameplay_surface_v07_r04.png`

The canonical runtime asset is:

`assets/ui_assets/campaign/islands/<island>/gameplay_surface.png`

The two files must be byte-identical within that island family. Sunny Cove's image must never be copied into another island. All surfaces are 720×1280 RGB PNGs.

The runtime `theme.gameplay_surface` and the island's `playable_geometry_r04.json` must identify the canonical `gameplay_surface.png` and its SHA-256. A changed image requires a fresh profile hash, geometry review, debug/stress proofs, manifest update, and focused tests before it can be used.

## 2. Geometry profile

`playable_geometry_r04.json` is the sole source of the shared gameplay polygon and launch/spawn/death positions for its island. `data/campaign/islands.json` references the profile; it must not contain a second copied geometry authority.

The profile records:
- island ID and profile schema/version;
- canonical surface path and SHA-256;
- versioned R04 source path and SHA-256;
- viewport dimensions;
- `playable_polygon`, `launch_y`, `spawn_y`, and `death_y`;
- calibration method and the debug/stress evidence paths.

All ten polygons must preserve the same accepted gameplay boundary unless the owner explicitly authorizes a gameplay-geometry change. Visual table rails must support the full cocktail footprints, including the established rear-only safety margin and zero added side clearance. Do not change accepted physics, collider sizes, launch speed/deceleration, merge motion, or scoring as part of visual calibration.

## 3. Calibration and evidence

Calibration reads the exact canonical per-island `gameplay_surface.png`, verifies its SHA-256 against the matching R04 source, and records pixel-space measurements at 720×1280. Calibration must not resize, recolor, or rewrite the source image.

Geometry-debug, twelve-level collider-footprint, and embedded-shadow identity proofs are deterministic overlays rendered from that exact surface. The profile is the measurement record and binds each proof hash to that surface. These are evidence outputs under:

`coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/r04-technical-validation/`

These outputs are not runtime assets and never replace the canonical source. The table and contact shadows are part of the integrated surface, so there is no independent shadow image or alignment transform. The shadow identity proof makes this visible without creating a second shadow asset. The old separate gameplay-table fit and table-shadow proofs do not apply to R04.

## 4. Runtime and asset validation

Runtime resolves the surface and profile for the selected island, verifies 720×1280 dimensions and matching SHA-256, then uses the profile geometry for all ten islands. Missing or mismatched assets fail closed; there is no per-island split-table visual fallback.

The asset validator checks:
- all ten R04 source and canonical assets exist and are byte-identical per island;
- all are 720×1280 RGB PNGs;
- each profile's paths and SHA-256 values match both files;
- each profile geometry matches the shared cross-island gameplay boundary;
- evidence overlays are derived from the matching surface;
- asset manifest and dimensions catalog contain current assets only;
- retired gameplay-only table/background/overlay/shadow layers are absent from island runtime packs.

The runtime gameplay UI remains layered and dynamic. Cocktails, HUD values, score/order labels, danger line, held marker, and progression content must not be baked into the static gameplay surface when the existing runtime renders them independently.

## 5. Retained separate island assets

These island-map/completion assets remain separate from the gameplay surface:
- `complete_badge.png`
- `map_background.png`
- `map_title.png`
- `theme_badge.png`
- `world_icon.png`

Global cocktail, HUD, effect, and non-gameplay screen assets remain governed by their existing contracts.

## 6. Regression and cleanup

R04-specific tests validate surface/profile identity and geometry. Accepted gameplay regression checks remain in place; tests whose only purpose was asserting retired split-layer paths are removed or replaced.

Owner ruling 2026-10-04 authorizes a repository-hygiene pass after owner acceptance of all ten R04 gameplay surfaces/geometries. During that explicit cleanup task:
- superseded visual evidence, rejected candidate renders, retired split-table assets, stale fixtures/scripts, obsolete JSON/provenance/calibration records, and generated/orphaned `*.import` files may be deleted after repository-wide reference analysis;
- old rules/tests that conflict with the R04 authority must be updated, replaced, or retired;
- current asset manifests/dimension catalogs must be rebuilt from the retained current set;
- the ten R04 source/runtime/profile triples plus the five retained island map/completion assets remain protected;
- historical text references alone do not make a retired binary/evidence file a current dependency;
- active TASKS/current contracts/tests must not be left with broken required references.

The cleanup must end with all current R04 validation and gameplay/campaign regressions passing.
