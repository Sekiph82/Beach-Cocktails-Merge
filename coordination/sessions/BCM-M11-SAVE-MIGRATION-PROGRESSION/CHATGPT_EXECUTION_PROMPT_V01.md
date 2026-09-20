# BCM-M11-SAVE-MIGRATION-PROGRESSION — Execution Prompt V01

Implement M11 under:

`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V02.md
- coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_CRITERIA_V01.md

Implement only:
- real campaign SaveManager persistence;
- backup/recovery behavior;
- schema migration path;
- idempotent legacy best-score migration from user://save.cfg;
- CampaignManager progression/unlock/replay/next-island core;
- persistence integration tests/docs.

Use isolated test save paths so the owner's actual user:// saves are never mutated by tests.

Do not change accepted gameplay, physics, R11/M08/M09 behavior, scoring/rewards, HUD, canonical assets, or start World Map/Island Map/timer/VIP/full-content work.

Write:
`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CODEX_LOG_V01.md`

Push implementation + tests + docs + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
