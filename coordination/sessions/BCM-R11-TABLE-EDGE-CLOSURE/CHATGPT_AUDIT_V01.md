# BCM-R11 — Independent Table-Edge Closure Audit V01

Verdict: **AUDITED_PASS FOR TABLE-EDGE / M06 CLOSURE**

Audited commit:
`9d6d8950da5f62f6c22d495f58414d70d034d893`

Primary documentation:
- `docs/BCM-R11_TABLE_EDGE_FIX_REPORT.md`
- `docs/WHAT_TO_DO_IF_TABLE_CHANGES.md`

## Scope

This audit reviews the owner-directed R11 hotfix that supersedes the failed R10 V09/V10 full-silhouette boundary model.

R11 was implemented outside the normal pre-issued four-artifact builder protocol. This audit does not pretend that locked R11 criteria existed before implementation. The implementation is nevertheless independently reviewed here against the already-documented owner defects, repository source, preserved gameplay contracts, regression evidence, and explicit owner runtime acceptance.

## Contract recovered from owner defects

The accepted fix must:
1. stop level-dependent growth of the visible table-edge gap;
2. stop near-edge merges from throwing the larger result inward merely because it is larger;
3. remove the inconsistent light-touch vs hard-hit boundary behavior;
4. preserve V05 table rail coordinates;
5. preserve drink-to-drink CircleShape2D gameplay physics, merge momentum, launch/deceleration, HUD and canonical assets;
6. keep drinks constrained by the intended table-plane contact point rather than by the full above-plane cocktail silhouette.

## Repository findings

### PASS — table-plane footprint replaces full-silhouette boundary response

`Drink.get_table_footprint_local()` derives a zero-height horizontal segment from the lowest Y of the measured body hull while retaining the hull's asymmetric X extent.

This is structurally different from the rejected R10 model: the full rim/body/garnish silhouette no longer determines table-edge clearance.

### PASS — low-speed and settled-body inconsistency is fixed

`Drink._integrate_forces()` now executes the footprint projection before the settled-body 8 px/s promotion check.

Therefore a low-speed nudge can no longer bypass boundary enforcement while a stronger hit activates a different rule.

`set_settled()` also projects once immediately before sleeping, closing the last-step/sleeping-body gap.

### PASS — one boundary rule is used by runtime, merge and drag positioning

The production paths now call `project_footprint_inside_table()`:
- live rigid-body integration;
- merge result correction;
- held/drag positioning;
- settling correction.

This removes the prior mismatch between normal motion and merge-time placement.

### PASS — rear clearance is level-independent

`REAR_EDGE_MARGIN := 12.0` is a constant screen-space art clearance and is not derived from collider radius or drink level.

### PASS — drink-to-drink physics remains separate

The existing CircleShape2D radii and drink-to-drink gameplay role remain intact. R11 changes table-plane containment rather than retuning inter-drink collision geometry.

### PASS — frozen table geometry preserved

The owner-approved V05 rail coordinate constants are not changed by R11.

### PASS — owner runtime acceptance

The owner explicitly reports that the table-edge gap problem is solved in the normal game runtime.

This direct owner acceptance supersedes older R10 builder screenshots and owner runtime failures for the table-edge issue.

## Superseded historical tests

The following probes encode the rejected R10 contract that the *entire visual/body hull* must remain inside the rail half-planes:

- `tests/r10_v09_visual_hull_containment_probe.gd`
- `tests/r10_v10_visual_hull_containment_probe.gd`

They are historical evidence and are no longer acceptance gates for current table-edge behavior.

They should not be rewritten to manufacture a pass. Their failures under R11 are expected because R11 deliberately changes the contact model.

Future boundary validation must test the table footprint:
- constant side tangency independent of level;
- constant rear margin independent of level;
- near-edge merge stability;
- equivalent light/hard-contact containment;
- no table-plane footprint escape.

## Regression evidence

The handoff reports:
- Godot 4.7.2 production parse/check PASS;
- M01/M02/M03/M04/M05/M07 PASS;
- R09 no-input PASS;
- R10 desktop smoke PASS;
- V09 failure-reproduction path PASS under the new behavior;
- Godot import/startup PASS;
- `git diff --check` PASS;
- local HEAD, origin/main and remote main equal at `9d6d8950da5f62f6c22d495f58414d70d034d893`.

Historical probes that depend on removed APIs remain historical and are not rewritten.

## Architecture note / technical debt

The current footprint solver still contains comments describing the piecewise rail envelope as convex and evaluates rail half-planes globally. Earlier R10 audit work showed that the sampled rail chain is not strictly globally convex by cross-product sign.

The owner-accepted R11 behavior demonstrates that this does not currently block the production footprint result, but the statement should not be treated as a general mathematical guarantee for arbitrary future table artwork. `docs/WHAT_TO_DO_IF_TABLE_CHANGES.md` correctly warns that future table shapes must be validated carefully.

This is a **NOTE**, not a current owner-visible blocker.

## Cross-milestone status

### M06

The table-envelope / cocktail-to-edge issue is now accepted.

**M06: PASS / CLOSE.**

### M07

R11 does not alter the previously owner-accepted HUD, score positioning, NEXT, To-Go placement, held alignment or logo work. Current regression evidence reports M07 probes passing.

Based on prior owner acceptance plus preserved source behavior:

**M07: PASS / CLOSE.**

### M05

R11 does **not** resolve the historical M05-R02 strict-audit blocker.

M05-R02 concerns independent provenance of body/collider measurements, incorrect shape classification in the old independent dataset, and circular contact-fit proof. R11 reuses existing body/hull data but does not independently re-establish those measurements.

Therefore:

**M05 remains CHANGES_REQUIRED.**

It must be resolved independently before the tracker may progress to M08 under the current governance rule.

## Final verdict

**R11 table-edge fix: AUDITED_PASS for M06 closure.**

**M07 may also close based on preserved owner-accepted behavior and passing regression evidence.**

**M05 remains the only pre-M08 blocker.**
