# BCM-M06-R02 — ChatGPT Strict Re-Audit V01

Decision: **CHANGES_REQUIRED**

This re-audit supersedes the earlier M06 PASS for project progression and supersedes the preliminary M06-R01 reopening notes where they conflict. The owner has explicitly rejected the committed M06 evidence images as not matching the planned visual composition.

## Canonical visual truth

Owner-approved master gameplay visual:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

For M06, HUD-specific elements are not required yet, but the **environment/table silhouette, scale, perspective, screen occupancy, horizon relationship and usable gameplay-surface proportions** must visibly derive from this master.

## Audited against

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- original M06 prompt/log
- M06 implementation range `5fb7351e0f549fd4389f69264b964951403e072b..1d79b49ce770f955c69b07593af520f35b79bbdb`
- `scripts/game_manager.gd`
- `scripts/shot_controller.gd`
- `tests/m06_environment_geometry_probe.gd`
- committed `docs/evidence/m06/*.png`
- M01-M05 regression claims
- owner visual rejection in the current project review
- owner master visual

## Findings

### F-M06-STRICT-001 — Owner visual acceptance explicitly failed — BLOCKER

The owner reviewed the M06 evidence images and stated they are not the planned visual and do not resemble the supplied master closely enough.

For a visual-composition milestone, an explicit owner rejection overrides a prior audit that did not independently inspect the screenshot pixels.

M06 therefore cannot remain PASS.

### F-M06-STRICT-002 — Previous ChatGPT audit acknowledged missing pixel inspection but still passed — MAJOR

The earlier M06 audit explicitly stated that the connector could not decode/inspect the committed screenshot pixels. It then treated that limitation as non-blocking.

Under the corrected audit policy, this is invalid for a milestone whose acceptance gate is visual table/environment agreement. Material visual evidence that is not independently inspected must remain `UNVERIFIED` and block unconditional PASS.

### F-M06-STRICT-003 — M06 implementation never uses the owner master as the geometry/composition truth — MAJOR

Production geometry is derived from manually chosen landmarks in `game_board_background.png`:

- `(292,464)` / `(732,464)` far rail
- `(104,1208)` / `(920,1208)` near rail
- danger source Y `1048`
- launch source Y `1144`

The owner master itself is not referenced by the implementation or validation probe, so the test can pass even when the resulting screenshot visibly diverges from the master composition.

### F-M06-STRICT-004 — Canonical design-space/aspect choice materially changes the master composition — MAJOR

The owner master is `1024x1536`, aspect ratio 2:3. M06 validates a primary gameplay viewport of `720x1280` (9:16), plus `720x1440` and `800x1280`.

The chosen `cover` transform preserves pixel aspect but crops the sides:

- 720x1280 uses scale 0.833333 with x offset about `-66.67` viewport px;
- 720x1440 uses scale 0.9375 with x offset `-120` viewport px.

At 720x1440 the mapped near-left table landmark is already `x=-22.5`, meaning the visible near table edge is cropped outside the viewport.

This may be technically consistent with `cover`, but it is not evidence that the master composition is preserved. The owner rejection confirms that the composition loss is material.

### F-M06-STRICT-005 — Responsive test is too weak to validate visual composition — MAJOR

For each viewport, `tests/m06_environment_geometry_probe.gd` sets `case_ok` from only:

- positive scale;
- non-positive vertical offset;
- a minimal `center_visible` expression.

It does not assert:

- both table rails are visible/credible;
- master-like table screen occupancy;
- horizon/table relationship;
- launch/danger placement relative to visible wood;
- future HUD-safe composition;
- absence of material table clipping.

Therefore all three responsive PASS lines can be green while the visual is wrong.

### F-M06-STRICT-006 — Collider-inside-table check is circular — MAJOR

The M06 probe obtains `safe_bounds` from production `get_horizontal_bounds_at_y()`, spawns the drink at the center of those same bounds, and then verifies the drink is within those bounds.

That proves consistency with production geometry, not agreement with the visible table pixels.

A wrong rail model will still pass its own bounds test.

### F-M06-STRICT-007 — Perspective-rail test proves only monotonic trapezoid shape — MAJOR

The check `top narrower than middle narrower than bottom` verifies a perspective trapezoid in abstract. It does not prove that the lines follow the table shown in the master/background image.

### F-M06-STRICT-008 — Gameplay regressions remain useful and should be preserved — PASS / NOTE

M01-M05 post-M06 regression evidence is valuable for gameplay preservation. The remediation must not throw away working collision, launch, merge, economy, persistence, or cocktail-mapping behavior while fixing composition.

## Acceptance matrix

| Criterion | Re-audit result |
|---|---|
| Canonical environment asset integrated | PASS |
| Background uses uniform non-stretch scaling | PASS |
| Production rail helpers deterministic | PASS |
| Owner-master table/environment composition match | FAIL |
| Owner visual acceptance | FAIL |
| 720x1280 master-like composition | UNVERIFIED / owner rejected overall evidence |
| 720x1440 master-like composition | FAIL risk: near rail cropped; owner rejected overall evidence |
| 800x1280 master-like composition | UNVERIFIED / owner rejected overall evidence |
| Rails independently matched to visible table pixels | FAIL / circular evidence |
| Launch/danger independently matched to visible table | UNVERIFIED |
| Responsive test meaningfully checks visual composition | FAIL |
| M01-M05 regression preservation | PASS by builder evidence, to rerun after remediation |
| No M07 leakage in original M06 | PASS |

## Required remediation

M06 remediation must:

1. treat the owner master as the canonical visual composition truth;
2. re-evaluate canonical logical design resolution/aspect instead of assuming 720x1280 must remain the primary composition space;
3. explicitly decide how the 1024x1536 master is adapted to target phone ratios without destroying the table silhouette;
4. derive and retain measurable table landmarks from the master/background with evidence overlays;
5. create runtime screenshots plus rail/collider overlay screenshots for all representative viewports;
6. strengthen tests so they compare against independent expected landmark/reference data, not the same production helper under test;
7. preserve M01-M05 gameplay contracts;
8. produce a new separate remediation log and stop for strict re-audit.

## Final verdict

**CHANGES_REQUIRED**
