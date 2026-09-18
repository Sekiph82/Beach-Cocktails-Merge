# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V06

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01/V02/V03/V04/V05**

Authority: latest owner GUI runtime evidence dated 2026-09-18 and owner decision to preserve V05 Solution 1 while testing a second 2D edge-contact model.

## Owner runtime conclusions carried forward

The owner has now visually accepted the current three-sided playable envelope itself:
- left playable boundary: accepted;
- right playable boundary: accepted;
- opposite/rear playable boundary: accepted;
- overall trapezoidal/perspective playable area: accepted.

The owner also reports:
- V05 Solution 1 improved gameplay feel/flow and should be preserved;
- the visible cocktail-to-edge gap still remains after merges and during edge accumulation;
- therefore Solution 1 is not sufficient as the visual edge-contact solution.

## Frozen behavior
Do not redesign or regress:
1. three-sided playable envelope geometry;
2. desktop auto-fire fix;
3. BEST SCORE / SCORE number centering;
4. To-Go top placement;
5. held-drink / gold-oval alignment;
6. NEXT content behavior;
7. baked 2x6 progression;
8. V04 HUD column/baseline alignment and enlarged logo;
9. launch speed 700 px/s;
10. deceleration 180 px/s²;
11. merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid-launch behavior;
12. canonical PNGs.

## Active problem — visible cocktail-to-table-edge gap in a 2D game

The game is 2D. Cocktails have screen-space width/height only; there is no 3D depth dimension.

Current production uses one circular collider radius for both:
- drink-to-drink collision/merge physics;
- table-edge center clearance.

That coupling is now the leading hypothesis for the owner-visible gap.

The goal of V06 is to test a 2D-specific model that separates:
- **drink-to-drink collision footprint**;
- **table-edge contact footprint / clearance**.

The existing drink-to-drink collider radii must remain the physics footprint for drink-vs-drink collisions unless a direct compile/runtime dependency requires otherwise.

## Part A — preserve V05 Solution 1

Keep the explicit post-merge X boundary clamp already implemented in `MergeQueue._do_merge()`.

The owner reports it improved gameplay feel.

Do not remove it.

It must continue to:
- clamp only the new merged result;
- occur after final merged collider size is known;
- preserve Y and inherited momentum;
- be a no-op when the result is already valid.

## Part B — test Continuous CD as an auxiliary stabilizer

For moving cocktail RigidBody2D nodes, enable/test Godot 4 2D continuous collision detection using:

`continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE`

or the equivalent Godot 4 property/value for this project version.

Purpose:
- reduce missed/unstable contact during fast movement;
- improve robustness around fast edge and drink collisions.

CCD is **not** by itself accepted as the visual edge-gap solution.

Do not treat a green CCD test as proof that the visual gap is solved.

Do not change to one-frame freeze as part of V06.

## Part C — do NOT implement the incorrect "CollisionShape2D margin = 0.08" recipe

Do not add a fictional/general `CollisionShape2D.margin = 0.08` setting if the active Godot 4 2D API does not support such a property for the current Shape2D type.

Do not silently substitute CharacterBody2D safe-margin behavior.

If there is an actual supported Shape2D/solver-bias setting worth testing, document it separately and do not use it as the primary acceptance mechanism in this V06 pass.

## Part D — introduce a separate table-edge contact footprint

Create an explicit 2D edge-contact concept separate from the drink-vs-drink collider radius.

Recommended production naming may be:
- `edge_contact_radius`,
- `table_edge_clearance`,
- `table_edge_footprint`,
or another equally clear project-consistent name.

The exact name is not important. The separation of responsibilities is mandatory.

### Required behavior

1. Drink-to-drink physics keeps using the existing level collider radius.
2. Left/right table-edge center limits use the new edge-contact footprint instead of automatically using the full drink collider radius.
3. The new footprint must be derived from the visible glass/container body only.
4. Garnish, straw, fruit, flowers, leaves, umbrellas and transparent texture margins must not enlarge the table-edge footprint.
5. The footprint may vary by level if the visible body requires it.
6. Do not invent a 3D depth value. This is a 2D screen-space edge-contact measurement.
7. The accepted opposite/rear rule remains:
   `rear_target_y = rear_table_y`
   with no added collider/height/depth offset.
8. The accepted three-sided playable envelope coordinates must not move in V06.

### Side-bound formula concept

Instead of coupling table clearance directly to the drink-vs-drink collider radius:

`left_center_limit = left_playable_edge + edge_contact_half_width`

`right_center_limit = right_playable_edge - edge_contact_half_width`

The `edge_contact_half_width` must represent the 2D visible glass/container footprint relevant to side contact, not the full garnish silhouette.

Use the same authoritative perspective rail helper and accepted owner envelope.

## Part E — merge correction must use the table-edge footprint

Update the preserved V05 post-merge boundary correction so its table-edge containment uses the new edge-contact footprint, not the full drink-vs-drink radius, while the actual drink collider remains unchanged for drink-to-drink physics.

Conceptually:

`min_x = left_playable_edge + merged_edge_contact_half_width`

`max_x = right_playable_edge - merged_edge_contact_half_width`

`merged_drink.position.x = clamp(merged_drink.position.x, min_x, max_x)`

This is the key V06 experiment.

The resulting larger drink should visually sit substantially closer to the accepted side playable rail without being explosively solver-ejected or visually leaving the valid table area.

## Required evidence

Retain machine-readable and runtime evidence for:

1. all L01-L12:
   - drink collider radius;
   - table-edge contact half-width/clearance;
   - proof they are separately represented;
2. representative L01/L06/L12 side contact on both left and right;
3. at least one merge near left wall and one merge near right wall;
4. before-merge input position, raw merge position, edge-contact valid range, corrected result X;
5. an already-valid center merge proving the clamp is a no-op when not needed;
6. CCD mode/state on representative drinks;
7. accepted rear target remains exactly `rear_table_y`;
8. three-sided envelope coordinates unchanged from V05;
9. owner-approved HUD/input/To-Go/held behavior unchanged.

Most importantly, provide normal GUI/F5 owner-verifiable runtime evidence. Headless coordinate PASS is not sufficient for visual closure.

## Regression

Run:
- full active M01-M07 regression;
- R09/R10 focused tests;
- V05 three-sided envelope regression unchanged;
- new V06 edge-footprint regression;
- left/right wall-merge regression;
- center no-op merge control;
- desktop no-input smoke;
- Godot import/startup;
- parse/check-only;
- `git diff --check`.

Codex must not edit `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files, historical logs, canonical PNGs or M08+ work.

Any movement of the owner-approved playable envelope, regression of V05 Solution 1, use of a fake unsupported collision margin API, loss of drink-to-drink collision behavior, or continued owner-visible edge gap blocks AUDITED_PASS.
