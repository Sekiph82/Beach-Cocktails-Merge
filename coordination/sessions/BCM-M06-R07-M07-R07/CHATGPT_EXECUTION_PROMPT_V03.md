# BCM-M06-R07 + BCM-M07-R07 — Owner Screenshot Problem-Driven Master Prompt V03

Status: **ISSUED — SUPERSEDES V01/V02**

This prompt is intentionally **problem-driven, not solution-prescriptive**.

The owner has supplied a new runtime screenshot from the current Godot build. Your job is to inspect the current production implementation, understand why the observed defects remain, and choose the appropriate technical solution yourself.

Do NOT assume the previous geometry/HUD implementation approach is correct merely because tests pass.
Do NOT blindly follow old constants/datasets if they conflict with the owner-visible runtime result.
Do NOT optimize for green tests at the expense of the screenshot-visible behavior.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R07/CHATGPT_AUDIT_CRITERIA_V03.md`
- `coordination/sessions/BCM-M07-R07/CHATGPT_AUDIT_CRITERIA_V03.md`

Do not edit TASKS.md or ChatGPT-owned prompt/audit/criteria/policy files.
Do not start M08+.
Do not self-audit.

---

# PHASE 1 — BCM-M06-R07 — Fix the real tabletop playfield behavior

## Current owner-visible problem
In the latest running-game screenshot:

- some cocktails can visibly go outside the wooden tabletop at the side/rear area;
- despite this, cocktails still do not reach/occupy all of the rear visible tabletop that the owner expects to be playable;
- therefore the current playfield geometry is simultaneously too permissive in some places and too restrictive in others.

The owner expectation is straightforward:

**The playable region should match the actual visible wooden tabletop surface in the running game.**

Cocktail glass/container bodies should remain on the table, while the clearly visible rear/side wood should be usable gameplay area.

## What must be true when finished
- Drinks must not visibly sit on beach/background/air outside the tabletop.
- Rear-left, rear-center and rear-right visible wooden tabletop areas must be reachable where they are visually part of the table.
- The rear/top gameplay limit must not cut off an obviously usable strip of wood.
- The side gameplay limits must not allow glass/container bodies to leave the table.
- Garnish/straw/fruit/leaves may naturally overhang if the glass/container body remains credible on the table.
- HUD elements must not define physics boundaries.
- Existing gameplay behavior must remain intact unless a genuine dependency is discovered and documented.

## Implementation freedom
You decide how to fix this.

Inspect the current production geometry, walls, clamps, collider/body mapping, perspective mapping, background/table relationship and tests. Use whichever technical model is most appropriate.

You are explicitly NOT required to preserve the current R06 piecewise implementation if a better model is needed.
You are explicitly NOT instructed to use a polygon, curve, polyline, additional samples, different wall model or any particular algorithm.
Choose the solution based on the actual defect.

If an older test/dataset encodes superseded geometry, update it so it tests the intended owner-visible behavior rather than excluding it or weakening it.

## Evidence expected
Retain runtime evidence for:
- 720x1280
- 720x1440
- 800x1280

Evidence must make it visually possible to judge:
- rear-left reachability;
- rear-center reachability;
- rear-right reachability;
- left/right side containment;
- small/mid/large cocktail body placement near critical boundaries.

Numerical helper agreement alone is not enough.

Write:
`coordination/sessions/BCM-M06-R07/CODEX_LOG_V01.md`

Commit and push Phase 1 separately before Phase 2.

---

# PHASE 2 — BCM-M07-R07 — Fix the remaining owner-visible HUD/launch alignment defects

Preserve accepted visual direction and canonical assets.

## Current owner-visible problems
The latest screenshot shows:

### SCORE value position
The SCORE panel is now on the correct right side, but the number itself still appears slightly too low inside the dark recessed rectangle.

Desired result:
- keep the fixed production font size;
- keep the 7-digit maximum contract;
- visually center the number in the dark inner value area, including vertical placement;
- do not regress BEST SCORE.

### To-Go hanging ropes
The ropes still appear visually disconnected from the top/ceiling in the actual running screenshot.

Desired result:
- the panel must read as genuinely suspended from the top of the gameplay viewport;
- there should be no obvious visible break between the top/ceiling and the To-Go rope assembly;
- final screenshot appearance matters more than a coordinate-only assertion.

### Held cocktail / gold launch oval
The held cocktail still does not visually sit in the true center of the gold launch oval.

Desired result:
- for every L01-L12 held cocktail, the visible glass/container body should look correctly centered on the gold oval;
- this must be correct in the final rendered image, not merely according to the same internal constants used by the placement code;
- preserve gameplay/physics unless a genuine dependency discovered in Phase 1 requires a bounded correction.

## Preserve
- BEST SCORE on the left under the logo;
- SCORE on the right beneath/near NEXT;
- fixed score font sizing and 7-digit maximum;
- To-Go target cocktail + reward digits only;
- no Lx/name;
- no leading plus sign;
- reward inside the cream board;
- NEXT L01-L12 containment;
- current baked 2x6 progression, top L07-L12 / bottom L01-L06;
- current canonical PNGs;
- no guide line;
- corrected M06-R07 tabletop behavior.

## Implementation freedom
You decide how to solve these visual defects.

Do not assume the current anchor constants, Line2D approach, label positioning logic or previous tests are necessarily the right mechanism. Inspect the actual rendered result and choose the smallest robust implementation that satisfies the owner-visible end state.

## Evidence expected
Retain runtime evidence for all three required viewports showing:
- SCORE number placement;
- To-Go rope continuity to the top;
- held cocktail centered on the gold oval.

Held-cocktail evidence must cover L01-L12.

Write:
`coordination/sessions/BCM-M07-R07/CODEX_LOG_V01.md`

Commit and push Phase 2 separately.

---

# FINAL REGRESSION

Run the complete active M01-M07 regression set after both phases.

This includes any active baseline M06 geometry test remaining in the repository. Do not hide a known failing test by calling it retired unless repository governance explicitly archives/removes it as part of an independently justified change.

Also run:
- Godot 4.7.x import/startup;
- `git diff --check`.

Do not weaken meaningful test coverage merely to obtain PASS.

## Final response
Return only:
- M06-R07 log URL + commit SHA;
- M07-R07 log URL + commit SHA;
- exact final regression result;
- `AWAITING_AUDIT`.

Then STOP.