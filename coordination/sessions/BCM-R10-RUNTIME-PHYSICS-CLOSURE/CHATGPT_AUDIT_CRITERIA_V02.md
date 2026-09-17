# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V02

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01**

Authority: R09 strict audit, owner-reported desktop runtime failure, and owner clarification that the rear target must use the table rear Y directly rather than cocktail height/radius/half-extent.

## A. Rear physical boundary closure
1. The independently measured rear tabletop boundary remains source y=457 unless new independent visual evidence disproves it.
2. `rear_table_y`, rear target math and the physical `TopRail` inward collision face must all coincide with that same boundary.
3. `TopRail` may not be built from stale y=472 side-polyline endpoints.
4. **Mandatory owner formula for every cocktail level L01-L12:**

   `rear_target_y = rear_table_y`

5. The rear target must NOT add any cocktail-specific Y clearance. The following are explicitly forbidden in the rear-target formula:
   - `+ collider_radius`
   - `+ body_half_extent_y`
   - `+ sprite_height / 2`
   - `+ drink_height / 2`
   - any per-level Y offset or hardcoded per-level rear target.
6. All L01-L12 therefore share the exact same rear target Y. Cocktail width/height/collider radius must not move the rear target forward.
7. The owner-visible acceptance condition is that the cocktail appears to reach/touch the rear table edge according to this direct-Y rule.
8. Validation must include real RigidBody2D travel/contact against the physical rear wall, not only direct spawn/clamp positioning.
9. Retain representative L01/L06/L12 rear-center and rear-corner cases showing moving drinks can reach `rear_table_y` without an artificial dead strip.
10. Side rails/corners must remain coherent with the rear wall and not create snagging, teleport-like correction or a second hidden rear stop.

## B. Desktop/F5 uncommanded-fire closure
11. The actual desktop/Windows-display normal project run must not fire a drink without intentional owner input.
12. Instrument the real input path sufficiently to identify the event sequence that previously produced non-held drinks in a Windows-display run.
13. A normal idle desktop run for at least 30 seconds must retain exactly one HELD preview, zero non-held drinks, zero merges, zero To-Go deliveries and unchanged score.
14. Do not use a headless-only result as sole evidence for criterion 13.
15. Fix the root input-gating cause if synthetic/duplicate/focus/window events can arm and fire a shot. The held-to-fired transition must require a genuine intentional user interaction sequence.
16. Legitimate mouse/touch drag-and-release shooting must continue to work.
17. Rapid-launch behavior must remain intact once intentional shots are fired.
18. Existing stored To-Go auto-fulfillment remains legitimate and must not be removed to mask an accidental-spawn bug.

## C. Preservation
19. Preserve owner-approved held-drink alignment, R08 To-Go placement, BEST/SCORE layout, NEXT and baked 2x6 progression.
20. Preserve launch speed 700 px/s and deceleration 180 px/s².
21. Preserve collision/momentum/merge/combo/scoring/economy/persistence/Game Over/restart.
22. No canonical PNG edits, no guide line, no M08+ feature work.
23. Full active M01-M07 regression plus R09/R10 idle and rear-physics tests must pass.
24. Godot import/startup, parse/check-only and `git diff --check` must pass.
25. Codex must not edit `TASKS.md` or ChatGPT-owned files.

Any desktop auto-fire/auto-score behavior, stale physical rear wall, use of cocktail radius/height/half-extent in the rear target formula, or visible rear dead strip blocks AUDITED_PASS.
