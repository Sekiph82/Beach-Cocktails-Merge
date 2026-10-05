# BCM-M21-001 — Owner-First World Map Visual Preview Criteria V02

Status: **LOCKED BEFORE PREVIEW EXECUTION**

This V02 supersedes the prior R01 instruction to begin production implementation immediately.

## 1. Owner-supplied background authority

The owner has supplied a specific 720×1280 PNG and requires it to be the World Map background.

Expected local/repository path:

`assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v01.png`

Requirements:
- exact dimensions: 720×1280;
- use this PNG as-is as the preview background;
- do not regenerate, repaint, recolor, crop, stretch, blur, or replace it;
- do not use `world_map_background.png` as the visual base for the preview.

If the owner PNG is missing, STOP with:
`OWNER_WORLD_MAP_BACKGROUND_REQUIRED`

## 2. Preview-only gate

Before ANY production World Map implementation, Codex must create the proposed final visual composition for owner review.

Allowed before owner approval:
- read repository assets/code/data;
- create one visual candidate PNG;
- create preview-only supporting layout JSON or render script under the session evidence directory;
- add/commit the owner-supplied background asset if it is present locally and not yet tracked;
- commit preview/evidence only.

Forbidden before owner approval:
- modifying `scripts/campaign/world_map_controller.gd`;
- modifying `scripts/campaign/island_entry.gd`;
- modifying `scripts/campaign/campaign_navigation_controller.gd`;
- modifying `scripts/campaign/island_map_controller.gd`;
- modifying `scenes/campaign/WorldMapScene.tscn`;
- modifying `data/campaign/islands.json`;
- changing map positions in production data;
- changing hitboxes/navigation;
- changing tests to accept the new composition;
- implementing the composite map;
- starting BCM-M21-006;
- editing root `TASKS.md`.

## 3. Existing World Map asset palette

Use the current PNG assets under:

`assets/ui_assets/campaign/world_map/`

The preview must use the existing ten island PNGs:
1. `sunny_cove.png`
2. `tiki_island.png`
3. `azure_bay.png`
4. `coconut_beach.png`
5. `sunset_island.png`
6. `party_beach.png`
7. `frozen_paradise.png`
8. `volcano_bay.png`
9. `billionaire_island.png`
10. `final_island.png`

Existing compatible supporting assets may also be used where visually useful:
- `route_line.png`
- `route_marker.png`
- `route_marker_complete.png`
- `route_marker_current.png`
- `island_name_panel.png`
- `island_locked_overlay.png`
- `world_map_title_panel.png`
- `world_map_compass.png`
- `world_map_boat.png`
- `world_clouds_back.png`
- `world_clouds_front.png`

Do not regenerate the ten island PNGs.

## 4. Intended visual concept

Design the preview as the intended production World Map, not as a debug diagram.

The map must:
- be exactly 720×1280;
- keep the supplied sky/horizon/sun/ocean background clearly visible;
- place all ten islands as separate composited island bodies;
- make the ten-island progression visually understandable from Sunny Cove to Final Island;
- use a clean mobile-readable route, preferably a flowing/serpentine progression rather than a rigid spreadsheet grid;
- avoid clipping;
- avoid island-on-island overlap;
- keep island labels legible;
- preserve breathing room around the horizon and upper sky;
- keep decorative assets subordinate to islands and progression;
- make Sunny Cove visually obvious as the starting/current island;
- show the other islands in a representative locked/future state without obscuring their identity;
- avoid invisible hotspot/debug visuals;
- avoid fake gameplay UI;
- avoid visual clutter.

The preview is allowed to resize the 220×220 island source images for composition, but must preserve their aspect ratio and identity.

## 5. Owner review artifact

Create exactly one primary owner-review image:

`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_V02.png`

Also create:

`coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/evidence/owner-preview-v02/WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json`

The JSON records, for each island:
- island id;
- source PNG;
- preview center x/y;
- preview rendered width/height;
- label center;
- route anchor;
- representative state.

This is preview evidence only and MUST NOT become production authority before owner approval.

## 6. Required checks before handoff

Verify:
- preview is exactly 720×1280;
- exact owner background is used;
- all ten island source PNGs appear exactly once as island bodies;
- no production code/scene/data file listed in section 2 changed;
- root TASKS.md unchanged;
- Git status clean after commit/push;
- local HEAD = origin/main = remote main.

## 7. Mandatory stop

After publishing the preview, STOP.

Do not begin implementation.

Final marker exactly:

`AWAITING_OWNER_WORLD_MAP_VISUAL_APPROVAL_V02`

The only valid next decisions are:
- `OWNER_WORLD_MAP_VISUAL_APPROVED_V02`
- `OWNER_WORLD_MAP_VISUAL_CHANGES_REQUIRED_V02`

Production implementation requires a later owner approval and a new/superseding implementation authorization.
