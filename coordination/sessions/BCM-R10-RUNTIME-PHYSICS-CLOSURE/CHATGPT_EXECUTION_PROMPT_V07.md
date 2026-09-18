# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V07

Status: **ISSUED — SUPERSEDES V01/V02/V03/V04/V05/V06**

This is a focused correction to the failed V06 edge-footprint model.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V04.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V07.md`

Do not edit `TASKS.md`, ChatGPT-owned files, historical logs, canonical PNGs or M08+ work.

## Frozen owner-approved state

Do not move:
- left playable rail;
- right playable rail;
- rear/opposite playable boundary.

Do not remove:
- V05 Solution 1 post-merge X clamp.

Preserve:
- current HUD;
- To-Go;
- held drink;
- NEXT;
- progression;
- auto-fire fix;
- launch 700 px/s;
- deceleration 180 px/s²;
- existing drink-to-drink collider radii;
- economy/persistence/Game Over/restart/rapid-launch.

## Problem

V06 did not materially solve the edge gap.

Its footprint formula reduced to approximately:

`collider_radius * 0.96..1.0`

which only changed clearance by a few pixels.

Do not reuse that model.

## Mandatory V07 implementation

Create an explicit independent 12-value per-level dataset:

`TABLE_EDGE_CONTACT_HALF_WIDTHS`

or an equally clear name.

It must contain one value for each L01-L12.

These values must be measured from the visible glass/container contact geometry in the actual cocktail PNGs.

They must NOT be derived from:
- `COLLIDER_RADII`;
- `visual_scale_for_level()`;
- any formula that algebraically reduces to collider radius.

Exclude garnish, straw, fruit, flowers, leaves, umbrellas and transparent margins.

Retain immutable measurement evidence showing how each L01-L12 value was obtained.

## Runtime use

Drink-to-drink collisions keep the existing collider radius.

Side table contact uses the new independent edge half-width:

`left_limit = left_rail + edge_contact_half_width`

`right_limit = right_rail - edge_contact_half_width`

Do not move the rails.

Rear stays:

`rear_target_y = rear_table_y`

No radius/width/height/depth addition to rear Y.

## Merge

Keep V05 Solution 1.

Use the NEW independent merged-level edge footprint for the merge result X clamp.

Preserve merge Y and inherited momentum.

If already valid, clamp is a no-op.

## Physical wall compatibility

Ensure the full RigidBody2D circle does not solver-eject a drink that is logically valid under the independent edge footprint.

You may choose the technical mechanism, but:
- logical V05 rail coordinates remain frozen;
- collider radii remain unchanged;
- drink-to-drink physics remains intact.

## CCD

CAST_SHAPE CCD is already active.

Preserve it.

Do not present it as a new fix.

Do not add fake CollisionShape2D margin, CharacterBody2D safe_margin or one-frame freeze.

## Required proof

Retain evidence for:
- all 12 independent edge-contact values;
- all 12 unchanged collider radii;
- measurement provenance independent from collider radius;
- L01/L06/L12 left/right contact;
- left-wall merge;
- right-wall merge;
- center merge no-op;
- exact rear target;
- unchanged V05 rail coordinates;
- normal GUI/F5 owner-verifiable result.

## Regression

Run:
- full active M01-M07;
- R09/R10 focused suite;
- V05 envelope regression;
- new V07 independent-edge probe;
- left/right wall merge;
- center no-op merge;
- desktop idle/no-input;
- Godot startup/import;
- parse/check-only;
- `git diff --check`.

Write:

`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V05.md`

Commit/push implementation and immutable log.

Return:
- log URL;
- implementation SHA;
- exact regression result;
- `AWAITING_AUDIT`.

Then STOP.
