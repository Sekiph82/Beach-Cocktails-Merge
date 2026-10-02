# BCM-M21 Owner F5 Ruling V06 — Composite Gameplay Surface + Image-Locked Physics

Date: 2026-10-02
Status: **OWNER-AUTHORITATIVE**

Owner manual F5 review after V05 plus four owner-supplied runtime screenshots confirms:

## Owner-visible evidence

1. **World Map**
   - island markers/labels are still not centered on the actual baked island bodies;
   - the map art itself is acceptable;
   - runtime marker placement remains wrong.

2. **Sunny Cove Island Map**
   - current node layout differs from the earlier owner sketch;
   - owner now accepts the current arrangement as a valid layout;
   - connector lines are absent as requested;
   - V06 must not redesign this surface.

3. **Sunny Cove gameplay**
   - the visible wooden table and the playable physics area are still not aligned as one system;
   - launched drinks can appear visually below/behind the visible table/cup presentation;
   - continuing to move independent table layers and physics offsets is rejected.

4. **Result/menu flow**
   - V05 menu/result lifecycle fixes are accepted and must remain unchanged.

## 1. New canonical gameplay architecture

The owner replaces the layered gameplay table/decor architecture with a single composite static gameplay image per island.

Canonical production key:

`gameplay_surface`

Canonical file for Sunny Cove:

`res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`

Requirements:
- exact canonical dimensions: 720×1280;
- contains the complete static gameplay scene:
  - background/environment;
  - table;
  - table shadow;
  - fixed decorative elements approved for that island;
- renders exactly once as the static gameplay visual;
- no independently positioned runtime table/shadow/edge/decor layer may alter the composite.

Dynamic content remains separate above the composite:
- Drink nodes;
- To-Go/VIP runtime content;
- HUD;
- pause/result UI;
- optional simple programmatic launch/aim line.

## 2. Old layered keys become legacy/fallback only

After Sunny Cove migration, these must not drive Sunny Cove production presentation:

- `gameplay_background`
- `gameplay_table`
- `gameplay_table_shadow`
- `table_edge_overlay`
- `launch_zone`
- `table_y_offset_canonical`
- `decor_left/right/back`

Do not delete the source PNGs. They remain source/history inputs.

## 3. Physics follows the final composite image

The old workflow of moving artwork to match a separately frozen table profile is superseded.

Each island may define:

`playable_geometry`

Minimum Sunny Cove fields:
- `playable_polygon`: ordered canonical 720×1280 pixel points tracing the playable table boundary;
- `launch_y`;
- `spawn_y`;
- `death_y`.

Optional metadata may be added only if required by the existing solver.

Rules:
- all rail/wall generation derives from `playable_polygon`;
- all rail queries derive from the same polygon;
- spawn/death/launch logic uses the same profile;
- projection/clamping uses the same profile;
- no independent Y offset exists;
- visual and physics share the same 720×1280 canonical coordinate system;
- no hidden legacy R11 coordinate set may override the island profile.

The existing physics behavior model may be reused, but its coordinates must be recalibrated to the final composite image.

## 4. Sunny Cove is the first canonical migrated island

Create Sunny Cove `gameplay_surface.png` deterministically from the currently accepted Sunny Cove source assets.

The final composite must visually preserve the accepted Sunny Cove identity and wooden table.

Then calibrate Sunny Cove `playable_geometry` against that exact final PNG.

Acceptance requires:
- playable polygon sits on the visible table surface;
- launched drinks visibly land on the table plane;
- 12-glass/crowded states remain visibly inside the table;
- side/rear containment visually matches the drawn table edges;
- no drink appears behind/below the table art because of a coordinate mismatch;
- the static composite never moves independently from physics because it is not layered.

## 5. Deterministic generation / provenance

Add a deterministic build script/tool for the composite.

Record:
- source asset paths;
- source SHA-256;
- exact layer order;
- exact transforms used during composition;
- output SHA-256;
- output dimensions.

The final `gameplay_surface.png` is committed.

No runtime composition of the old layers is allowed for Sunny Cove after migration.

## 6. Geometry calibration evidence

Create an auditable calibration artifact containing:
- composite image path + SHA-256;
- all polygon vertices in canonical pixels;
- launch_y;
- spawn_y;
- death_y;
- a generated 720×1280 debug overlay image with:
  - playable polygon outline;
  - launch line;
  - spawn line/point;
  - death line;
  - a 12-glass stress placement overlay.

The debug overlay is evidence only, not production UI.

## 7. Other islands

Do not fabricate final composite gameplay surfaces for the remaining nine islands in this V06 batch.

The runtime/data schema must support the same contract for future islands.

Unopened islands may retain legacy placeholder/theme data until their owner-designed composite is created.

## 8. Sunny Cove Island Map

Owner accepts the current Island Map layout.

Therefore:
- do not move level nodes;
- do not restore connector lines;
- preserve 100-level pagination/reachability.

## 9. World Map remains a separate release blocker

V06 must also fix World Map marker alignment.

Do not infer marker centers from old `map_position` values alone.

Use the actual baked World Map image and per-island map assets to calibrate marker centers onto the island bodies.

Required:
- one deterministic calibration report;
- all ten markers visually centered on their corresponding islands;
- marker ring/name/lock/click target share the same center;
- no runtime route lines;
- no duplicate island thumbnails.

Owner F5 acceptance remains mandatory.

## 10. Preserve accepted V05 behavior

Do not regress:
- Main Menu PLAY / SETTINGS / BACK;
- post-result menu input;
- result lifecycle;
- no timer;
- retired +Time;
- real mouse/touch gameplay;
- pause/resume;
- persistence.

## Final authority

This ruling supersedes the previous per-layer table-position and rigid-offset approach for Sunny Cove.

The new rule is:

**one static gameplay image + one geometry profile measured from that image.**
