# BCM-M21-001 + BCM-M21-006 — Composite World Map + Sunny Cove Navigation Remediation Criteria V01

Status: **LOCKED BEFORE EXECUTION**

## A. Sync / preservation

Use AGENTS.md generalized safe-sync.

Preserve all owner-local work, including current tracked/untracked plugin/project changes.

Root `TASKS.md` is read-only to Codex.

## B. Reproduce owner failure first

Before product edits:
1. launch production F5/app-shell flow at 720×1280 canonical viewport;
2. enter World Map through Main Menu → PLAY;
3. capture the current full map;
4. attempt a real mouse click on the visible Sunny Cove island body;
5. record whether `IslandEntry.pressed`, `WorldMapController.island_map_requested`, `CampaignNavigationController.show_island_map`, and `IslandMapController.configure_island` fire;
6. record current hotspot rect vs visible Sunny Cove art rect.

Do not assume the navigation controller itself is broken. Prove where the real-input chain stops.

## C. New World Map composition

Production World Map must no longer depend on a baked ten-island image.

Create a new current base asset:
`assets/ui_assets/campaign/world_map/world_map_ocean_base_v01.png`

Requirements:
- exactly 720×1280;
- no island bodies baked into the image;
- clean tropical/ocean/cartographic background;
- enough visual contrast for ten island PNGs, labels, routes, header and bottom status;
- no fake hotspot guides;
- no text baked into the base;
- mobile-safe readability.

Use the ten existing 220×220 transparent island PNG files as the actual island visuals.

Do not regenerate or replace those ten owner-specified island PNGs.

## D. One authority per island

For every island, the same layout record must own:
- visual island center;
- visual island size/scale;
- state ring/marker;
- label;
- pointer/touch hit region;
- route anchor.

No independent hidden-hotspot coordinate system.

Recommended authority:
- canonical `map_position` center in `data/campaign/islands.json`;
- optional explicit per-island presentation scale only if actually required.

If scale metadata is added, define and validate it once. Do not scatter magic sizes through code.

## E. Layout requirements

At 720×1280:
- all 10 islands visible without clipping;
- no island art overlaps header, status panel or bottom navigation boundary;
- no island hit target overlaps another island hit target;
- labels readable and attached to the correct island;
- route progression readable from Sunny Cove through Final Island;
- decorative clouds/boat/compass may remain only if they do not obstruct islands or hit targets;
- Sunny Cove must be visually obvious and clickable;
- locked/current/complete/open states remain readable without duplicating a second island thumbnail.

Do not optimize for old baked coordinates. Recalibrate all positions as needed.

## F. IslandEntry architecture

Remove/supersede the baked-map assumptions in `island_entry.gd`.

Required:
- `IslandArt.visible = true` in production composite map;
- art texture comes from the island's canonical `map_asset`;
- Button/hitbox encompasses the visible island presentation;
- visual center and hit center coincide within a small audited tolerance;
- locked state may tint/dim/add a lock treatment, but must not swap in a second duplicate island body;
- no invisible island target disconnected from art.

## G. Real Sunny Cove opening

Add a production-path real-input regression.

At minimum mouse:
- enter World Map through app shell/campaign navigation;
- derive Sunny Cove's actual runtime hit center;
- send real mouse move/press/release through viewport input;
- assert exactly one Sunny Cove selection/navigation event;
- assert navigation view becomes `ISLAND_MAP`;
- assert active island id = `sunny_cove`;
- assert IslandMapController island id = `sunny_cove`;
- assert 100 level buttons are built;
- assert Sunny Cove `theme.island_map_background` is loaded/visible.

Also add touch-tap coverage using real `InputEventScreenTouch` if the existing test harness supports it.

Direct method invocation cannot satisfy this criterion.

## H. Preserve campaign truth

Do not change:
- island ids;
- order_index;
- next_island_id;
- unlock_rule semantics;
- level counts/content;
- rewards;
- save schema;
- gameplay R04 surface/profile files;
- physics/scoring/To-Go/VIP.

Only World Map presentation/layout metadata and the minimum navigation/input fix are authorized.

## I. Current tests must be rewritten to current truth

Update M12 and any stale World Map tests so they validate:
- island art is visible;
- art and hitbox share center;
- ten island PNGs are the production visual bodies;
- new ocean base is the production background;
- no baked-island dependency;
- 720×1280 bounds/overlap;
- state transitions;
- real Sunny Cove click/tap opens M13 Island Map.

Do not delete meaningful state/progression assertions.

## J. Visual evidence

Use renderer-capable Godot + Godot AI.

Capture 720×1280:
1. fresh full composite World Map;
2. top half;
3. bottom half;
4. Sunny Cove selected/current;
5. one locked island;
6. Sunny Cove Island Map immediately after a real click on Sunny Cove.

Provide a layout JSON with for each island:
- id;
- source PNG;
- center;
- visual rect;
- hit rect;
- label rect;
- state;
- route anchor;
- overlaps/clipping.

Owner visual acceptance remains required.

## K. Mandatory regression

Must PASS:
- new focused composite World Map probe;
- M12 twice consecutively;
- M13;
- M20 app-shell;
- real mouse Sunny Cove entry;
- real touch Sunny Cove entry where supported;
- M10;
- M11;
- M14;
- R04 surface/profile authority 10/10;
- asset validator;
- clean Godot import/parse/boot;
- `git diff --check`.

## L. Evidence / log

Create:
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/world-map-composite-v01/`
- `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/WORLD_MAP_COMPOSITE_LAYOUT_V01.json`
- `docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_COMPOSITE_NAV_R01.md`

Final marker:
`AWAITING_GPT_M21_WORLD_MAP_COMPOSITE_NAV_AUDIT_V01`
