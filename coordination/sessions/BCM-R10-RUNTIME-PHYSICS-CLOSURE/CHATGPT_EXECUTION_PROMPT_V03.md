# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V03

Status: **ISSUED — SUPERSEDES V01/V02**

This is a narrow rear-contact closure. Do not redesign unrelated systems.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V03.md`

Do not edit `TASKS.md`, ChatGPT-owned files, canonical PNGs or historical logs. Do not start M08+.

## Latest owner runtime state
The owner has now visually confirmed these areas are correct and they are frozen:

- auto-fire / uncommanded drink creation is resolved;
- BEST SCORE numeric placement is correct;
- SCORE numeric placement is correct;
- To-Go Orders top placement / rope-to-ceiling result is correct;
- held-drink placement on the gold launch oval is correct;
- NEXT and baked 2x6 progression show no visible regression.

Do not modify these accepted areas unless a direct compile/runtime dependency forces the smallest possible change. If so, document it.

# SOLE ACTIVE PROBLEM — rear tabletop contact

The only remaining owner-visible defect is that cocktails still stop too far from the real rear edge of the tabletop.

## Mandatory owner formula
For every cocktail level L01-L12:

`rear_target_y = rear_table_y`

The rear target Y is exactly the common rear table Y.

Equivalent gameplay target:

`drink.position.y = rear_table_y`

Do not add cocktail dimensions to this Y target.

### Forbidden formulas
Do NOT use:

`rear_target_y = rear_table_y + collider_radius`

`rear_target_y = rear_table_y + body_half_extent_y`

`rear_target_y = rear_table_y + sprite_height / 2`

`rear_target_y = rear_table_y + drink_height / 2`

Also forbidden:
- width-based rear Y adjustments;
- per-level rear Y offsets;
- per-level rear-target tables;
- safety clearance added to rear Y from cocktail dimensions.

The contract is exactly:

`rear_target_y = rear_table_y`

## Physical collision closure
Inspect the current production rear-wall geometry and normal RigidBody2D path.

Required end state:
- a moving drink can physically reach the owner-defined rear target;
- no stale hidden `TopRail` or other physical wall stops it earlier;
- physical rear collision, rear clamp/target and `rear_table_y` are coherent;
- the current visible unused strip of tabletop behind the drinks is removed;
- normal side/corner collision behavior does not regress.

If current `TopRail` geometry still blocks motion earlier than `rear_table_y`, correct that physical boundary.

Do not solve this by teleporting settled drinks directly to the target. Normal fired drinks must be able to reach the intended rear region through normal physics.

## Required runtime proof
Retain production runtime evidence for at least:
- L01 moving to rear-center contact;
- L06 moving to rear-center contact;
- L12 moving to rear-center contact;
- representative rear-left and rear-right approaches.

Evidence must show the actual table artwork and final drink position, not only coordinates or an overlay.

Also re-run a normal desktop/display idle smoke to confirm the already-fixed auto-fire issue remains fixed. This is regression-only, not an active redesign target.

## Preserve
Do not change unless unavoidable:
- resolved auto-fire/input behavior;
- To-Go top placement;
- BEST/SCORE layout and numeric centering;
- held-drink/gold-oval alignment;
- NEXT;
- baked 2x6 progression;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- collisions and momentum transfer;
- same-level merge behavior;
- combo/scoring/To-Go economy;
- persistence;
- Game Over/restart;
- rapid launch;
- no guide line.

## Regression
Run:
- complete active M01-M07 suite;
- current R09/R10 focused runtime tests;
- desktop/display no-input smoke;
- Godot import/startup;
- parse/check-only for touched production scripts;
- `git diff --check`.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V02.md`

Commit and push the implementation, then the immutable log.

Final response must return only:
- R10 log URL
- implementation SHA
- exact final regression result
- `AWAITING_AUDIT`

Then STOP.
