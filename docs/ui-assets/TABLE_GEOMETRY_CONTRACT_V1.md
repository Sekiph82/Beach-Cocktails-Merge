> **SUPERSEDED BY V2 — HISTORICAL ONLY.** Do not use this file as geometry authority for new table artwork. Current authority: [TABLE_GEOMETRY_CONTRACT_V2.md](TABLE_GEOMETRY_CONTRACT_V2.md).
>
> V1's bottom-corner tabletop polygon does not provide the required lower apron/leg/progression region and is not the live R11 runtime boundary.

# Beach Cocktails Merge — Canonical Table Geometry Contract V1

Branch: `ui-assets`

Base viewport: **720 × 1280 portrait**.

This contract applies to the current Sunny Cove replacement table and every future island table. The table art may change theme, but the geometry must not.

## Owner direction

The current gameplay table is visually too wide.

The replacement table must:
1. place the player-facing/front outer-left table corner exactly on the viewport bottom-left corner;
2. place the player-facing/front outer-right table corner exactly on the viewport bottom-right corner;
3. use a wider rear edge than the earlier narrow concept;
4. preserve one identical gameplay footprint for every level, map, and island;
5. never change play-area geometry based on island skin or level.

## Canonical normalized silhouette

Use normalized viewport coordinates for the outer tabletop master silhouette:

- front-left outer corner = **(0.000, 1.000)**
- front-right outer corner = **(1.000, 1.000)**
- rear edge centered on x = **0.500**
- target rear-edge width = **0.640 × viewport width**
- rear-left outer x = **0.180**
- rear-right outer x = **0.820**

At 720 px viewport width:
- front-left x = 0 px
- front-right x = 720 px
- rear-left x = 129.6 px
- rear-right x = 590.4 px
- rear width = 460.8 px

Production rasterization may round symmetrically to whole pixels, but all island tables must use the same rounded master.

## Rear Y / depth

The rear Y coordinate and gameplay depth must be derived once from the accepted gameplay composition and then frozen in a machine-readable geometry file.

Codex must inspect the current runtime geometry and create:

`assets/ui_assets/tables/table_geometry_v1.json`

The file must record:
- viewport_width = 720
- viewport_height = 1280
- normalized front/rear corner coordinates
- actual integer raster corner coordinates
- canonical rear_y
- canonical launch_y
- canonical danger_y
- canonical playable-boundary points
- geometry_version = 1

The rear edge should be visibly wider than the old/current visual table while leaving HUD readability intact. The target width is 64% of viewport width unless a documented owner-proof preview shows a tiny adjustment is necessary. Any adjustment requires updating this contract before asset acceptance.

## One geometry for all islands

All island table skins must be produced from one master alpha/silhouette mask.

Required invariant:
- same PNG canvas dimensions;
- same tabletop outer silhouette;
- same front corners;
- same rear corners;
- same rear Y;
- same launch alignment;
- same playable-boundary mask;
- same table depth;
- same perspective centerline.

Only these may vary:
- surface material;
- color;
- trim;
- inlay;
- island motifs;
- decorative texture;
- lighting/reflection treatment that does not move the edge.

## Gameplay-area integration rule

The visual table and the authoritative 2D gameplay boundary must eventually describe the same table.

The current main-branch physics must **not** be modified during the first asset-production pass. To avoid conflicts with the other Codex working on main:

- first create the new canonical table geometry specification, all table art, overlays, and preview evidence entirely on `ui-assets`;
- do not touch `scripts/game_manager.gd`, current gameplay scene files, or existing runtime asset paths in the asset-generation prompt;
- record the future integration as an explicit task in `ui-assets-tasks.md`.

When integration is later authorized on the isolated branch:
- replace the current table presentation with the new canonical silhouette;
- update the authoritative playable-boundary points to the same one frozen geometry;
- apply the same playable area to all islands and all levels;
- preserve drink-to-drink colliders and accepted R11 footprint semantics unless a separate physics audit explicitly changes them;
- do not create island-specific collision geometry.

## Validation

Asset-production validation must include:
- alpha-mask comparison of all 10 gameplay tables;
- exact front-corner test;
- exact rear-width test;
- exact same-canvas test;
- overlay contact sheet showing all 10 tables aligned to one silhouette;
- geometry JSON consistency check.

A one-pixel asymmetry caused by symmetric raster rounding may be documented. Any larger geometry variation is a failure.
