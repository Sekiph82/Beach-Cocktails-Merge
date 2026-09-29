# BCM-M17 V06-R01 — Child 03 Remediation Prompt

## Scope

Re-run the complete fresh V06 physical screening for all 45 exact challenge classes. Correct the deterministic aggregate/classification bookkeeping identified in the V06 Child 03 log, but do not use a repair pass after a failing run. The corrected runner must produce the final report directly and return exit code 0.

## Required method

- `MERGE_AWARE_V01`
- `Engine.time_scale = 1.0`
- one fresh trial per exact class, lowest-level representative
- full telemetry and action-log evidence
- one-trial failures remain `SCREENING_FAILURE_NEEDS_CONFIRMATION`
- no `HIGH_RISK_SOLVER_FAILURE` without exact-class 0/5 evidence

## Frozen paths

Do not edit `TASKS.md`, canonical Sunny Cove data, timers, objectives, VIP content, HUD, score/economy, progression, table, physics, colliders, M18, V04, V05, or the accepted V06 report. Use new `V06_R01` report names.

## Required checks and handoff

Run parse and direct execution checks for the corrected runner, inspect the generated report shape, verify frozen hashes and `git diff --check`, and write `CODEX_LOG_V06_R01_CHILD_03.md`. If any required check fails, stop with a truthful blocked log and do not execute Child 04.

Completion marker: `CHILD_03_REMEDIATION_COMPLETE_HANDOFF_TO_CHILD_04`.
