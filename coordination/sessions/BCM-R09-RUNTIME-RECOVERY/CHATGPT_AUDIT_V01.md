# BCM-R09-RUNTIME-RECOVERY — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Scope audited
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CODEX_LOG_V01.md`
- locked criteria `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_CRITERIA_V01.md`
- implementation commit `736fd31d0522c4a72835d28cbf7afa061a348949`
- current `scripts/game_manager.gd`
- R09 no-input and rear-boundary probes

## Accepted improvements
1. The dirty local `project.godot` was inspected instead of blindly treated as authoritative. The committed project still points to `res://scenes/main.tscn`, with no test startup path or autoload.
2. A 30.5 s deterministic no-input headless regression was added and reports one HELD preview, zero non-held drinks, zero merges, zero To-Go deliveries and score 0.
3. The R08 rear formula itself was preserved rather than replaced.
4. A new independent background measurement identifies source y=457 as the candidate visible rear tabletop boundary rather than reusing source y=472 from production geometry.
5. Production `table_top_y` and `rear_table_y` now use the new source y=457 measurement.
6. Existing M01-M07 regressions are reported green by the builder.

## Blocking finding F-R09-STRICT-001 — physical TopRail still uses the old y=472 geometry
The R09 log claims that TopRail, clamp and rear solver all share the new independently measured rear boundary. Current production source contradicts that claim.

`_configure_board_layout()` correctly maps `ACTUAL_REAR_TABLE_SOURCE_Y = 457.0` into `table_top_y` / `rear_table_y`. However `_build_walls()` still constructs `left_points` and `right_points` directly from `TABLE_LEFT_EDGE_SOURCE_POINTS` / `TABLE_RIGHT_EDGE_SOURCE_POINTS`, whose first points remain at source y=472. It then creates `TopRail` from `left_points[0]` to `right_points[0]`.

Therefore:
- clamp/rear solver target the y=457 boundary;
- the actual physical TopRail still has its inward collision face on the old y=472 line;
- a moving RigidBody2D can collide with the old physical wall before reaching the new clamp target.

This directly explains why the owner can still observe a visible rear dead strip even though tangency probes based on the clamp formula pass.

This violates locked criterion 12: **physical TopRail and clamp/rear solver must agree with the same actual visible rear boundary**.

## Blocking finding F-R09-STRICT-002 — desktop/F5 no-input behavior is not closed
The user-reported failure occurs in the actual desktop game. The R09 log reports that an exploratory Windows-display run received input-like events and generated non-held drinks, but that result was excluded from acceptance in favor of a headless display-driver test.

That is material evidence, not noise. Locked criteria require a normal F5/project run to remain idle without player input. A headless process that cannot receive desktop/window input does not prove the desktop runtime is safe from the event sequence that triggered the owner's auto-fire / auto-score symptom.

The current `ShotController` fires after an accepted press/release drag sequence, and R09 did not establish why the Windows-display harness generated gameplay input-like events. The normal desktop input path therefore remains unresolved.

Required closure must reproduce and inspect the real desktop/F5 event stream, then ensure only intentional owner interaction can transition the held preview into a fired non-held drink. Do not remove legitimate stocked To-Go behavior to mask the symptom.

## Classification
- Rear formula: **correct concept, incomplete physical implementation**.
- Candidate rear boundary measurement: **useful / provisionally accepted**.
- Normal headless no-input runtime: **green**.
- Actual desktop/F5 no-input runtime: **not proven safe**.
- Overall R09: **CHANGES_REQUIRED**.

## Required next remediation
1. Make the physical TopRail use the exact same independently measured rear boundary as `rear_table_y` / clamp.
2. Prove collision contact, not only clamped center math, for L01/L06/L12 at the rear edge.
3. Reproduce the desktop/F5 no-input failure path with real Windows-display input logging.
4. Identify which event(s) cause `_begin_drag()` / `_launch()` without intentional player input and fix the input gating at the root cause.
5. Add a desktop/display-backed idle regression or retained event trace proving no held-to-fired transition, no non-held drink, no To-Go delivery and no score increase without intentional input.
6. Preserve legitimate player-fired gameplay and stored To-Go fulfillment.

Until those two blockers are closed, M06/M07 cannot advance.
