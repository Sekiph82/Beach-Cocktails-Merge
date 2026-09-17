# BCM-M06-R06 — Independent Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Accepted findings
- Production geometry now uses five measured source-space samples per side and piecewise interpolation rather than the superseded single far-to-near line.
- `get_horizontal_bounds_at_y()` remains radius + epsilon and HUD-independent.
- Side walls are segmented along the piecewise boundary and offset outward.
- Danger/launch coordinates and gameplay constants were preserved.
- Focused M06-R06 probe and retained evidence were produced for all three required portrait viewports.

## Blocking finding
### F-M06-R06-001 — Full regression is not green because the legacy M06 geometry probe remains an active failing test
The Codex log explicitly states that `tests/m06_environment_geometry_probe.gd` was run and fails because its M06-R04 datasets still assert the superseded narrow two-endpoint geometry. The file remains in `tests/` as a normal deterministic M06 probe and is not archived/renamed/marked non-authoritative in repository structure.

Locked criterion 17 requires the full M01-M07 regression to pass. Excluding a known failing M06 regression test ad hoc does not satisfy that criterion.

The production R06 geometry itself does not need to be reverted. The required remediation is to update the legacy M06 geometry regression and its authoritative geometry datasets so they validate the current R06 piecewise/full-tabletop contract, or formally replace it in a repository-governed way while preserving equivalent coverage. Do not simply weaken assertions or delete coverage.

## Scope result
No evidence of canonical PNG changes, TASKS edits by Codex, ChatGPT-owned file edits, historical-log rewriting, or M08+ work was found in the bounded implementation commit.

## Required remediation
1. Reconcile `tests/m06_environment_geometry_probe.gd` with the accepted M06-R06 geometry contract.
2. Update/replace stale M06-R04 geometry datasets referenced by that probe with R06-authoritative independent data.
3. Preserve background/rail/launch/danger visual and gameplay behavior.
4. Run BOTH the reconciled baseline M06 probe and `m06_r06_full_tabletop_probe.gd` successfully.
5. Run the complete M01-M07 suite with no known geometry test failure.

Until then: **CHANGES_REQUIRED**.
