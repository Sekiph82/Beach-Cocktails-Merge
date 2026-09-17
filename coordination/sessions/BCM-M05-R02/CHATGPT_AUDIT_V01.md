# BCM-M05-R02 — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Scope audited

- `coordination/sessions/BCM-M05-R02/CODEX_LOG_V01.md`
- `tools/m05_independent_body_dataset.py`
- current `scripts/drink.gd`
- strengthened M05 probe/dataset claims
- historical locked M05 criteria and R03 remediation requirements

## Major findings

### F-M05-R02-001 — Independent dataset is not convincingly independent — BLOCKER

The new dataset lives outside production code, but its supposedly independent values exactly reproduce the production M05 measurement table:

- body widths in `BODY_BOXES` are exactly the same values as `Drink.VISIBLE_BODY_WIDTH_PX`;
- derived body-center offsets exactly reproduce `Drink.VISIBLE_BODY_CENTER_OFFSET_PX`;
- `TARGET_RADII` exactly reproduces `Drink.COLLIDER_RADII`.

As a result every runtime comparison reports mathematically exact values such as body diameter 40.00 vs target 40.00 and center error 0.00 for all 12 levels. File separation alone does not establish independent provenance. The R03 requirement was to break circular correctness acceptance, not merely copy the same target values into another file.

### F-M05-R02-002 — Shape-diversity review is factually wrong — MAJOR

`tools/m05_independent_body_dataset.py` records:

- martini: L03, L07
- highball: L04, L06, L08
- goblet: L09, L10
- coconut: L05

This conflicts with the approved cocktail artwork contract. Examples: L03 is the green mojito/highball, L04 is the blue martini, L05 is the orange tropical goblet, L06 is the pink martini, L07 is the long highball, L08 is the blue goblet, and L09 is the coconut. Therefore the claimed explicit shape-diversity review is not reliable.

This directly fails the locked requirement that martini/highball/goblet/coconut/pineapple shape diversity be explicitly and correctly reviewed.

### F-M05-R02-003 — Touching-pair zero-gap result remains constructed — MAJOR

The representative center distances equal the sums of the selected radii, while the independent body widths/scales were selected to produce collider diameters exactly. Therefore the reported `visible_gap=0` / `visible_overlap=0` is structurally guaranteed by the duplicated target dataset rather than serving as a genuinely independent apparent-contact measurement.

The test is stronger than the earlier production-helper self-comparison, but it still does not satisfy the intended non-circular acceptance bar.

## Passing areas

- single L01-L12 texture mapping remains intact;
- invalid L13 path remains absent;
- canonical source PNGs are preserved;
- M01-M04 regressions are reported passing;
- merge/current/rapid-launch/restart/Game Over ownership checks remain present;
- historical pre-M05 radius correction is preserved truthfully;
- no M06/M07 production leakage was found in the bounded M05 phase.

## Visual evidence boundary

The current runtime overlay/contact PNG pixels were not independently available through the GitHub connector in this audit. Under the locked rule, apparent contact/pivot visual quality therefore also remains unverified rather than being accepted from the Codex log.

## Final verdict

**CHANGES_REQUIRED**.

The blocker is not that the runtime mapping necessarily looks wrong. The blocker is that the new 'independent' acceptance dataset reproduces the same production measurement/radius values and even contains incorrect shape classifications, so it does not yet provide trustworthy independent correctness evidence.
