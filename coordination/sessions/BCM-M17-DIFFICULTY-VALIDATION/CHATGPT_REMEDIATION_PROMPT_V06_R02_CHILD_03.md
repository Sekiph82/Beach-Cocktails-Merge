# BCM-M17 V06-R02 - Child 03 Remediation Prompt

## Scope

Correct only the V06-R01 screening runner's final integrity check, then run a fresh V06-R02 physical screen for all 45 exact challenge classes. The direct runner must produce the final report and return exit code 0.

## Required method

- `MERGE_AWARE_V01`
- `Engine.time_scale = 1.0`
- one fresh trial per exact class using deterministic recorded seeds
- established flat telemetry and full action-log evidence
- one-trial failures remain `SCREENING_FAILURE_NEEDS_CONFIRMATION`
- no `HIGH_RISK_SOLVER_FAILURE` without exact-class 0/5 evidence

The integrity check must validate the flat fields emitted by `m17_seeded_validation_harness.gd`; do not alter that harness or add a repair pass.

## Frozen paths

Do not edit `TASKS.md`, canonical Sunny Cove data, timers, objectives, VIP content/rewards, HUD, score/economy, progression, table, physics, colliders, M18, V04/V05/V06/V06-R01 evidence, or production code. Use new `V06_R02` report names.

## Required checks and handoff

Run parse and direct execution checks, inspect the report shape, verify frozen hashes and `git diff --check`, and write `CODEX_LOG_V06_R02_CHILD_03.md`. If any required check fails, stop and do not execute Child 04.

Completion marker: `CHILD_03_REMEDIATION_COMPLETE_HANDOFF_TO_CHILD_04_V06_R02`.
