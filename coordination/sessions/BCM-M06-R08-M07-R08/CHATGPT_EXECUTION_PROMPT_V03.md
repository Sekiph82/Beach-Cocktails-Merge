# BCM-M06-R08 + BCM-M07-R08 — Owner Runtime Refinement Master Prompt V03

Status: **ISSUED — SUPERSEDES V02**

V03 keeps the accepted R08 scope but makes the rear-stop mathematics explicit and mandatory.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V03.md`
- `coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

Do not edit `TASKS.md`, ChatGPT-owned files, canonical PNGs, historical logs or M08+ work.

---

# PHASE 1 — BCM-M06-R08 — Common rear-edge contact with mandatory formula

## Owner requirement
Every cocktail L01-L12 must reach the SAME visible rear tabletop boundary with the rear-most edge of its visible glass/container body touching that boundary.

There is one common rear table line. Do not create different rear table limits for different levels.

## Mandatory mathematics
Godot screen-space Y increases downward.

Let:

```text
rear_table_y = Y coordinate of the common visible rear tabletop boundary
body_half_extent_y = current cocktail glass/container body height / 2
```

Then the cocktail center target is:

```text
rear_target_center_y = rear_table_y + body_half_extent_y
```

The invariant that MUST hold is:

```text
visible_body_top_y = rear_target_center_y - body_half_extent_y
visible_body_top_y == rear_table_y
```

If the current circular CollisionShape2D radius accurately represents the glass/container vertical half-extent, use:

```text
body_half_extent_y = collider_radius
rear_target_center_y = rear_table_y + collider_radius
```

If collider radius does not accurately match the visible glass/container body, derive/use an evidence-backed `body_half_extent_y` from the actual body. Do not include garnish, straw, fruit, flowers or leaves in this extent.

## Important implementation rule
Do NOT create hardcoded per-level rear Y target positions.

The per-level difference must emerge automatically from the formula because each level has a different body size.

Example:

```text
rear_table_y = 300

L01 body_half_extent_y = 18
L01 center target = 300 + 18 = 318
L01 body top = 318 - 18 = 300

L06 body_half_extent_y = 34
L06 center target = 300 + 34 = 334
L06 body top = 334 - 34 = 300

L12 body_half_extent_y = 55
L12 center target = 300 + 55 = 355
L12 body top = 355 - 55 = 300
```

All three bodies touch the SAME rear edge. Only their center positions differ.

## Rear corners
The owner still wants the extreme rear-left/rear-right corners to feel softly rounded rather than like abrupt square invisible walls.

You may choose the safest architecture-compatible method for that corner behavior. A weak smooth center-seeking influence is acceptable if useful, but it must be local, subtle and must NOT change the common rear-edge formula above.

## Preserve
- owner-approved held-drink launch alignment;
- 700 px/s launch;
- 180 px/s² deceleration;
- collision and momentum behavior;
- same-level merge behavior;
- combo/scoring/To-Go economy;
- persistence/Game Over/restart;
- current danger and launch positions unless a genuine dependency is proven;
- no guide line.

## Required validation/evidence
For L01-L12, log at minimum:

```text
level
rear_table_y
body_half_extent_y
computed rear_target_center_y
resulting visible_body_top_y
tangency_error = abs(visible_body_top_y - rear_table_y)
```

The test must prove the equation, not compare one production constant table with another copied table.

Retain runtime evidence for 720x1280, 720x1440 and 800x1280 showing representative small/mid/large rear-center contacts plus rear-left/rear-right behavior.

Write:
`coordination/sessions/BCM-M06-R08/CODEX_LOG_V01.md`

Commit and push Phase 1 before Phase 2.

---

# PHASE 2 — BCM-M07-R08 — To-Go placement and score vertical centering

## To-Go
Do NOT extend, redraw, fake or modify the To-Go ropes.
Do NOT modify the canonical To-Go PNG.

Move the complete existing To-Go asset/panel upward until the asset's own topmost visible artwork touches the top edge of the gameplay viewport.

The asset itself reaches the ceiling. Its supplied rope/artwork remains untouched.

Remove/disable runtime-only rope extensions introduced solely to bridge the previous gap.

Preserve To-Go content:
- target cocktail + reward digits only;
- no Lx/name;
- no leading plus;
- reward remains inside cream board.

## BEST SCORE and SCORE
Horizontal centering is accepted.
Vertical centering is not.

Both numeric values must be visually centered vertically as well as horizontally inside the actual dark/gold-framed value recesses.

Keep:
- fixed font size;
- seven-digit maximum through `9999999`;
- BEST left under logo;
- SCORE right under/near NEXT.

Do not move the expected test box together with the production value. Validate against the actual baked recess and rendered glyph bounds.

## Held drink
The current held-drink placement on the gold oval is OWNER-APPROVED.

Do not modify:
- held baseline;
- X alignment;
- body-foot anchor;
- halo alignment.

## Preserve
- NEXT L01-L12 containment;
- baked 2x6 progression, top L07-L12 / bottom L01-L06;
- canonical PNGs;
- corrected M06-R08 geometry;
- no guide line.

## Evidence
Retain 720x1280, 720x1440 and 800x1280 screenshots/close-ups proving:
- To-Go asset topmost visible artwork touches viewport top with no runtime rope extension;
- To-Go content remains visible;
- BEST/SCORE are horizontally and vertically centered for representative short/medium/7-digit values;
- held drink remains unchanged from the owner-approved state.

Write:
`coordination/sessions/BCM-M07-R08/CODEX_LOG_V01.md`

Commit and push Phase 2 separately.

---

# FINAL REGRESSION
Run the complete active M01-M07 regression suite, including all active M06 geometry tests and active M07 focused tests.

Also run:
- Godot 4.7.x import/startup;
- parse/check-only for touched production scripts;
- `git diff --check`.

Do not exclude a known failing test by declaring it retired.

## Final response
Return only:
- M06-R08 log URL + implementation commit SHA;
- M07-R08 log URL + implementation commit SHA;
- exact final regression result;
- `AWAITING_AUDIT`.

Then STOP.
