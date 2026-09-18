# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V05

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01/V02/V03/V04**

Authority: latest owner runtime screenshots and written requirements dated 2026-09-18 07:47.

## Owner-approved / frozen behavior
The following remain accepted and must not regress:
1. Desktop auto-fire / uncommanded drink creation is resolved.
2. BEST SCORE and SCORE numeric centering inside their own value recesses is correct.
3. To-Go Orders top placement / rope-to-ceiling result is correct.
4. Held-drink placement on the gold launch oval is correct.
5. NEXT content behavior is correct.
6. Baked 2x6 progression is correct.
7. Launch speed remains 700 px/s.
8. Deceleration remains 180 px/s².
9. Collision/momentum/merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid-launch behavior remains intact.
10. Canonical PNGs are not modified.

## Active problem A — rear tabletop contact
The owner rear-target rule remains:

`rear_target_y = rear_table_y`

Equivalent:

`drink.position.y == rear_table_y`

for the rear target.

Do not add collider radius, body half extent, sprite size, drink size, width/height-based clearance, per-level Y offsets or per-level rear targets.

The physical rear collision must not stop the moving RigidBody2D before this target.

## Active problem B — side playable rails should be slightly more inward
The latest owner screenshot shows that the side playable boundary should sit slightly farther inside the visible tabletop than the current side collision path.

Requirements:
1. Move the effective left/right playable side rails inward by a small, visually conservative amount.
2. The final side boundary should follow the owner's annotated white-line intent: remain on visible tabletop wood and not ride directly on the extreme decorative/frame edge.
3. The inset must be modest. Do not materially shrink the playable table.
4. Preserve the current perspective shape and rear geometry. Do not turn the table into a rectangle.
5. Left/right playable limits must remain symmetric in intent and responsive across supported portrait layouts.
6. The HUD must not define or influence these side physics bounds.
7. Validate with moving drinks at left and right sides, not only coordinate math.

## Active problem C — merge-created larger drink must be boundary-corrected immediately
The owner observed a repeatable physics defect:
- a lower-level drink can be resting against/near a table wall;
- a merge replaces it with a larger next-level drink at the same or nearby world position;
- the larger collider can initially overlap/interpenetrate the table wall;
- Godot's physics solver then pushes the new larger drink away from the wall, creating an obvious temporary gap;
- after later motion/jitter, the drink can drift back toward the wall.

For R10 V05, test and implement **Solution 1 only: explicit boundary clamp immediately after merge creation/resize**.

Required contract:
1. Immediately after the new merged drink exists and its final level/collider size is known, but before normal physics is allowed to resolve a wall overlap, correct its position against the current authoritative board bounds.
2. The correction must use the new merged drink's current collision/body size for X-side containment.
3. Conceptual side rule:
   - `min_x = current_left_playable_edge + new_drink_half_width`
   - `max_x = current_right_playable_edge - new_drink_half_width`
   - `new_drink.position.x = clamp(new_drink.position.x, min_x, max_x)`
4. Use the project's actual authoritative boundary helpers/geometry rather than inventing disconnected constants.
5. If the merged drink is already valid, do not move it unnecessarily.
6. The correction must preserve physically meaningful forward/lateral momentum as much as possible. Do not zero velocity merely to hide the problem.
7. A merge next to the left or right wall must produce the larger drink tangent/contained at the valid side boundary instead of being explosively pushed inward by overlap resolution.
8. This boundary correction applies to the newly created merged result, not to unrelated settled drinks.

### Explicitly NOT requested in V05
Do not use the alternative remedies yet unless required only for a compile/runtime dependency:
- do not change Continuous CD as the primary solution;
- do not tune collision margins as the primary solution;
- do not freeze the merged drink for one physics frame as the primary solution.

The owner explicitly wants Solution 1 tested first.

## Active problem D — HUD layout refinements from V04
Preserve and implement the V04 layout requirements:

Alignment definitions:
- vertical alignment = equal visible-artwork center X;
- horizontal alignment = equal visible-artwork bottom Y.

1. SCORE stays at its current accepted position.
2. BEST SCORE moves so `best_score_visual_bottom_y == score_visual_bottom_y`.
3. NEXT moves so `next_visual_center_x == score_visual_center_x`.
4. Beach Cocktails Merge logo is modestly enlarged with preserved aspect ratio, no crop/stretch, no PNG edit.
5. Logo moves so `logo_visual_center_x == best_score_visual_center_x`.
6. BEST/SCORE number centering inside their recesses remains correct.
7. To-Go top placement and held-drink/gold-oval alignment remain unchanged.

## Required evidence
Retain runtime evidence showing:
1. moving L01/L06/L12 rear contact behavior;
2. representative moving drinks against both new side playable rails;
3. at least one left-wall merge where a smaller drink becomes a larger drink and the result remains correctly boundary-contained without a solver-created visible gap;
4. at least one right-wall merge with the same proof;
5. before/after positional values for the merge correction sufficient to prove clamp happened only when needed;
6. the four V04 HUD alignment requirements;
7. no regression of auto-fire fix, To-Go top placement, score centering, held drink alignment, NEXT content or progression.

## Regression
- full active M01-M07 regression;
- current R09/R10 focused tests;
- focused wall-merge regression for both left and right boundaries;
- desktop no-input smoke;
- Godot import/startup;
- parse/check-only;
- `git diff --check`.

Codex must not edit `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files, historical logs, canonical PNGs or M08+ work.

Any visible rear dead strip, side boundary outside the intended inset, merge-result wall ejection/gap, or regression of owner-approved behavior blocks AUDITED_PASS.
