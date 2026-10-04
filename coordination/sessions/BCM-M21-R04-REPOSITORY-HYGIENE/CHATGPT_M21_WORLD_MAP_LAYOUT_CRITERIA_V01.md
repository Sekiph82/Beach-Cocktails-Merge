# BCM-M21-001 — World Map 720×1280 Layout Closure Criteria V01

Status: **LOCKED BEFORE EXECUTION**

## A. Preserve accepted current authority

Do not modify:
- any of the ten owner-approved `gameplay_surface_v07_r04.png` files;
- their byte-identical `gameplay_surface.png` runtime copies;
- any `playable_geometry_r04.json`;
- gameplay physics, scoring, To-Go/VIP, campaign progression, persistence;
- current World Map semantic `map_position` centers unless real rendered evidence proves a center itself is wrong and the owner-approved/calibrated intent cannot be preserved otherwise;
- root `TASKS.md`.

BCM-M21-007 cleanup artifacts are frozen except for a new remediation log/evidence file if needed.

## B. Reproduce before changing

Run the current committed M12 probe and capture complete stdout/stderr and exit code.

Record:
- every failed label;
- the exact `get_layout_report()` dictionary for the two-island fixture and canonical 10-island map;
- per-island center, Control rect, visible ring/art/labels rects, MapCanvas bounds, Header bounds, StatusPanel bounds, SelectionBoundary bounds.

Do not edit source before this evidence exists.

## C. Isolate cleanup causality

Prove baseline relation:
- `world_map_controller.gd` at cleanup baseline and current HEAD;
- M12 probe diff;
- current canonical map-position provenance.

The remediation must state explicitly whether the failure predates cleanup.

## D. Real GUI / Godot AI visual evidence

Headless screenshot failure is not sufficient.

Use a renderer-capable Godot run and Godot AI runtime inspection at **720×1280**.

Capture at minimum:
1. fresh World Map with all ten destinations;
2. top region showing Frozen Paradise / Volcano Bay relative to title/header;
3. bottom region showing Sunny Cove/final lower markers relative to status/navigation UI;
4. locked-state example;
5. selected-current example.

Evidence must make visible:
- marker rings/labels;
- title/header;
- map boundaries;
- any overlap/clipping;
- tap target relationship.

## E. Decision rule

### If rendered UI is visually clean

Treat the existing M12 geometry assertion/report as stale or overbroad.

Repair only the reporting/test semantics, for example:
- distinguish horizontal X clipping from vertical Y clipping;
- measure actual visible/interactable marker footprint rather than a hidden/non-authoritative rectangle;
- explicitly allow intentional edge bleed only when it does not overlap protected navigation/header controls.

Do not simply delete the assertion, hardcode PASS, or shrink the test until it stops failing.

### If rendered UI has real overlap/clipping

Fix the minimum presentation layer:
- marker visual footprint;
- map-canvas safe bounds;
- header/map relationship;
- label/ring placement;
- or, only if genuinely necessary, calibrated center position.

Do not move all map positions wholesale.

## F. Functional preservation

World Map must still:
- show 10 planned islands;
- preserve OPEN/LOCKED/CURRENT/COMPLETE states;
- reject locked selection;
- emit exactly one navigation boundary per accepted selection;
- preserve current semantic island ordering and current island ids;
- retain map click/touch behavior;
- retain selected/focus behavior;
- keep current world-map art assets.

## G. Mandatory tests

After remediation:
- clean Godot import/parse/boot PASS;
- `tests/m12_world_map_probe.gd` PASS twice consecutively with no file changes between runs;
- renderer-capable `m12_world_map_gui_capture.gd` or replacement visual capture PASS;
- M10 PASS;
- M11 PASS;
- M13 PASS;
- M14 PASS;
- M20 app-shell/navigation PASS;
- R04 surface/profile authority probe PASS;
- asset validator PASS;
- `git diff --check` PASS.

## H. Evidence

Create under:
`coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/evidence/world-map-layout-v01/`

Required:
- pre-fix M12 full log;
- pre-fix layout JSON;
- 720×1280 pre-fix GUI screenshots;
- post-fix M12 run-1/run-2 logs;
- post-fix layout JSON;
- post-fix 720×1280 GUI screenshots;
- regression summary JSON/MD.

Required builder log:
`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_LAYOUT_CLOSURE_V01.md`

Final marker:
`AWAITING_GPT_M21_WORLD_MAP_LAYOUT_AUDIT_V01`
