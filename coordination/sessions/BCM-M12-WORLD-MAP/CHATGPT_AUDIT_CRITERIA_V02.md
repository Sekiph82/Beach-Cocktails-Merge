# BCM-M12-WORLD-MAP — ChatGPT Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Remediate M12 after owner runtime rejection.

The World Map must become an actual visual map, not a card/list screen, and the runtime refresh error must be eliminated.

## Owner-authoritative findings

Owner runtime screenshots establish:
- current list/card UI is visually unacceptable as a World Map;
- the screen must visually show islands placed on a map;
- only Sunny Cove is open/selectable initially;
- all other displayed islands are visibly locked;
- selecting Sunny Cove currently causes:
  - `Object is locked and can't be freed`
  - `Attempted to free a locked object`
  from `world_map_controller.gd:61 @ refresh()`;
- startup/import also surfaces historical R10 probe parse-error notifications.

These findings supersede the prior source-only visual interpretation.

## Frozen baseline

Do not change:
- gameplay physics;
- R11 table-edge behavior;
- rails/colliders;
- scoring/combo/To-Go rewards;
- M08/M09 feedback;
- gameplay HUD;
- save/progression semantics from M11;
- canonical gameplay assets;
- Island Map/timer/VIP/full-level content.

## Required visual map

Create a real portrait World Map scene.

It must visually read as a map at first glance.

Requirements:
- full-screen map/ocean visual background;
- multiple island locations placed spatially across the map;
- visible route/path or spatial progression relationship is allowed and encouraged;
- island nodes/markers must look like island destinations, not rectangular list rows;
- Sunny Cove must be visually highlighted as the current/open island;
- all other displayed islands must visibly read as locked;
- locked destinations may show lock icon/overlay/name;
- no scrollable card list as the primary presentation.

Temporary campaign art is acceptable, but the composition must look like an actual island map rather than a settings/menu screen.

## Island count / data behavior

Use the campaign definition layer, not hardcoded unlock logic.

For this M12 visual foundation:
- Sunny Cove is the only initially selectable island;
- all other displayed planned island destinations are locked;
- the scene architecture must remain data-driven;
- if canonical production data contains fewer islands than the visual map needs, use clearly-marked placeholder island definitions/data in an M12 presentation fixture or extend canonical island placeholder data without implementing their gameplay.

Do not make locked islands selectable just for presentation.

## Interaction

Sunny Cove:
- selectable;
- selection emits the future Island Map navigation boundary;
- no gameplay launch.

Locked islands:
- tappable for concise locked feedback if desired;
- must not emit Island Map navigation.

Back control must remain safe.

## Critical runtime fix

The current immediate child cleanup in `refresh()` is unsafe.

Do not call immediate `free()` on UI objects that may be locked during signal/call processing.

Use safe deferred cleanup such as:
- `queue_free()`;
- deferred refresh/rebuild;
- or equivalent lifecycle-safe pattern.

Acceptance:
- selecting Sunny Cove repeatedly must not produce debugger errors;
- repeated refresh/rebuild must not produce object-locked/free errors;
- selecting locked destinations must not produce errors.

## Startup/import noise

Owner saw multiple historical R10 test parse-error notifications on project load.

Do not rewrite or falsify historical acceptance tests.

Investigate why historical probe scripts are being parsed during normal editor import/runtime.

If they can be safely isolated/excluded from normal editor loading without changing their historical source meaning, do so.

If Godot necessarily parses them because they live under `res://`, move/archive them to a non-runtime documentation/evidence location only if governance permits and all references are updated.

At minimum:
- normal M12 World Map owner verification should open without a burst of unrelated historical probe parse-error popups.

## Mobile layout

Target portrait 720x1280 reference.

Requirements:
- map fills the gameplay viewport;
- island labels readable;
- no clipping/overlap;
- touch targets comfortable;
- map still visually coherent at the owner's current embedded 405x720 debug preview.

## Tests

Add focused coverage for:
1. WorldMapScene loads;
2. visual island markers are generated from data/presentation definitions;
3. Sunny Cove is the only selectable destination on fresh state;
4. all other displayed destinations are locked;
5. Sunny Cove selection emits navigation exactly once;
6. locked destination selection emits no navigation;
7. repeated Sunny Cove selection/refresh produces no runtime errors;
8. refresh cleanup uses lifecycle-safe deletion and leaves no duplicate island nodes;
9. 720x1280 geometry has no clipping/overlap;
10. map can structurally display the planned island set;
11. save reload reconstructs states;
12. M01-M11 active regressions remain green.

## Visual evidence

Provide normal GUI evidence at 720x1280 for:
- fresh visual World Map;
- locked-island feedback;
- Sunny Cove selected/open state.

Final visual acceptance remains owner-authoritative.

## Scope exclusions

Do not implement:
- Island Map;
- level buttons;
- timed gameplay;
- VIP runtime;
- full Sunny Cove 100 levels;
- M13+ systems.

Codex must not edit `TASKS.md` or ChatGPT-owned audit/criteria files.
