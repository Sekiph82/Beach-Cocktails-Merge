# BCM-M17 V06-R01 — Bounded Remediation Master Prompt

This remediation addresses only the V06 Child 03 stop-condition violation identified by `CHATGPT_AUDIT_V06.md`.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_03.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_04.md`

## Exact bounded order

1. Execute the corrected Child 03 remediation and publish `CODEX_LOG_V06_R01_CHILD_03.md`, fresh V06-R01 JSON/Markdown reports, and the corrected runner evidence.
2. Only if Child 03 passes all remediation criteria, execute the final regression/handoff child and publish `CODEX_LOG_V06_R01_CHILD_04.md`.
3. Publish `CODEX_LOG_V06_R01.md` with both child results and the final marker `AWAITING_M17_AUDIT_V06_R01`.

Do not treat Child 04 as accepted if Child 03 fails. Do not start any later milestone or M17-008 timer/objective tuning.

## Frozen scope

Do not edit root `TASKS.md`, canonical Sunny Cove data, timers, normal objectives, VIP content/rewards, M15 HUD, score/economy, progression, table, physics, colliders, M18 files, V04 evidence, V05 evidence, or the accepted V06 report. New remediation evidence must use V06-R01 names.

## Required correction

Run a fresh corrected physical screening for all 45 exact challenge classes at `MERGE_AWARE_V01` and `Engine.time_scale = 1.0`. The corrected runner must return PASS directly. Do not use a post-failure repair tool to convert a failing required run into a passing handoff. Preserve the one-trial sample-size boundary and classify a single-trial failure as confirmation evidence, never impossibility.

## Stop conditions

Stop and publish a truthful blocked log if synchronization is not clean, any frozen hash changes, any required check fails, the runner returns FAIL, the class count is not 45, time scale is not 1.0, or scope expands. Never reset, clean, stash, rebase, force-push, or edit the tracker.

## Required outputs

- `M17_CANONICAL_SCREENING_V06_R01.json`
- `M17_CANONICAL_SCREENING_V06_R01.md`
- `CODEX_LOG_V06_R01_CHILD_03.md`
- `CODEX_LOG_V06_R01_CHILD_04.md`
- `CODEX_LOG_V06_R01.md`

Stop at `AWAITING_M17_AUDIT_V06_R01`.
