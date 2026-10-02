# BCM-M21 Owner F5 Ruling V07 — Builder Visual Acceptance Loop + Fresh Single-Surface Redesign

Date: 2026-10-02
Status: **OWNER-AUTHORITATIVE**

## 1. Standing builder rule for all future visual/runtime tasks

From V07 onward, any CODEX task that changes a player-visible screen, layout, geometry, input surface, animation, result flow, map, gameplay board, or visual asset MUST perform its own visual/runtime acceptance loop before handoff.

The loop is mandatory:

1. implement;
2. launch Godot in GUI mode;
3. enter the feature through the real production navigation path;
4. use real viewport mouse/touch dispatch where input matters;
5. capture canonical 720×1280 screenshots covering every locked visual question;
6. inspect those screenshots itself;
7. answer every locked visual question PASS/FAIL in a machine-readable and human-readable self-audit;
8. if any item is FAIL or uncertain, do not hand off;
9. fix the issue;
10. rerun Godot and recapture;
11. repeat until every builder self-check is PASS;
12. only then publish handoff for independent ChatGPT/owner review.

Headless tests, scene-tree assertions, JSON reports, coordinates, and builder claims do NOT replace this visual loop.

A builder self-PASS also does not replace independent ChatGPT/owner acceptance.

## 2. Screenshot contract

For every visual question:
- one screenshot must directly show the answer;
- screenshot must be from production runtime, not an editor mock;
- canonical capture = 720×1280;
- no debug overlays in the clean acceptance screenshot;
- a separate debug/geometry overlay may be added as supporting evidence;
- screenshot filename must identify the question/item.

CODEX must create:
- `BUILDER_SELF_VISUAL_AUDIT_V07.md`
- `BUILDER_SELF_VISUAL_AUDIT_V07.json`

Each entry must contain:
- question id;
- exact question;
- PASS/FAIL;
- screenshot path;
- short visual reason;
- iteration number.

No final handoff is allowed with FAIL/UNCERTAIN entries.

## 3. Fresh Sunny Cove gameplay visual

The V06 Sunny Cove composite is rejected as a design method.

Do NOT create V07 by:
- shifting the old table 150 px;
- flattening the current V06 layers with inherited coordinates;
- carrying forward old table placement;
- making the physics fit the old arrangement.

Instead design a new Sunny Cove production image from a blank 720×1280 canvas.

Final output:
`res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07.png`

It is one single flattened image containing:
- Sunny Cove environment/background;
- the complete table;
- table frame/legs if visible;
- table shadow;
- approved fixed decoration.

Old Sunny Cove art may be used as visual reference or source material, but:
- placement must be re-authored from zero;
- no old transform/offset is authoritative;
- the final design must be gameplay-first.

## 4. Gameplay-first composition requirements

Reserve the gameplay surface before decorative composition.

The visible playable tabletop must:
- occupy a large, clear central area;
- be unobstructed by foreground decoration;
- keep HUD clear at the top;
- keep the launch/held-drink area clear at the bottom;
- provide enough usable area for crowded 12-glass states;
- have visually obvious boundaries that can be traced into physics;
- avoid placing the supply/progression UI over the physical table plane.

The table visual and playable physics area must be designed together, not reconciled afterward.

## 5. Physics is authored after final art

Only after `gameplay_surface_v07.png` is frozen:
- measure the visible playable boundary;
- create/update Sunny Cove `playable_geometry`;
- bind walls, bounds, projection, spawn, launch and death logic to that profile;
- never move the final image to satisfy physics;
- never move physics independently without regenerating the visual calibration evidence.

## 6. Mandatory builder visual questions for Sunny Cove

CODEX must answer from runtime screenshots:

### SC-01
Is the final gameplay screen visually one coherent image with no independently drifting table/decor layers?

### SC-02
Does the visible tabletop occupy the intended central gameplay region without being too high or too low?

### SC-03
Is the held/spawn cocktail visually in front of the table/launch area and not behind any table/UI art?

### SC-04
After at least 10 real launches, do cocktails remain visibly on the table plane?

### SC-05
In a 12-glass crowded stress state, are all 12 cocktail visual footprints inside the visible tabletop with no glass hidden behind/below the table frame?

### SC-06
Do side/rear collisions visually occur at the drawn table boundary, with no obvious invisible-wall gap or visible escape?

### SC-07
Does HUD/supply/progression UI stay outside the physical playable tabletop and avoid covering active drinks?

### SC-08
Does WIN appear cleanly with no gameplay drink/effect above it?

All must be builder PASS before handoff.

## 7. World Map visual acceptance loop

The current World Map marker calibration is not accepted merely from coordinates.

CODEX must launch the actual World Map and visually inspect all ten island markers.

Mandatory questions WM-01..WM-10:
For each canonical island, is the marker/ring/label/lock target centered on the actual baked island body it represents?

Islands:
1. Sunny Cove
2. Tiki Island
3. Azure Bay
4. Coconut Beach
5. Sunset Island
6. Party Beach
7. Frozen Paradise
8. Volcano Bay
9. Billionaire Island
10. Final Island

CODEX must:
- take one clean full-map screenshot;
- optionally take close crops for ambiguous islands;
- adjust marker positions;
- recapture;
- repeat until all ten are visually PASS.

No route lines or duplicate island thumbnails may return.

## 8. Current accepted behavior to preserve

Do not change:
- current Sunny Cove Island Map layout;
- connector-lines-off state;
- Main Menu PLAY / SETTINGS / BACK;
- post-result menu input;
- result lifecycle;
- no timer;
- retired +Time;
- pause/resume;
- save/settings persistence.

## 9. Future islands

This design process becomes the standard for every future island:

**fresh single 720×1280 gameplay surface first → freeze art → derive per-island playable geometry → real GUI screenshot self-audit → independent review.**

Do not fabricate all remaining island final art in V07. V07 production redesign scope is Sunny Cove only.

## 10. Handoff

Technical marker remains owner-gated:
`AWAITING_OWNER_F5_ACCEPTANCE_V07`

CODEX may not hand off until its own V07 visual audit contains only PASS results.
