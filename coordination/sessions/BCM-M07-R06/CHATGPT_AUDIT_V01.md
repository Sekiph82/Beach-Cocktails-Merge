# BCM-M07-R06 — Independent Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Accepted findings
- BEST SCORE remains left under the logo.
- SCORE moved to the right beneath/near NEXT without entering gameplay-bound calculations.
- BEST/SCORE keep fixed 20 px font sizing and 7-digit clamp behavior.
- Production now recenters rendered glyph bounds in the measured recessed value window after every HUD refresh.
- To-Go remains target cocktail + digits-only reward, with reward moved into the cream-board lower-middle region.
- To-Go ropes remain top-attached and behind the panel.
- Held visual anchoring now validates both visible-body X center and body-bottom Y against the launch halo/baseline.
- NEXT and baked 2x6 progression contracts were preserved.

## Blocking finding
### F-M07-R06-001 — Locked full-regression requirement is not satisfied
BCM-M07-R06 criterion 18 requires the full M01-M07 regression to pass. The builder log explicitly acknowledges that `tests/m06_environment_geometry_probe.gd` currently fails because it still asserts superseded M06-R04 geometry, and the final suite omits that known failing test from the active acceptance list.

Because M07-R06 is required to preserve accepted M06-R06 geometry and pass the full M01-M07 regression, this unresolved M06 regression test blocks final M07 acceptance too.

## Important scope note
No new production HUD defect was found from source/diff evidence in this audit. Do **not** redo the M07-R06 layout changes unless the reconciled regression test exposes a real problem. The remediation should be regression-harness reconciliation first, followed by a full rerun.

## Required remediation
1. Reconcile the stale baseline M06 geometry probe/datasets with the R06 piecewise full-tabletop contract.
2. Re-run M06 baseline + M06-R06 focused probe.
3. Re-run M07-R04 and M07-R06 focused probes unchanged.
4. Run the complete M01-M07 suite with no known failing test.
5. Preserve all current owner-approved M07-R06 layout behavior unless a genuine regression is demonstrated.

Until then: **CHANGES_REQUIRED**.
