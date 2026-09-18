# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V05

Status: **ISSUED — SUPERSEDES V01/V02/V03/V04**

This task contains the remaining rear/side tabletop physics work, one specific merge-wall correction, and the already-requested HUD refinements. Do not redesign unrelated systems.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V05.md`

Do not edit `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files, canonical PNGs or historical logs. Do not start M08+.

## Owner-approved / frozen behavior
Preserve:
- resolved desktop auto-fire behavior;
- BEST SCORE / SCORE number centering;
- To-Go Orders top placement;
- held-drink / gold-oval alignment;
- NEXT content behavior;
- baked 2x6 progression;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- collision/momentum/merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid launch.

## Part A — rear target
For every cocktail level L01-L12:

`rear_target_y = rear_table_y`

Do not add collider radius, body extent, sprite size, width, height or per-level Y offsets to this rear target.

The moving RigidBody2D must be able to reach the intended rear target without a stale hidden TopRail stopping it earlier.

## Part B — move side playable rails slightly inward
The latest owner screenshot shows the side playable boundary should sit slightly inside the current extreme edge.

Implement a **modest inward inset** for the left and right playable rails while preserving the current perspective shape.

Owner intent:
- the usable boundary should visually follow the white annotated side lines;
- the playable edge stays on visible tabletop wood;
- it should not ride directly on the extreme decorative/frame edge;
- do not materially shrink the table.

Do not use HUD geometry to define this.

Retain moving-body evidence at both left and right boundaries.

## Part C — merge-at-wall correction: use Solution 1 only
The owner wants to test the explicit post-merge boundary correction first.

Observed failure:
- a drink near a wall merges;
- the new higher-level drink is larger;
- it appears at the old merge position;
- its larger collider overlaps the wall;
- the physics solver pushes it inward and creates a visible gap.

Implement this correction directly in the merge-result path.

Immediately after the new merged drink is created/resized and its final collider/body size is known, but before normal physics overlap resolution can throw it away from the wall:

1. Obtain the authoritative current left/right playable bounds at the merged drink's Y.
2. Obtain the new merged drink's current horizontal body/collider half-width.
3. Compute the valid center range conceptually as:

`min_x = left_playable_edge + new_drink_half_width`

`max_x = right_playable_edge - new_drink_half_width`

4. Clamp the merged result:

`new_drink.position.x = clamp(new_drink.position.x, min_x, max_x)`

Use the project's actual boundary helper(s) where available so this is integrated with the real perspective table geometry rather than duplicated constants.

If the merged result is already valid, do not move it.

Preserve meaningful inherited forward/lateral momentum. Do not zero velocity simply to suppress the symptom.

### Important
For this V05 attempt, do **not** use these as the primary solution:
- Continuous CD changes;
- collision-margin tuning;
- freezing the merged drink for one physics frame.

We are testing Solution 1 first.

Required focused proof:
- merge near left wall from a smaller level to a larger level;
- merge near right wall from a smaller level to a larger level;
- in both cases the new larger drink is immediately valid/tangent/contained and does not get solver-ejected inward leaving an artificial gap.

## Part D — HUD refinements from V04
Keep SCORE at its current accepted position.

Implement:
1. BEST SCORE bottom visible Y == SCORE bottom visible Y.
2. NEXT visual center X == SCORE visual center X. Move NEXT, not SCORE.
3. Enlarge Beach Cocktails Merge logo modestly, preserving aspect ratio and keeping it on-screen.
4. Logo visual center X == BEST SCORE visual center X.
5. BEST/SCORE internal number centering remains correct.
6. To-Go top placement remains unchanged.
7. Held-drink alignment remains unchanged.

Definitions:
- vertical alignment = equal visible-artwork center X;
- horizontal alignment = equal visible-artwork bottom Y.

Use actual displayed artwork bounds, not arbitrary node origins.

## Evidence
Retain clean runtime evidence showing:
- rear contact;
- left/right side playable boundary after the modest inset;
- left-wall merge before/after result;
- right-wall merge before/after result;
- no solver-created artificial gap after merge;
- final HUD alignments and logo size;
- preserved To-Go, score centering and held drink.

## Regression
Run:
- full active M01-M07 regression;
- current R09/R10 focused tests;
- new left/right merge-wall regression;
- desktop no-input smoke;
- Godot import/startup;
- parse/check-only;
- `git diff --check`.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V03.md`

Commit and push implementation, then immutable log.

Return only:
- R10 log URL;
- implementation SHA;
- exact final regression result;
- `AWAITING_AUDIT`.

Then STOP.
