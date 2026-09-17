# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V02

Status: **ISSUED — SUPERSEDES V01**

This task closes two concrete R09 blockers. Do not redesign unrelated systems.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V02.md`

Do not edit TASKS.md, ChatGPT-owned files, canonical PNGs or historical logs. Do not start M08+.

## Problem 1 — physical rear wall and rear target still disagree with the owner-required model

R09 moved the measured rear tabletop boundary to independently measured source y=457, but current production `_build_walls()` still builds `TopRail` from stale first side-polyline points around source y=472.

There is also a newly clarified owner rule for the rear target.

### Mandatory owner formula

For every cocktail level L01-L12:

`rear_target_y = rear_table_y`

The rear target Y is exactly the common rear table Y.

Do NOT add cocktail dimensions to this formula.

Forbidden rear-target formulas include:

`rear_target_y = rear_table_y + collider_radius`

`rear_target_y = rear_table_y + body_half_extent_y`

`rear_target_y = rear_table_y + sprite_height / 2`

`rear_target_y = rear_table_y + drink_height / 2`

Also forbidden:
- hardcoded per-level rear target Y values;
- per-level rear offsets;
- any extra Y clearance based on cocktail width, height, collider size or sprite size.

All cocktail levels use the same exact target:

`drink_rear_target_y = rear_table_y`

### Required physical closure

Make the physical `TopRail` inward collision face use the same `rear_table_y` boundary.

The rear system must therefore have one shared Y across:
- `rear_table_y`;
- rear target/clamp behavior;
- physical TopRail collision face.

A moving RigidBody2D must be able to reach this target without being stopped earlier by a stale hidden wall.

Validate real moving/contact behavior for at least L01, L06 and L12 at rear-center, rear-left and rear-right. Do not prove this only by spawning directly at coordinates.

Do not restore source y=472 as rear truth unless new independent evidence proves y=457 wrong.

## Problem 2 — actual desktop/F5 runtime can still generate non-held drinks without intended owner input

R09 headless no-input regression passed, but the R09 log also records that a Windows-display run received input-like events and generated non-held drinks.

The owner-visible failure occurs in the desktop game, so this must be investigated rather than excluded.

Required work:
- reproduce the normal desktop/Windows-display project run;
- instrument/log the actual input sequence reaching `ShotController`;
- identify exactly what can call `_begin_drag()` and `_launch()` without intentional owner interaction;
- fix the root input-gating issue so a held preview cannot become fired from focus/window/synthetic/duplicate events;
- preserve intentional mouse and touch drag/release shooting;
- preserve rapid-launch after intentional shots.

Do NOT disable legitimate stocked To-Go fulfillment. The goal is to stop accidental drink creation/firing, not to remove order logic.

## Required runtime proof

Retain evidence for a normal desktop/display-backed idle run of at least 30 seconds showing:
- exactly one HELD preview;
- zero non-held drinks;
- score unchanged at 0;
- zero merges;
- zero To-Go deliveries;
- no held-to-fired transition;
- captured input log/event trace sufficient to show no unintended firing path occurred.

Also retain a deliberate-input smoke proving one intentional drag/release still fires exactly one drink and immediately provides the next HELD preview.

## Preservation

Preserve:
- owner-approved held-drink alignment;
- R08 To-Go placement;
- BEST/SCORE layout;
- NEXT;
- baked 2x6 progression;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- collision/momentum/merge/combo/scoring/economy;
- persistence;
- Game Over/restart;
- rapid launch;
- no guide line.

Do not modify canonical PNGs.

## Regression

Run the full active M01-M07 suite plus R09/R10 no-input and rear-physics tests, Godot import/startup, parse/check-only and `git diff --check`.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V01.md`

Commit and push the implementation, then the immutable log.

Final response must return only:
- R10 log URL
- implementation SHA
- exact final regression result
- `AWAITING_AUDIT`

Then STOP.
