# BCM-M06-R08 + BCM-M07-R08 — Owner Runtime Refinement Master Prompt V01

Status: **ISSUED — PROBLEM-DRIVEN**

This prompt is intentionally problem-driven rather than solution-prescriptive. Codex must inspect the current implementation and choose the safest technical solution that satisfies the owner-visible result.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

Do not edit `TASKS.md`, ChatGPT-owned files, canonical PNGs, historical logs or M08+ work.

---

# PHASE 1 — BCM-M06-R08 — Rear tabletop stopping and corner behavior

## Owner-observed problem
In the current runtime build, cocktails still stop too far from the visible rear edge of the wooden tabletop. The rear playable area therefore still feels smaller than the table artwork suggests.

At the same time, large cocktails must not visually hang off the rear edge. The owner expects rear stopping distance to depend on the cocktail's current size/body footprint rather than one shared fixed stopping distance.

The owner also wants the extreme rear-left/rear-right table corners to feel gently rounded rather than like hard square invisible walls. A subtle center-seeking influence near the rear corners is acceptable if needed, provided it is smooth and nearly invisible to the player.

## Desired behavior
- Small drinks may travel closer to the rear edge than large drinks when their visible body permits it.
- Large drinks stop farther from the rear edge automatically according to current body/physical footprint.
- Visible glass/container bodies remain on the wooden tabletop.
- Garnish may naturally overhang if visually credible.
- Rear-left and rear-right movement should feel organic, not sticky, square or abrupt.
- If a subtle center-guidance behavior is used near rear corners, it must be weak, local and smooth.

The owner supplied the following conceptual guidance from another AI as inspiration only, NOT as mandatory implementation instructions:
- derive rear stopping distance dynamically from the current cocktail radius/body size;
- conceptually stop upward travel when the cocktail's rear/body edge reaches the table rear boundary rather than when the center reaches a fixed Y;
- optionally apply a small smooth center-seeking X influence only near extreme rear corners.

Codex must decide whether those ideas fit the current architecture or whether another solution is safer.

## Preserve
- current accepted held-drink launch alignment;
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
- rear-center placements for small/mid/large levels;
- rear-left and rear-right placements for small/mid/large levels;
- body containment on visible wood;
- visibly different size-aware stopping distances where appropriate;
- any implemented corner-guidance trajectory/behavior in a way that proves it remains subtle.

Write:
`coordination/sessions/BCM-M06-R08/CODEX_LOG_V01.md`

Commit and push Phase 1 before Phase 2.

---

# PHASE 2 — BCM-M07-R08 — To-Go placement and score vertical centering

## Owner-observed problem and final requested state

### To-Go
The current runtime extends the ropes upward. The owner does NOT want that.

Do not modify the To-Go PNG and do not extend/redraw/fake the ropes.

Instead, move the **entire existing To-Go asset/panel upward** until the asset's own **topmost visible artwork** touches the top edge of the gameplay viewport.

In other words, the asset itself should reach the ceiling. The ropes and artwork inside the supplied PNG remain exactly as supplied.

Any runtime-only rope extension introduced in earlier rounds solely to bridge the top gap should be removed/disabled.

Preserve To-Go content rules:
- target cocktail + reward digits only;
- no Lx/name;
- no leading plus;
- reward remains inside cream board.

### BEST SCORE and SCORE
Their horizontal centering is now acceptable.
Their vertical centering is not.

Both numeric values must be visually centered vertically as well as horizontally inside the actual dark/gold-framed value recesses.

Keep:
- fixed font size;
- seven-digit maximum through `9999999`;
- BEST on left under logo;
- SCORE on right under/near NEXT.

Do not achieve the result by moving expected test boxes together with the production value. Validation must use the actual visible recess and rendered glyph bounds.

### Held drink
The current held-drink placement on the gold oval is **OWNER-APPROVED**.

Do not modify the held-drink baseline, X alignment, body-foot anchor or halo alignment in this phase.

## Preserve
- NEXT L01-L12 containment;
- baked 2x6 progression, top L07-L12 / bottom L01-L06;
- canonical PNGs;
- corrected M06-R08 gameplay geometry;
- no guide line.

## Evidence
Retain 720x1280, 720x1440 and 800x1280 runtime screenshots plus close-ups proving:
- To-Go asset's topmost visible artwork touches the viewport top without runtime rope extension;
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
