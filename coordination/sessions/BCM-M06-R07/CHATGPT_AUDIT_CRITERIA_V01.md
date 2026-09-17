# BCM-M06-R07 — Regression Harness Reconciliation Audit Criteria V01

Status: **LOCKED BEFORE IMPLEMENTATION**

## Scope
Reconcile the stale baseline M06 regression harness with the already-implemented M06-R06 piecewise/full-tabletop geometry. Do not redesign production geometry unless the reconciled test demonstrates a real production defect.

## PASS requirements
1. `tests/m06_environment_geometry_probe.gd` no longer fails merely because it asserts the superseded M06-R04 two-endpoint geometry.
2. The baseline M06 probe validates the current authoritative M06-R06 piecewise five-sample/full-tabletop contract.
3. Any datasets used by the baseline M06 probe are updated to current R06 independent geometry evidence and do not silently preserve stale R04 expectations.
4. Coverage is preserved or improved; do not delete/skip assertions simply to make the suite green.
5. `tests/m06_r06_full_tabletop_probe.gd` continues to pass unchanged in intent.
6. Production `scripts/game_manager.gd` geometry remains unchanged unless a genuine mismatch is found and documented.
7. M07-R06 HUD behavior remains unchanged.
8. Full M01-M07 regression runs include the reconciled baseline M06 probe, M06-R06 focused probe, M07-R04 probe and M07-R06 probe, all exit 0.
9. Godot import/startup and `git diff --check` pass.
10. No canonical PNG, TASKS.md, ChatGPT-owned file, historical log or M08+ work is modified.

Any material failure blocks AUDITED_PASS.
