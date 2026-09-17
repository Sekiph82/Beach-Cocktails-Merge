# BCM-M06-R06 + BCM-M07-R06 — Owner Runtime Remediation Master Prompt V01

Status: **ISSUED**

## Authority
The latest owner runtime screenshot dated 2026-09-17 supersedes earlier self-consistent PASS interpretations where they conflict with visible owner evidence.

Read first:
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R05/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M07-R05/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M06-R06/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_CRITERIA_V01.md`

Then run governed sync preflight.

Do not edit TASKS.md or any ChatGPT-owned audit/prompt/criteria/policy file.
Do not modify canonical PNGs.
Do not start M08+.
Do not self-audit.

---

# PHASE 1 — BCM-M06-R06 — Fix the still-restricted rear tabletop

The previous M06-R05 probe proved only that cocktails reached the production `rails`. The owner's later runtime screenshot proves those rails are still too far inward in the rear part of the table.

## Required implementation

1. Re-measure the visible **inner tabletop boundary** directly from the active owner-approved background/runtime render.
2. Do NOT reuse the old far rail constants as ground truth merely because previous probes used them.
3. Measure at least 5 Y samples per side spanning:
   - far/rear edge,
   - rear-upper third,
   - middle,
   - lower-middle,
   - near/front.
4. Store these measurements in an independent evidence dataset separate from production constants.
5. If one straight left/right interpolation cuts off visible wood, replace it with a piecewise-linear/polyline or equivalent boundary model.
6. Production `get_table_rail_bounds_at_y()` must follow the real visible edge closely at all measured depths.
7. Continue using body radius plus only tiny solver epsilon for center-safe horizontal limits. Do not reintroduce wall-thickness double inset.
8. Place collision-wall inward faces on the corrected visible boundaries.
9. Validate not only numeric contact but actual rendered L01/L06/L12 placements at rear-left and rear-right. The visible glass/container body must be able to occupy the rear wood up to the true edge.
10. Inspect rear Y containment too. If the current top-stop/circle-radius model leaves a visible rear strip that the glass body cannot occupy, remediate that specific mismatch without changing launch/deceleration/economy. The acceptance target is visible glass-body coverage of the usable tabletop, not mere circle-center arithmetic.

Preserve:
- current background and all canonical PNGs;
- danger Y and launch Y unless owner evidence absolutely requires otherwise;
- 700 px/s launch;
- 180 px/s² deceleration;
- M01-M05 gameplay/economy/merge/persistence;
- no guide line.

## Evidence
Retain at 720x1280, 720x1440, 800x1280:
- clean screenshot;
- overlay with independent measured table edges and production boundaries;
- at least 5 measured points per side;
- rear-left/rear-right rendered contact cases for L01/L06/L12;
- numeric deltas between independent edge and production edge.

Write:
`coordination/sessions/BCM-M06-R06/CODEX_LOG_V01.md`

Commit and push this phase separately before continuing.

---

# PHASE 2 — BCM-M07-R06 — Apply latest owner annotations

Preserve all accepted M07-R04 behavior, but correct the owner-visible layout defects shown in the latest screenshot.

## A. BEST SCORE
- Keep BEST SCORE on the left under the logo.
- Keep the existing fixed production font size.
- Do NOT change font size per value.
- Reposition the label using actual rendered glyph bounds so the digits are visually centered both horizontally and vertically inside the dark recessed rectangle.
- Validate 0, 321, 24380, 999999, 9999999.

## B. SCORE
- Move the entire SCORE panel to the **right side beneath/near NEXT**, matching the owner's annotation.
- Do not leave a second SCORE panel on the left.
- Keep it fully visible and non-overlapping with NEXT, To-Go, table or screen edge.
- Keep the existing fixed font size and 7-digit maximum contract.
- Center digits both horizontally and vertically inside the dark recessed value rectangle using rendered glyph bounds.
- SCORE remains HUD-only and must not participate in any physics/playfield bound.

## C. To-Go reward
- Runtime remains target cocktail + reward digits only.
- No Lx/name.
- No leading `+`.
- Move reward from the too-low position into the **owner-marked lower-middle area inside the cream board**.
- Reward must be fully inside the cream panel and visually balanced beneath/near the target cocktail without overlap.
- Ceiling ropes remain attached to viewport top.

## D. Held cocktail / launch halo
- The current Y-baseline-only proof is insufficient.
- For every L01-L12, measure the visible glass/container body bbox excluding garnish where appropriate.
- Align the visible body bottom to the accepted launch baseline.
- ALSO horizontally center the visible glass/container body on the gold oval / launch-position X.
- Do not center by full texture alpha rect or garnish centroid.
- This is visual-only: do not change physics body center, collider radius, launch speed, deceleration, momentum, merge or economy.
- Retain an L01-L12 contact sheet showing body-center X delta and body-bottom Y delta relative to halo center/baseline.

## E. Preserve
- NEXT L01-L12 safe fit;
- To-Go ropes to viewport top;
- baked 2x6 progression top L07-L12 / bottom L01-L06;
- no runtime progression frames;
- no guide line;
- corrected M06-R06 full-tabletop geometry.

## Evidence
At 720x1280, 720x1440, 800x1280 retain clean screenshots proving:
- BEST left and centered;
- SCORE right under/near NEXT and centered;
- To-Go reward inside board;
- held drink centered on halo;
- corrected rear tabletop remains unobstructed and playable.

Write:
`coordination/sessions/BCM-M07-R06/CODEX_LOG_V01.md`

Commit and push separately.

---

# FINAL REGRESSION
Run on final candidate main:
- M01 contract
- M02 physics/collision/merge
- M03 economy/To-Go/persistence/Game Over
- M04 asset import
- M05 sprite/collider probe
- M06-R06 rear-table/full-width probe
- M07-R04 focused probe where still applicable
- M07-R06 owner-layout probe
- Godot 4.7.x import/startup
- `git diff --check`

Do not weaken historical tests simply to obtain green results. If an old test encodes a superseded owner layout, update only the superseded expectation and document why.

Final response only:
- M06-R06 log URL + commit SHA
- M07-R06 log URL + commit SHA
- one-line final regression result
- `AWAITING_AUDIT`

Then STOP.