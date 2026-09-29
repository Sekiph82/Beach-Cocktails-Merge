# BCM-M17 V07-R03 Child 01 - Typed Mapping Fix and Fresh Confirmation

## Scope

Remediate only the V07-R02 runner/report integrity failure. Preserve all V07-R02 and V07-R01 evidence. Do not edit root `TASKS.md` or canonical data.

## Required work

1. Complete clean synchronized preflight and freeze-hash proof.
2. Create `tools/campaign/m17_canonical_confirmation_v07_r03.gd` from R02.
3. Correct only the typed/numeric semantic normalization used by member/signature mapping comparison. Prove all 45 source/canonical mappings compare equal without weakening representative, structure, key, value, telemetry, action-log, candidate, seed, VIP, or report-integrity validation.
4. Use R03 output paths, report identifiers, and fresh seeds `18000000 + representative*100 + trial_index`, index 1..4.
5. Parse-check, commit, push, synchronize, and prove exact runner bytes before any direct run.
6. Run the exact committed runner once. Require direct PASS / exit 0, 42 candidates, 168 new trials, 42 x 5 aggregates, 213 unique seeds, zero validation errors, R03 PASS marker, and VIP 0/25 forced / 25/25 surplus.
7. Stop without repair/rerun/regressions if direct execution fails. If it passes, run the locked regression sequence and record all results.

## Handoff

Write `CODEX_LOG_V07_R03_CHILD_01.md` with exact evidence and stop at `AWAITING_M17_AUDIT_V07_R03` in the master log. Do not tune M17 canonical data or start M18.
