# BCM-M21-001 — Owner-Approved World Map Production Integration Criteria V05

Status: **LOCKED BEFORE EXECUTION**

This V05 package is the only active production implementation authority for BCM-M21-001.

It supersedes the historical direct-implementation R01 package and follows the owner-approved V04 visual preview.

## A. Sync / governance

1. Start from the canonical Desktop checkout:
   `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
2. Read `AGENTS.md`, root `TASKS.md`, this criteria file, the V05 prompt, and the owner V04 visual acceptance before editing.
3. Use the AGENTS sync-first rules.
4. Root `TASKS.md` is read-only to Codex.
5. Do not start BCM-M21-006.
6. Do not create a new branch.
7. Preserve the clean canonical addon/project state already synchronized to GitHub.

## B. Frozen owner-approved visual target

The production World Map must reproduce the owner-approved V04 preview, not redesign it.

Owner acceptance:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_WORLD_MAP_VISUAL_ACCEPTANCE_V04.md`

Accepted preview:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_V02.png`

Accepted layout metadata:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json`

Accepted preview SHA-256:
`d2c9693f5040a5a67b9292a07a0b19873840b23f842d3e6d5e44954760d8895f`

Selected owner background:
`assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png`

The owner-approved composition includes:
- title/frame in the sky above the ocean;
- Sunny Cove starting upper-right;
- irregular island placement;
- intentionally different island render sizes;
- ten separate island PNGs;
- existing route/decorative language;
- clouds and boat;
- no rigid same-row/same-column grid.

Do not alter that visual direction during implementation.

## C. Production composition architecture

The production World Map must be a real runtime composition.

Required:
1. Use the exact owner V02 background asset as the World Map base.
2. Use the ten existing island PNGs as ten separate runtime visual bodies:
   - sunny_cove.png
   - tiki_island.png
   - azure_bay.png
   - coconut_beach.png
   - sunset_island.png
   - party_beach.png
   - frozen_paradise.png
   - volcano_bay.png
   - billionaire_island.png
   - final_island.png
3. Use the existing compatible World Map decoration assets as needed to match the accepted preview:
   - route_line.png
   - route_marker*.png
   - island_name_panel.png
   - island_locked_overlay.png where appropriate
   - world_map_title_panel.png
   - world_map_compass.png
   - world_map_boat.png
   - world_clouds_back.png
   - world_clouds_front.png
4. Do NOT use the flattened accepted preview PNG as the production background or click surface.
5. Do NOT use the rejected baked `world_map_background.png` as the production visual authority.
6. Keep the old baked background file in the repository for historical rollback only; do not delete it in this task.

## D. Exact accepted layout authority

At canonical 720×1280, production layout must use the accepted V04 centers/sizes below.

| Island | Center px | Render size px | Label center px | State in fresh/default preview |
|---|---:|---:|---:|---|
| sunny_cove | (540, 300) | 225×225 | (540, 392) | CURRENT |
| tiki_island | (175, 440) | 183×183 | (175, 510) | LOCKED |
| azure_bay | (485, 545) | 234×234 | (485, 642) | LOCKED |
| coconut_beach | (145, 645) | 192×192 | (145, 720) | LOCKED |
| sunset_island | (410, 765) | 213×213 | (410, 850) | LOCKED |
| party_beach | (610, 870) | 186×186 | (610, 940) | LOCKED |
| frozen_paradise | (400, 1020) | 228×228 | (400, 1112) | LOCKED |
| volcano_bay | (180, 920) | 207×207 | (180, 1003) | LOCKED |
| billionaire_island | (180, 1180) | 177×177 | (180, 1247) | LOCKED |
| final_island | (615, 1178) | 201×201 | (615, 1257) | LOCKED |

Route anchor = island center for all ten islands unless the accepted preview renderer proves a different decoration-only anchor is necessary.

Allowed implementation tolerance at 720×1280:
- island visual center: ±2 px;
- island rendered width/height: ±2 px;
- label center: ±4 px;
- hitbox center: ±2 px from island visual center.

The runtime must not silently normalize all island sizes to one common size.

## E. One authoritative layout record per island

Do not scatter accepted positions/sizes across multiple scripts.

Implement one canonical production layout source that owns each island's:
- center;
- rendered size/scale;
- label placement;
- route anchor.

Preferred implementation:
- preserve `map_position` as the canonical center in island data;
- add one explicit per-island presentation size/scale field if needed;
- derive the hitbox from the actual visible island rect;
- derive route anchor from the same center;
- derive label placement from one bounded offset/field.

If you choose another structure, it must still be one data authority per island and must be testable.

Do not make the evidence JSON itself a production runtime dependency.

## F. Island visual / hitbox contract

For every island:
1. `IslandArt.visible == true` in production.
2. Art texture comes from the canonical island `map_asset`.
3. The visible island body is the click/touch target.
4. Button/hit region must fully cover the visible island presentation without extending into a neighboring island.
5. Hitbox and visual centers must coincide within ±2 px.
6. No separate invisible displaced hotspot system.
7. No second duplicate island thumbnail.
8. Locked/current/open/complete state treatment may add tint/ring/marker/lock treatment but must preserve island identity.
9. State overlays must not make the island unclickable when it is legitimately selectable.

## G. Title / decoration contract

Match the accepted V04 composition:
- World Map title/frame stays in the sky above the ocean and must not cover the island field.
- Clouds remain decorative and may not block click/touch input.
- Boat remains decorative and may not block click/touch input.
- Compass/back navigation remain usable and must not overlap island hitboxes.
- Decorative route graphics must render below labels and interactive state UI where required.
- All decorative controls/nodes that are not intended to receive input must use mouse filtering/input configuration that cannot steal island input.

## H. Real Sunny Cove navigation blocker

Reproduce and fix the real owner-reported failure through the production input path.

Required chain:
`visible Sunny Cove island art → actual mouse/touch input → IslandEntry pressed → WorldMapController.select_island("sunny_cove") → island_map_requested("sunny_cove") → CampaignNavigationController.show_island_map("sunny_cove") → IslandMapController.configure_island(...) → visible Sunny Cove Island Map`

Do not satisfy this with direct method calls only.

### Mouse acceptance

Through the real application/campaign shell:
1. enter Main Menu;
2. press PLAY/CONTINUE;
3. arrive at production World Map;
4. derive the actual Sunny Cove runtime hit center;
5. send real viewport mouse move/press/release;
6. assert exactly one selection/navigation event;
7. assert current view becomes `ISLAND_MAP`;
8. assert active island id is `sunny_cove`;
9. assert IslandMapController island id is `sunny_cove`;
10. assert 100 level buttons are built;
11. assert Sunny Cove island-map background is loaded/visible.

### Touch acceptance

Add the same production-path coverage with `InputEventScreenTouch` when supported by the existing Godot test harness.

If touch cannot be executed headlessly, provide a renderer/editor-capable test and document exact evidence. Do not replace real input with direct method invocation.

## I. Preserve campaign/gameplay truth

Do not change:
- island ids;
- order_index;
- next_island_id;
- unlock-rule semantics;
- 100-level Sunny Cove content;
- level content/rewards;
- save schema;
- progression semantics;
- R04 gameplay surface/profile assets;
- physics;
- scoring;
- To-Go;
- VIP;
- no-timer owner ruling;
- M22+ plugin presentation work.

Only the World Map visual/layout/input/navigation seams needed for BCM-M21-001 are authorized.

## J. Production tests

Update stale World Map tests to the new owner-approved truth.

Required assertions:
- owner V02 background is production background;
- rejected baked background is not production visual authority;
- all ten canonical island PNGs are rendered as separate visible bodies;
- exact accepted centers/sizes match within tolerance;
- island sizes remain intentionally non-uniform;
- visual rect and hit rect centers coincide;
- no hitbox overlaps another island hitbox;
- labels remain in bounds and attached to correct islands;
- route order remains Sunny Cove → Tiki → Azure → Coconut → Sunset → Party → Frozen → Volcano → Billionaire → Final;
- locked/open/current/complete states still work;
- real Sunny Cove mouse click opens M13;
- touch path opens M13 where supported;
- repeated World Map ↔ Island Map navigation does not duplicate map instances.

Do not delete meaningful existing M12/M13 progression assertions.

## K. Visual parity evidence

Use renderer-capable Godot and the current production scene at 720×1280.

Capture:
1. full production World Map fresh/default state;
2. top section showing title + Sunny Cove;
3. middle section;
4. bottom section;
5. Sunny Cove current/selectable state;
6. one locked island;
7. Sunny Cove Island Map immediately after a real mouse click.

Create:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/production-v05/`

Create a production layout report:
`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/WORLD_MAP_PRODUCTION_LAYOUT_V05.json`

For each island record:
- id;
- source PNG;
- expected center/size from approved preview;
- actual runtime center/size;
- hit rect;
- label rect;
- route anchor;
- state;
- center/size deltas;
- overlap/clipping result.

The builder may visually compare against the approved preview but may not self-approve owner parity.

## L. Mandatory regression matrix

Must PASS after the final code change:
- focused V05 World Map production/layout probe;
- M12 World Map probe twice consecutively;
- M13 Island Map probe;
- M20 app-shell probe;
- real mouse Sunny Cove entry;
- real touch Sunny Cove entry where supported;
- M10 campaign architecture regression;
- M11 save/progression regression;
- M14 gameplay-session bridge regression;
- R04 10/10 gameplay surface/profile authority validation;
- asset validator;
- clean Godot import/parse/boot;
- `git diff --check`.

If any locked regression fails, do not claim completion.

## M. Builder log / publication

Create:
`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_PRODUCTION_V05.md`

The log must include:
- starting HEAD;
- sync proof;
- exact production files changed;
- exact visual-layout implementation authority;
- real mouse/touch evidence;
- test commands and exact results;
- visual evidence paths;
- known unverified items;
- confirmation root `TASKS.md` was untouched;
- final synchronization proof.

Commit logical implementation/evidence changes and push to `main`.

Final required state:
- working tree clean;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Final marker exactly:

`AWAITING_GPT_M21_WORLD_MAP_PRODUCTION_AUDIT_V05`

Codex must stop there. Codex does not close BCM-M21-001 and does not start BCM-M21-006.
