# CODEX Execution Log — BCM-M17 V06-R01 Remediation Master

This is the immutable remediation master-log template. CODEX must complete it only after Child 03 passes and Child 04 completes. CODEX must not edit root `TASKS.md`.

## Ordered remediation progress

| Child | Required handoff | Status | Commit/SHA | Scope |
| --- | --- | --- | --- | --- |
| 03 | `CODEX_LOG_V06_R01_CHILD_03.md` | PENDING | — | fresh corrected 45-class V06-R01 screen |
| 04 | `CODEX_LOG_V06_R01_CHILD_04.md` | BLOCKED UNTIL CHILD 03 PASS | — | regressions, report inspection, final handoff |

## Contract and scope

- Master prompt: `CHATGPT_REMEDIATION_PROMPT_V06_R01.md`
- Master criteria: `CHATGPT_AUDIT_CRITERIA_V06_R01.md`
- Child 03 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_03.md`
- Child 04 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_04.md` / `CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_04.md`
- V06 audit: `CHATGPT_AUDIT_V06.md`
- Frozen scope: no tracker, canonical data, timer, objective, VIP, HUD, score/economy, progression, table, physics, collider, M18, V04, V05, or accepted V06 changes.

## Final handoff requirements

Record exact commands/results, fresh V06-R01 report hashes, per-child SHAs/URLs, frozen-data proof, regression results, final `HEAD`/`origin/main`/remote equality, and the exact marker:

`AWAITING_M17_AUDIT_V06_R01`
