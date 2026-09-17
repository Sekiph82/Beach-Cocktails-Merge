# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V04

Status: **ISSUED — SUPERSEDES V01/V02/V03**

This task contains one remaining gameplay-physics correction plus four owner-requested HUD placement refinements. Do not redesign unrelated systems.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V04.md`

Do not edit `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy files, canonical PNGs or historical logs. Do not start M08+.

## Owner-approved / frozen behavior
The following are currently correct and must remain functionally unchanged:

- desktop auto-fire / uncommanded drink creation is fixed;
- BEST SCORE and SCORE number centering inside their own value recesses is correct;
- To-Go Orders top placement / rope-to-ceiling result is correct;
- held drink placement on the gold launch oval is correct;
- NEXT content behavior is correct;
- baked 2x6 progression is correct;
- launch speed is 700 px/s;
- deceleration is 180 px/s²;
- merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid-launch behavior is correct.

Do not use this task as an excuse to redesign those systems.

# Part A — Remaining rear tabletop contact problem

The cocktail rear target Y is defined by the owner with one exact formula for every L01-L12:

`rear_target_y = rear_table_y`

Equivalent:

`drink.position.y = rear_table_y`

No cocktail size/dimension may be added to this Y target.

Forbidden:

`rear_target_y = rear_table_y + collider_radius`

`rear_target_y = rear_table_y + body_half_extent_y`

`rear_target_y = rear_table_y + sprite_height / 2`

Also forbidden:
- width-based adjustment;
- height-based adjustment;
- collider-size clearance;
- per-level rear offsets;
- per-level rear target tables.

The moving RigidBody2D must be able to reach the intended rear target under normal gameplay physics. A stale physical TopRail/hidden wall must not stop it earlier.

Physical TopRail inward face, rear clamp/target and `rear_table_y` must be coherent with the same rear contact line.

Do not prove this only by directly spawning drinks at coordinates. Retain normal-motion validation for at least:
- L01 rear-center;
- L06 rear-center;
- L12 rear-center;
- representative rear-left;
- representative rear-right.

The final running game must not leave the current obvious unused strip of wood behind cocktails that have reached the rear stopping area.

# Part B — Four owner HUD layout changes

These are visual placement changes only. They must not influence game/table physics bounds.

## Alignment definitions

Use the displayed artwork/visible image bounds, not label bounds and not arbitrary node origins.

**Vertical alignment** means:

`visual_center_x(A) == visual_center_x(B)`

**Horizontal alignment** means:

`visual_bottom_y(A) == visual_bottom_y(B)`

## 1. BEST SCORE and SCORE horizontal alignment

SCORE is the anchor and must stay at its current accepted position.

Move BEST SCORE as required so:

`best_score_visual_bottom_y == score_visual_bottom_y`

Their lowest visible artwork pixels must lie on the same horizontal axis.

Do not move SCORE to achieve this.

## 2. SCORE and NEXT vertical alignment

SCORE remains at its current accepted position.

Move NEXT horizontally as required so:

`next_visual_center_x == score_visual_center_x`

SCORE and NEXT must form one right-side vertical column based on their visual centers.

Do not move SCORE to achieve this.

## 3. Beach Cocktails Merge logo slightly larger

Increase the displayed Beach Cocktails Merge logo modestly compared with the current accepted runtime size.

Requirements:
- preserve aspect ratio;
- no stretch/distortion;
- no crop;
- do not edit the canonical PNG;
- keep it fully on-screen;
- do not overlap To-Go Orders;
- do not affect gameplay bounds.

Do not make it dramatically larger. The owner asks for a modest size increase.

## 4. Logo and BEST SCORE vertical alignment

Align their visual center X coordinates:

`logo_visual_center_x == best_score_visual_center_x`

This forms one left-side vertical column.

BEST SCORE may move vertically to satisfy requirement 1. Logo may resize/reposition to satisfy requirements 3 and 4.

## HUD preservation rules

- SCORE stays where it is.
- BEST SCORE number remains centered inside its value recess after the panel moves.
- SCORE number remains centered inside its value recess.
- To-Go panel must not move from the currently approved top position.
- Held drink / gold oval alignment must not change.
- NEXT may move only as required for alignment with SCORE; preserve its existing cocktail containment/fit.
- Progression strip must not move or be redesigned unless a direct collision with the required HUD layout makes a minimal adjustment unavoidable; document any such dependency.

# Required evidence

Retain clean runtime screenshots/evidence showing:

1. Rear normal-physics contact for representative levels/trajectories.
2. BEST SCORE and SCORE bottom edges on the same Y.
3. SCORE and NEXT visual centers on the same X.
4. Logo and BEST SCORE visual centers on the same X.
5. Logo visibly modestly larger than before.
6. BEST/SCORE numeric centering preserved.
7. To-Go top placement unchanged.
8. Held drink launch placement unchanged.

At minimum, retain the canonical 720x1280 runtime layout plus responsive evidence where existing R10/R09 tests expect it.

# Regression

Run:
- full active M01-M07 regression;
- current R09/R10 focused tests;
- desktop no-input smoke confirming auto-fire remains fixed;
- Godot import/startup;
- parse/check-only;
- `git diff --check`.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V02.md`

Commit and push the implementation, then the immutable log.

Final response must return only:
- R10 log URL;
- implementation SHA;
- exact final regression result;
- `AWAITING_AUDIT`.

Then STOP.
