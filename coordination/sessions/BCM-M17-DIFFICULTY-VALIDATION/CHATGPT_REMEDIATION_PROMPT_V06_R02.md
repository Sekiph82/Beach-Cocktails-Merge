# BCM-M17 V06-R02 - Bounded Remediation Master Prompt

This remediation addresses only the V06-R01 Child 03 direct-runner integrity failure identified by `CHATGPT_AUDIT_V06_R01.md`.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06_R01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R02.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R02_CHILD_03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R02_CHILD_03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R02_CHILD_04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R02_CHILD_04.md`

## Exact bounded order

1. Correct the V06-R01 runner's final integrity validation to validate the established flat trial telemetry fields and class-level policy/time-scale metadata, then run a fresh V06-R02 45-class screen and publish Child 03 evidence.
2. Only if Child 03 returns direct PASS and satisfies all criteria, execute Child 04 regressions and publish its final handoff log.
3. Publish `CODEX_LOG_V06_R02.md` with both ordered child results and the final marker `AWAITING_M17_AUDIT_V06_R02`.

Do not treat Child 04 as accepted if Child 03 fails. Do not start M17-008 timer/objective tuning or M18.

## Frozen scope

Do not edit root `TASKS.md`, canonical Sunny Cove data, timers, normal objectives, VIP content/rewards, M15 HUD, score/economy, progression, table, physics, colliders, M18 files, V04/V05/V06/V06-R01 evidence, or the seeded validation harness. The only implementation change allowed is the bounded V06-R02 screening-runner integrity check. New evidence must use `V06_R02` names.

## Required correction

The runner must validate the actual flat trial schema emitted by `m17_seeded_validation_harness.gd` rather than requiring nested per-trial `telemetry` or a per-trial `engine_time_scale` field that the harness does not emit. Preserve the direct fresh physical screen, `MERGE_AWARE_V01`, `Engine.time_scale = 1.0`, one trial per class, full flat telemetry/action-log evidence, `0/25` forced and `25/25` surplus semantics, and the one-trial interpretation boundary. No repair-after-failure path is allowed.

## Stop conditions

Stop and publish a truthful blocked log if synchronization is not clean, any frozen hash changes, the direct runner returns FAIL, the report is not 100 levels/45 classes/45 trials, any required check fails, or scope expands. Never reset, clean, stash, rebase, force-push, or edit the tracker.

## Required outputs

- `M17_CANONICAL_SCREENING_V06_R02.json`
- `M17_CANONICAL_SCREENING_V06_R02.md`
- `CODEX_LOG_V06_R02_CHILD_03.md`
- `CODEX_LOG_V06_R02_CHILD_04.md`
- `CODEX_LOG_V06_R02.md`

Stop at `AWAITING_M17_AUDIT_V06_R02`.
