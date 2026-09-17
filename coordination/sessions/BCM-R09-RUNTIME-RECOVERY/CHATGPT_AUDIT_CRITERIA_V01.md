# BCM-R09-RUNTIME-RECOVERY — ChatGPT Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

Authority: owner runtime report after BCM-M06-R08/M07-R08: (1) the running game continuously creates cocktails, sends them to To-Go Orders and increases score without owner input; (2) cocktails still stop materially too far from the visible rear tabletop edge.

## A. Uncommanded cocktail / score regression
1. A normal F5/project run must execute only the actual game scene and must not execute any test/probe/evidence script.
2. With no player input for at least 30 seconds, the game must not fire, settle, merge, create gameplay cocktails beyond the single intended HELD preview, complete To-Go orders, or increase score.
3. Initial state must be exactly one collision-free HELD preview plus NEXT UI; no settled/physics cocktail may appear until the player fires.
4. Inspect the LOCAL dirty `project.godot` and all local run/autoload configuration before editing. Compare it with `origin/main:project.godot`. Determine exactly why it is modified. Do not blindly preserve it merely because a prior log called it owner-created.
5. `run/main_scene` for normal gameplay must resolve to `res://scenes/main.tscn`. No test/probe script may be configured as a normal project startup/autoload path.
6. Test/probe scripts may spawn synthetic drinks only inside their isolated test process and must terminate cleanly. They must never alter normal-game startup/runtime behavior.
7. Existing intended To-Go inventory behavior may remain: when a legitimate player-created stored matching cocktail already exists on the table and a future order requests it, one such cocktail may auto-deliver. This must not manufacture new cocktails and must not create an endless reward loop.
8. Add a no-input runtime regression that proves score remains 0, To-Go completion count remains 0, and gameplay world contains no non-held Drink after the observation interval.

## B. Rear tabletop contact
9. The current mathematical invariant remains mandatory for all L01-L12:
   `rear_target_center_y = actual_visible_rear_table_y + body_half_extent_y`
   and therefore
   `visible_glass_body_top_y = actual_visible_rear_table_y`.
10. The problem in R08 is not the formula. The audit must independently establish the correct **actual visible rear tabletop Y** from the active owner-approved background/runtime render.
11. Production must not assume `TABLE_LEFT_EDGE_SOURCE_POINTS[0].y == actual rear edge` unless independent visual measurement proves it.
12. The physical TopRail and any clamp/rear solver must agree with the same actual visible rear boundary.
13. Expected rear-edge evidence must not be derived from production `rear_table_y`, production table constants, or production helper output. Avoid circular validation.
14. Evidence must visibly show representative L01/L06/L12 body top edges touching the actual rear wood boundary with no artificial dead strip and no body overflow.
15. All L01-L12 use one common rear table boundary; only center Y differs according to body half-extent.

## C. Preservation
16. Preserve the owner-approved held-drink launch alignment exactly.
17. Preserve R08 To-Go asset placement and current score/best HUD work unless a genuine regression is discovered.
18. Preserve launch speed 700 px/s, deceleration 180 px/s², collision/momentum/merge, economy, persistence, Game Over/restart, NEXT and baked 2x6 progression.
19. No canonical PNG changes, no guide line, no M08+ feature work.
20. Run full active M01-M07 regression plus the new no-input runtime regression, Godot import/startup and `git diff --check`.
21. Codex must not edit TASKS.md or ChatGPT-owned audit/prompt/criteria/policy files.

Any uncommanded cocktail generation, uncommanded score increase, test code leaking into normal gameplay, or visible rear dead strip blocks AUDITED_PASS.
