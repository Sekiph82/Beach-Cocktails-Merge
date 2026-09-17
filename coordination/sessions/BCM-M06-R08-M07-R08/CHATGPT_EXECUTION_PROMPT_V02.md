# BCM-M06-R08 + BCM-M07-R08 — Owner Runtime Refinement Master Prompt V02

Status: **ISSUED — SUPERSEDES V01**

This prompt is intentionally problem-driven rather than solution-prescriptive. Codex must inspect the current implementation and choose the safest technical solution that satisfies the owner-visible result.

V02 corrects one critical interpretation from V01: **all cocktail levels must reach the same visible rear tabletop boundary with their visible glass/container body edge touching that boundary.** Smaller drinks are not given a farther rear gameplay limit than larger drinks.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V02.md`
- `coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

Do not edit `TASKS.md`, ChatGPT-owned files, canonical PNGs, historical logs or M08+ work.

---

# PHASE 1 — BCM-M06-R08 — Common rear-edge contact and corner behavior

## Owner-observed problem
In the current runtime build, cocktails still stop too far from the visible rear edge of the wooden tabletop. A visible strip of rear wood remains unused.

## Critical owner rule
Every cocktail level L01-L12 must be able to move rearward until the **rear-most edge of its visible glass/container body touches the same visible rear tabletop boundary**.

The rear table boundary is common to every level.

Do NOT create different rear gameplay boundaries for different cocktail sizes.

Per-level size/body footprint is relevant only because it changes the center position at which that cocktail's body edge becomes tangent to the same boundary.

Therefore:
- a larger cocktail center will naturally stop farther from the rear boundary;
- a smaller cocktail center may be physically closer to the boundary;
- but **the visible body rear edge of both must touch the same table edge**;
- no drink should stop with an artificial visible gap between its glass/container body and valid rear wood;
- no glass/container body may pass beyond the visible wooden tabletop.

The owner also wants the extreme rear-left/rear-right table corners to feel gently rounded rather than like hard square invisible walls. A subtle center-seeking influence near the rear corners is acceptable if needed, provided it is smooth, nearly invisible, and does not prevent legitimate body-edge contact with the common rear boundary.

## Conceptual guidance, not mandatory implementation
The owner shared another AI's suggestion as inspiration only:
- determine contact from the current cocktail physical/visible body size rather than one shared center-Y stop;
- conceptually stop upward travel when the cocktail body edge reaches the rear table edge;
- optionally use a small smooth center-seeking influence only near extreme rear corners.

Codex must decide whether those ideas fit the current architecture or whether another solution is safer.

## Required owner-visible result
- L01-L12 can all reach rear-edge contact.
- Body-edge contact is tangent to one common visible rear table boundary.
- No artificial rear dead zone remains.
- Glass/container bodies remain on wood.
- Rear-left/rear-center/rear-right behavior is credible.
- Extreme rear corners feel organic rather than sticky/square if corner guidance is needed.

## Preserve
- current owner-approved held-drink launch alignment;
- 700 px/s launch speed;
- 180 px/s² deceleration;
- collisions and momentum transfer;
- same-level merge behavior;
- combo/scoring/To-Go economy;
- persistence, Game Over and restart;
- current danger and launch world positions unless a genuine dependency is proven;
- no guide line.

## Evidence
Retain runtime evidence for 720x1280, 720x1440 and 800x1280 showing:
- L01-L12 rear contact validation;
- clear representative small/mid/large rear-center contacts;
- rear-left and rear-right contacts;
- visible glass/container body edge touching the common rear boundary without artificial gap or body overflow;
- any implemented corner-guidance trajectory/behavior proving it remains subtle.

Write:
`coordination/sessions/BCM-M06-R08/CODEX_LOG_V01.md`

Commit and push Phase 1 before Phase 2.

---

# PHASE 2 — BCM-M07-R08 — To-Go placement and score vertical centering

## To-Go
Do NOT extend, redraw, fake or modify the To-Go ropes.
Do NOT modify the canonical To-Go PNG.

Move the complete existing To-Go asset/panel upward until the asset's own **topmost visible artwork touches the top edge of the gameplay viewport**.

The asset itself reaches the ceiling. Its supplied rope/artwork remains untouched.

Remove/disable runtime-only rope extensions introduced solely to bridge the previous gap.

Preserve To-Go content rules:
- target cocktail + reward digits only;
- no Lx/name;
- no leading plus;
- reward remains inside cream board.

## BEST SCORE and SCORE
Their horizontal centering is accepted.
Their vertical centering is not yet accepted.

Both numeric values must be visually centered vertically as well as horizontally inside the actual dark/gold-framed value recesses.

Keep:
- fixed font size;
- seven-digit maximum through `9999999`;
- BEST on left under logo;
- SCORE on right under/near NEXT.

Do not move the expected test box together with the production value. Validate against the actual baked recess and rendered glyph bounds.

## Held drink
The current held-drink placement on the gold oval is **OWNER-APPROVED**.
Do not modify held-drink baseline, X alignment, body-foot anchor or halo alignment.

## Preserve
- NEXT L01-L12 containment;
- baked 2x6 progression, top L07-L12 / bottom L01-L06;
- canonical PNGs;
- corrected M06-R08 gameplay geometry;
- no guide line.

## Evidence
Retain 720x1280, 720x1440 and 800x1280 runtime screenshots plus close-ups proving:
- To-Go asset's own topmost visible artwork touches viewport top with no runtime rope extension;
- To-Go content remains fully visible;
- BEST and SCORE digits are vertically and horizontally centered for representative short/medium/7-digit values;
- held drink remains unchanged from the owner-approved current state.

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
