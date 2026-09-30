# BCM-M17 V07-R03-R01 Child 01 - Regression Evidence Recapture

## Scope

Close only the missing V07-R03 handoff evidence. Do not edit root `TASKS.md`, the R03 runner, the R03 JSON/Markdown report, canonical data, or any historical evidence.

## Required work

1. Complete clean synchronized preflight and record protected-file hashes.
2. Confirm the existing R03 runner/report direct PASS and record their unchanged SHA-256 values; do not rerun the R03 confirmation runner.
3. Run the locked regression sequence in order: R03 report/hash inspection; V06 analytical probe; V05 optionality probe; M17 difficulty-validation probe twice; M16; M15; M14; M02; diff check; and freeze proofs.
4. Capture complete stdout and exact exit codes. Both M17 runs must include `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.
5. Record final `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` values, proving equality and a clean tree.
6. If any command fails or a required marker is absent, stop without rerun or repair and record the blocker.

## Handoff

Write `CODEX_LOG_V07_R03_R01_CHILD_01.md` and complete the master log with exact evidence. Stop at `AWAITING_M17_AUDIT_V07_R03_R01`. No M17 tuning or M18 work is authorized.
