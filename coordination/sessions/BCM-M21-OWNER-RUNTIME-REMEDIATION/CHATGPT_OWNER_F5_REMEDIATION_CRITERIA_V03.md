# BCM-M21 Owner F5 Remediation V03 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

Authority:
- `OWNER_F5_RULING_V03.md`
- `OWNER_RULING_V01.md`
- `OWNER_RUNTIME_AUDIT_V01.md`
- V02-R01 technical audit and owner screenshots.

## A — scope

Fix only the owner-observed V03 failures.

Preserve:
- no-timer contract;
- retired +Time;
- real mouse/touch launch;
- R11 physics/contact geometry;
- To-Go/scoring/progression;
- save/settings persistence;
- accepted input fixes.

CODEX must not edit root `TASKS.md`.

## B — debug window

`project.godot`:
- viewport = 720×1280;
- window override = **800×1422**;
- stretch mode unchanged.

## C — World Map

Required:
1. remove/disable runtime yellow `IslandRoute` `Line2D`;
2. no dynamic route polyline is visible;
3. baked white dotted route art remains untouched;
4. hotspot centers derive from `islands.json.map_position`;
5. hard-coded `BAKED_ISLAND_CENTERS` cannot override canonical data;
6. Sunny Cove center resolves from [0.16,0.83] and appears lower-left;
7. duplicate island art remains hidden;
8. lock/current/open rings remain centered on the hotspot.

Produce a 720×1280 capture and a machine-readable center table.

## D — Island Map theme

`IslandMapController` must render the selected island's `island_theme.island_map_background` as a full-viewport TextureRect behind path/nodes.

Sunny Cove must resolve to:
`res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png`

Fallback flat color may be used only if the theme path is absent/invalid.

Produce Sunny Cove Island Map capture proving the themed background is visible.

## E — gameplay visual composition

For Sunny Cove:
- visible composition is limited to background, table shadow, wooden gameplay table, table edge overlay, launch zone, gameplay objects and HUD;
- `decor_left/right/back` are absent from runtime scene tree or invisible;
- no legacy/extra layer obscures the wooden table.

Add an automated runtime inventory report listing every Sprite2D/TextureRect texture path and z/layer for gameplay before first shot.

The report must prove no runtime node uses:
- `decor_left.png`
- `decor_right.png`
- `decor_back.png`

Also prove the resolved Sunny Cove table texture is:
`sunny_cove/gameplay_table.png`.

If another texture is the actual occluder, name it in the log and remove only that visual layer.

R11 physics coordinates must remain byte/source-equivalent unless a separate audit stop is raised.

## F — WIN modal terminal cleanup

On terminal WIN/LOSE:
- all active Drink nodes become hidden before result presentation;
- held/next world-space shot object is hidden;
- transient world effects/trails are cleared or hidden;
- no Drink/feedback Sprite2D may be visible over the result card;
- gameplay input remains blocked;
- result modal is in a dedicated topmost CanvasLayer above gameplay HUD/world;
- Next Level / Retry / Island Map remain functional.

Focused test must create a crowded board, resolve WIN, then assert:
- visible Drink count = 0;
- visible transient world effect count = 0;
- result modal visible;
- result modal canvas layer > gameplay HUD canvas layer;
- no further score/delivery mutation after terminal.

Produce 720×1280 WIN capture.

## G — regression

Re-run:
- real mouse/touch 10/10 input;
- no timer / one-hour survival;
- M02 physics/merge;
- R11 geometry;
- M03 To-Go/scoring;
- M07-R06 HUD;
- M08/M09;
- updated M14/M15/M16;
- M18;
- M19 map/theme;
- M20 result/save;
- M21 progression 100/100;
- `git diff --check`.

## H — owner handoff

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V03.md`

Checklist must contain only the five corrected owner-visible surfaces plus quick regression confirmations and leave all PASS/FAIL boxes blank.

Technical success marker:

`AWAITING_OWNER_F5_ACCEPTANCE_V03`

Do not claim release-ready.
