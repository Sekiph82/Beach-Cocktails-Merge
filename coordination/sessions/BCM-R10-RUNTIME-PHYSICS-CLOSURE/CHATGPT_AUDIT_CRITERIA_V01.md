# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: R09 strict audit plus owner-reported desktop runtime failure.

## A. Rear physical boundary closure
1. The independently measured rear tabletop boundary remains source y=457 unless new independent visual evidence disproves it.
2. `rear_table_y`, clamp/rear target math and the physical `TopRail` inward collision face must all coincide with that same boundary.
3. `TopRail` may not be built from stale y=472 side-polyline endpoints.
4. Mandatory contact invariant for all L01-L12 remains:
   `rear_target_center_y = actual_visible_rear_table_y + body_half_extent_y`
   and
   `visible_glass_body_top_y = actual_visible_rear_table_y`.
5. Validation must include real physics collision travel/contact, not only direct spawn/clamp positioning.
6. Retain representative L01/L06/L12 rear-center and rear-corner cases showing the moving RigidBody2D reaches the physical wall with no artificial gap and no body overflow.
7. Side rails/corners must remain coherent with the rear wall and not create snagging or teleport-like correction.

## B. Desktop/F5 uncommanded-fire closure
8. The actual desktop/Windows-display normal project run must not fire a drink without intentional owner input.
9. Instrument the real input path sufficiently to identify the event sequence that previously produced non-held drinks in a Windows-display run.
10. A normal idle desktop run for at least 30 seconds must retain exactly one HELD preview, zero non-held drinks, zero merges, zero To-Go deliveries and unchanged score.
11. Do not use a headless-only result as sole evidence for criterion 10.
12. Fix the root input-gating cause if synthetic/duplicate/focus/window events can arm and fire a shot. The held-to-fired transition must require a genuine intentional user interaction sequence.
13. Legitimate mouse/touch drag-and-release shooting must continue to work.
14. Rapid-launch behavior must remain intact once intentional shots are fired.
15. Existing stored To-Go auto-fulfillment remains legitimate and must not be removed to mask an accidental-spawn bug.

## C. Preservation
16. Preserve owner-approved held-drink alignment, R08 To-Go placement, BEST/SCORE layout, NEXT and baked 2x6 progression.
17. Preserve launch speed 700 px/s and deceleration 180 px/s².
18. Preserve collision/momentum/merge/combo/scoring/economy/persistence/Game Over/restart.
19. No canonical PNG edits, no guide line, no M08+ feature work.
20. Full active M01-M07 regression plus R09/R10 idle and rear-physics tests must pass.
21. Godot import/startup, parse/check-only and `git diff --check` must pass.
22. Codex must not edit `TASKS.md` or ChatGPT-owned files.

Any desktop auto-fire/auto-score behavior, stale physical rear wall, or visible rear dead strip blocks AUDITED_PASS.
