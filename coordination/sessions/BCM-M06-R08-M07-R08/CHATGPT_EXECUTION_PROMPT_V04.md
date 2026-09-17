# BCM-M06-R08 + BCM-M07-R08 — Consolidated Owner Refinement Master Prompt V04

Status: **ISSUED — CONSOLIDATED / SUPERSEDES R08 V01-V03**

## Why this V04 exists
The last prompt actually executed by Codex was:

`coordination/sessions/BCM-M06-R07-M07-R07/CHATGPT_EXECUTION_PROMPT_V03.md`

The owner did **not** execute any of the intermediate R08 V01/V02/V03 prompts. Therefore this V04 is the single authoritative follow-up prompt that consolidates every owner refinement requested after R07.

Do not assume any R08 work has already been implemented.

This prompt begins from the current repository state after the completed R07 implementation/audit cycle and applies all subsequent owner-requested changes in one bounded sequence.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V03.md`
- `coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md`

Do not edit `TASKS.md`, ChatGPT-owned prompts/audits/criteria/policy files, canonical PNGs, historical logs, or M08+ work.

---

# PHASE 1 — BCM-M06-R08 — Common rear-edge body contact

## Owner-observed problem
The current running build still leaves cocktails too far from the visible rear edge of the wooden tabletop. A visible strip of valid rear wood remains unused.

The owner wants **every cocktail level L01-L12 to physically reach the same visible rear tabletop boundary**.

## Mandatory mathematical contract
There is ONE common rear tabletop boundary for all cocktail levels:

```text
rear_table_y
```

Godot 2D screen coordinates increase downward on +Y.

For each cocktail, determine the current vertical half-extent of the **glass/container body only**:

```text
body_half_extent_y = current_visible_glass_body_height / 2
```

If the active `CollisionShape2D` circular radius accurately represents the body vertical half-extent, it may be used directly:

```text
body_half_extent_y = collider_radius
```

The cocktail center target at rear contact MUST be computed as:

```text
rear_target_center_y = rear_table_y + body_half_extent_y
```

The required invariant is:

```text
visible_body_top_y = rear_target_center_y - body_half_extent_y
visible_body_top_y == rear_table_y
```

Equivalent physical meaning:

> **The rear-most/top-most edge of the visible glass/container body must be tangent to the same rear tabletop boundary for every level L01-L12.**

### Important consequences
- Do NOT create different rear table boundaries for different levels.
- Do NOT hardcode per-level rear target Y positions.
- Do NOT use one shared cocktail-center Y stop for every level.
- Different cocktail levels naturally have different center Y values only because their body half-extents differ.
- L01 and L12 must both touch the exact same table rear edge with their glass/container body.
- Decorative garnish, straw, fruit, leaves, flowers, umbrellas, etc. are NOT part of the rear body extent.
- No artificial visible gap may remain between valid rear wood and the glass/container body at rest/contact.
- The glass/container body must not pass beyond the visible wooden tabletop.

## Rear-left / rear-right corner behavior
The owner does not want the extreme rear corners to feel like hard square invisible walls.

A very subtle, smooth center-seeking influence near the extreme rear-left/rear-right corner region is acceptable if Codex determines it is technically appropriate, provided that:
- it is weak and local;
- it does not overpower player momentum;
- it does not visibly snap drinks sideways;
- it does not prevent valid rear-edge tangency;
- it does not create oscillation/sticking;
- it does not change launch speed/deceleration contracts.

Codex may choose the safest implementation architecture for this corner behavior, but the mandatory rear-edge equation above is NOT optional.

## Preserve
- current owner-approved held-drink launch alignment;
- launch speed `700 px/s`;
- deceleration `180 px/s²`;
- current collision/momentum transfer behavior;
- same-level merge behavior;
- combo/scoring/To-Go economy;
- persistence;
- Game Over/restart;
- rapid launch behavior;
- current danger-line and launch-zone world positions unless a genuine technical dependency is discovered and fully documented;
- no guide line.

## Required M06 evidence
Retain evidence for:
- `720x1280`
- `720x1440`
- `800x1280`

Evidence must demonstrate:
- L01-L12 rear contact validation;
- representative small/mid/large rear-center cases;
- representative rear-left and rear-right cases;
- body-edge tangency to the common rear boundary;
- no artificial rear dead zone;
- no glass/container body overflow beyond visible wood;
- any corner-guidance behavior, if implemented, is subtle and smooth.

Write immutable log:

`coordination/sessions/BCM-M06-R08/CODEX_LOG_V01.md`

Commit and push Phase 1 before Phase 2.

---

# PHASE 2 — BCM-M07-R08 — To-Go vertical placement and score-number centering

## To-Go panel final owner rule
The owner does NOT want runtime rope extension.

Therefore:
- Do NOT extend the To-Go ropes.
- Do NOT redraw the ropes.
- Do NOT fake extra rope geometry.
- Do NOT modify the To-Go canonical PNG.
- Do NOT alter the supplied rope artwork inside the PNG.

Instead, move the **entire existing To-Go asset/panel as one unit upward** until:

> **the topmost visible pixel/artwork of the supplied To-Go asset itself touches the top edge of the gameplay viewport.**

The panel/image moves; the rope artwork itself does not change.

Any runtime-only rope-extension objects/geometry introduced in earlier rounds solely to bridge the ceiling gap must be removed or disabled.

Preserve To-Go runtime content:
- target cocktail;
- reward digits only;
- no `Lx/name`;
- no leading `+`;
- reward fully inside the cream board.

## BEST SCORE and SCORE numeric placement
The owner confirms their horizontal placement/centering is correct.

The remaining defect is vertical placement.

For BOTH BEST SCORE and SCORE:
- keep the fixed production font size;
- keep the seven-digit maximum through `9999999`;
- keep BEST SCORE left under the logo;
- keep SCORE right beneath/near NEXT;
- preserve horizontal centering;
- move the rendered numeric glyphs so they are also **visually centered vertically inside the actual dark/gold-framed value recess**.

Validation must use the actual baked recess and rendered glyph bounds. Do not simply move a test expectation box by the same amount as production.

## Held drink is frozen / owner-approved
The current held-drink placement on the gold launch oval is OWNER-APPROVED.

Do NOT modify:
- held-drink baseline;
- held-drink X alignment;
- held body-foot anchor;
- halo alignment;
- launch-zone placement.

Any regression here is a failure.

## Preserve
- NEXT L01-L12 containment;
- baked 2x6 progression;
- progression top row L07-L12;
- progression bottom row L01-L06;
- canonical PNGs;
- corrected M06-R08 tabletop behavior;
- no guide line.

## Required M07 evidence
Retain evidence for:
- `720x1280`
- `720x1440`
- `800x1280`

Evidence must prove:
- To-Go asset topmost visible artwork touches viewport top;
- no runtime rope extension is used;
- To-Go content remains fully visible;
- BEST SCORE numeric glyphs are horizontally and vertically centered in the real dark recess;
- SCORE numeric glyphs are horizontally and vertically centered in the real dark recess;
- representative short/medium/7-digit values fit correctly;
- owner-approved held drink remains unchanged.

Write immutable log:

`coordination/sessions/BCM-M07-R08/CODEX_LOG_V01.md`

Commit and push Phase 2 separately.

---

# FINAL REGRESSION

After both implementation phases, run the complete active M01-M07 regression suite.

This must include all active M06 geometry/playfield tests and all active M07 focused/HUD tests.

Also run:
- Godot 4.7.x import/startup;
- parse/check-only for every touched production script;
- `git diff --check`.

Do not exclude a known failing test by declaring it retired.

## Governance
- Do not edit `TASKS.md`.
- Do not edit ChatGPT-owned prompt/audit/criteria/policy files.
- Do not rewrite historical logs.
- Do not modify canonical PNGs.
- Do not start M08+.
- Do not self-audit or assign `AUDITED_PASS`.

## Final response
Return only:
- M06-R08 log URL + implementation commit SHA;
- M07-R08 log URL + implementation commit SHA;
- exact final active M01-M07 regression result;
- `AWAITING_AUDIT`.

Then STOP.
