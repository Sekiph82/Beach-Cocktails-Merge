# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V06

Status: **ISSUED — SUPERSEDES V01/V02/V03/V04/V05**

This is a focused 2D edge-contact experiment.

The owner has visually accepted the V05 three-sided playable envelope. Do NOT move it again.

The owner also wants V05 Solution 1 preserved because gameplay/flow improved, but the cocktail-to-edge visible gap still remains.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V03.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V06.md`

Do not edit `TASKS.md`, ChatGPT-owned files, canonical PNGs, historical logs or M08+ work.

## Frozen owner-approved state

Do not move or redesign:
- V05 three-sided playable envelope;
- rear/opposite playable boundary;
- left/right playable rail geometry;
- auto-fire fix;
- BEST/SCORE numeric centering;
- To-Go top placement;
- held drink / gold oval;
- NEXT content;
- 2x6 progression;
- V04 HUD alignment and logo size/layout;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- economy/persistence/Game Over/restart/rapid-launch.

## Problem

The game is 2D.

There is no cocktail "depth" axis.

The current visible gap appears to come from using the same circular collider radius for two different jobs:

1. drink-to-drink collision/merge physics;
2. table-edge clearance.

Do not solve this by inventing 3D depth.

## Part 1 — preserve V05 Solution 1

Keep the current explicit post-merge boundary correction in `MergeQueue._do_merge()`.

The owner says it improved gameplay feel.

Do not remove it.

## Part 2 — test Solution 2 CCD, but only the valid Godot 4 part

For moving cocktail `RigidBody2D` instances, enable/test shape-based continuous collision detection:

`continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE`

or the exact Godot 4.7 equivalent.

Do not assume CCD alone solves the visual gap.

Do NOT implement a fake/general `CollisionShape2D.margin = 0.08` if that property is not supported by the active Godot 4 Shape2D API.

Do not convert the drinks to CharacterBody2D.

Do not add a one-physics-frame freeze in this V06 pass.

## Part 3 — separate table-edge footprint from drink collider radius

This is the main V06 experiment.

Keep the existing circular collider radii for drink-vs-drink physics.

Add a separate 2D value for table-edge contact, for example:

`edge_contact_half_width`

or:

`table_edge_clearance`

The exact name is your choice.

It must represent the visible glass/container body footprint relevant to table-edge contact.

Exclude:
- garnish;
- straw;
- fruit;
- flowers;
- leaves;
- umbrellas;
- transparent sprite margins.

Do not use a 3D depth concept.

### Required side-limit model

Current conceptual coupling:

`left_limit = left_rail + collider_radius`

`right_limit = right_rail - collider_radius`

V06 target concept:

`left_limit = left_rail + edge_contact_half_width`

`right_limit = right_rail - edge_contact_half_width`

The physical drink collider itself remains unchanged for drink-vs-drink collisions.

Use the existing accepted perspective rail helper.

Do not move the rails.

## Part 4 — rear rule remains unchanged

For all L01-L12:

`rear_target_y = rear_table_y`

No radius, height, width, sprite extent or invented depth may be added to rear Y.

Do not move `rear_table_y`.

## Part 5 — use the new edge footprint in the preserved merge clamp

Update the V05 Solution 1 merge correction so the new merged result's valid X range is calculated using the NEW table-edge footprint, not the full drink collider radius.

Conceptually:

`min_x = left_playable_edge + merged_edge_contact_half_width`

`max_x = right_playable_edge - merged_edge_contact_half_width`

`new_drink.position.x = clamp(new_drink.position.x, min_x, max_x)`

Do not zero inherited velocity.

Do not change merge Y.

If the raw merge position is already valid, the correction must be a no-op.

## Required focused tests

Create/extend focused tests that prove:

1. L01-L12 each expose both:
   - drink collision radius;
   - table-edge contact footprint.

2. Drink-to-drink collision radius remains unchanged from the current accepted values.

3. Side contact uses edge-contact footprint rather than full collider radius.

4. Left-wall merge:
   - raw merge X;
   - final edge footprint;
   - valid X range;
   - corrected X;
   - no solver-created artificial gap.

5. Right-wall merge with the same evidence.

6. Center merge control:
   - raw X already valid;
   - corrected X == raw X.

7. Representative drinks use CAST_SHAPE CCD.

8. Rear target remains exactly `rear_table_y`.

9. V05 three-sided envelope coordinates remain byte-for-byte/numerically unchanged.

## Owner-visible goal

In normal Godot GUI/F5 gameplay:
- cocktails should visually sit closer to the accepted table side boundaries;
- after a side merge, the larger result should remain close to the edge instead of being pushed noticeably inward;
- the accepted playable envelope itself must not move;
- drink-to-drink collision/merge feel must remain intact.

## Regression

Run:
- full active M01-M07 regression;
- R09/R10 focused tests;
- V05 envelope regression;
- new V06 edge-footprint regression;
- left/right merge-wall regression;
- center no-op merge control;
- desktop no-input smoke;
- Godot startup/import;
- parse/check-only;
- `git diff --check`.

Write:

`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V04.md`

Commit and push implementation, then immutable log.

Return only:
- R10 log URL;
- implementation SHA;
- exact final regression result;
- `AWAITING_AUDIT`.

Then STOP.
