# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V01

Status: **ISSUED**

This task closes two concrete R09 blockers. Do not redesign unrelated systems.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`

Do not edit TASKS.md, ChatGPT-owned files, canonical PNGs or historical logs. Do not start M08+.

## Problem 1 — physical rear wall still disagrees with the new rear boundary

R09 changed `rear_table_y` / clamp to the independently measured source y=457 boundary.

But current production `_build_walls()` still builds `TopRail` from `left_points[0]` / `right_points[0]`, whose side-polyline source points remain at y=472.

That means the moving RigidBody2D can collide with the old physical wall before reaching the new rear target.

Required end state:
- physical TopRail inward face uses the exact same independently measured rear boundary as `rear_table_y`;
- clamp, rear target formula and physical collision all agree;
- moving drinks can physically reach the intended rear edge;
- L01/L06/L12 prove real motion/contact, not only direct spawn/clamp math.

Keep the mandatory formula:

`rear_target_center_y = actual_visible_rear_table_y + body_half_extent_y`

and invariant:

`visible_glass_body_top_y = actual_visible_rear_table_y`

Do not restore source y=472 as rear truth.

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
