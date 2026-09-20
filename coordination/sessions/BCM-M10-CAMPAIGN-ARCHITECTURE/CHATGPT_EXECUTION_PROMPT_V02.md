# BCM-M10-CAMPAIGN-ARCHITECTURE — Execution Prompt V02

Remediate M10 using:

`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V02.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V01.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V02.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CODEX_LOG_V01.md

Fix only these three audit blockers:

1. Validate island unlock_rule references/types, including unresolved island ids and invalid required completion levels.
2. Make FULL level-count validation iterate every declared island, including islands with zero loaded rows.
3. Make GameplaySessionBridge level definitions deeply immutable, not merely top-level read-only.

Add focused tests that would fail the V01 implementation for all three issues.

Do not change gameplay, R11/M08/M09 behavior, scoring/rewards, HUD, canonical assets, project.godot, or start World Map/Island Map/timer/live-save/full-content work.

Run focused M10 plus active M01-M09 regressions.

Write:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CODEX_LOG_V02.md`

Push remediation + tests + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
