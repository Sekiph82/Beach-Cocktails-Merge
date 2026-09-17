# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V03

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01/V02**

Authority: latest owner runtime screenshot and written confirmation dated 2026-09-18 00:57.

## Owner-approved / frozen state
The following are now accepted by the owner and are **not active remediation targets**:

1. Desktop auto-fire / uncommanded drink creation is resolved.
2. BEST SCORE numeric placement is accepted.
3. SCORE numeric placement is accepted.
4. To-Go Orders top placement / rope-to-ceiling result is accepted.
5. Held-drink placement on the gold launch oval is accepted.
6. NEXT and the baked 2x6 progression show no owner-visible regression.

Codex must not redesign, retune or reposition these accepted areas unless a direct compile/runtime dependency makes a minimal change unavoidable. Any such dependency must be documented explicitly.

## Sole active problem — rear tabletop contact
The only remaining owner-visible defect is the contact relationship between moving cocktails and the real rear edge of the tabletop.

The intended model is deliberately simple and applies identically to all cocktail levels L01-L12.

### Mandatory rear-target formula

For every cocktail level:

`rear_target_y = rear_table_y`

Equivalent requirement:

`drink.position.y == rear_table_y`

at the rear stopping/contact target.

No cocktail dimension participates in this Y formula.

### Explicitly forbidden rear-Y adjustments
Do not add any of the following to `rear_table_y`:

- collider radius;
- body half extent;
- sprite height or half-height;
- drink height;
- drink width;
- per-level Y offsets;
- per-level rear target tables;
- safety clearance based on cocktail dimensions.

Forbidden examples:

`rear_target_y = rear_table_y + collider_radius`

`rear_target_y = rear_table_y + body_half_extent_y`

`rear_target_y = rear_table_y + sprite_height / 2`

The accepted contract is exactly:

`rear_target_y = rear_table_y`

## Physical collision requirement
1. The physical rear boundary must not stop a moving RigidBody2D before the owner-defined `rear_table_y` target.
2. The physical TopRail inward collision face, rear clamp/target and the owner-defined rear table boundary must describe one coherent rear contact line.
3. Remove or relocate any stale hidden rear wall that still stops drinks earlier than `rear_table_y`.
4. A real moving cocktail must be able to travel to the intended rear contact region under normal gameplay physics.
5. Do not validate this only by directly spawning a drink at the target coordinate.
6. Validate representative real-motion rear contacts for at least L01, L06 and L12, including rear-center and representative left/right trajectories.
7. The final runtime result must not leave the current obvious unused strip of tabletop between the cocktail stopping positions and the visually intended rear edge.

## Preservation
Preserve exactly unless a genuine technical dependency is documented:

- resolved desktop input/auto-fire behavior;
- To-Go top placement;
- BEST/SCORE numeric centering;
- held drink / gold oval alignment;
- NEXT;
- baked 2x6 progression;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- collision/momentum behavior;
- same-level merge behavior;
- combo/scoring/To-Go economy;
- persistence;
- Game Over/restart;
- rapid launch;
- no guide line.

Canonical PNGs must not be modified.

## Evidence and regression
1. Retain runtime evidence showing actual moving L01/L06/L12 cocktails reaching the rear contact area.
2. Evidence must show the real table artwork and final cocktail positions, not only numerical overlays.
3. Re-run a desktop no-input smoke to confirm the already-fixed auto-fire issue has not regressed.
4. Run the complete active M01-M07 regression suite plus current R09/R10 focused tests.
5. Godot import/startup, parse/check-only and `git diff --check` must pass.
6. Codex must not edit `TASKS.md` or ChatGPT-owned prompt/audit/criteria/policy files.
7. No M08+ feature work begins.

Any visible rear dead strip, stale rear physical blocker, or regression of an owner-approved frozen area blocks AUDITED_PASS.
