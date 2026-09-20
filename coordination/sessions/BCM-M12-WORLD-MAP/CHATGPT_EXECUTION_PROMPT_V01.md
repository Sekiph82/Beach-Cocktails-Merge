# BCM-M12-WORLD-MAP — Execution Prompt V01

Implement M12 under:

`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V02.md
- coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V01.md

Build only the reusable data-driven World Map:
- WorldMapScene/controller
- island entry/card component
- OPEN / LOCKED / CURRENT / COMPLETE states
- Sunny Cove open / Tiki locked from campaign state
- locked reason/progress feedback
- island-selection navigation boundary for future Island Map
- portrait/mobile-safe layout
- focused tests + 720x1280 GUI evidence

Do not hardcode unlock logic in the UI. Read state from LevelDatabase/CampaignManager.

Do not implement Island Map, level buttons, gameplay timer, VIP runtime, full 100-level data, or M13+ work.

Do not change accepted gameplay, physics, R11/M08/M09 behavior, scoring/rewards, existing HUD, canonical gameplay assets, or persistence semantics.

Write:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V01.md`

Push implementation + tests + evidence + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
