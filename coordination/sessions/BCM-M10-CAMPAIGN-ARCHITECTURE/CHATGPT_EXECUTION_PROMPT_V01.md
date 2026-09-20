# BCM-M10-CAMPAIGN-ARCHITECTURE — Execution Prompt V01

Implement M10 under:

`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md
- docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md
- coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-R11-TABLE-EDGE-CLOSURE/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V01.md

Build only the campaign architecture/data foundation:
- CampaignManager
- LevelDatabase
- SaveManager API/schema boundary
- GameEconomy
- GameplaySessionBridge
- canonical islands/level seed JSON
- deterministic validation
- focused tests/docs

Do not implement World Map/Island Map UI, gameplay timer, live save migration, VIP UI/runtime, boosters, full 100-level Sunny Cove content, or M11+ features.

Do not modify accepted core gameplay, R11 table-edge behavior, M08/M09 visuals/feedback, HUD, scoring, rewards, physics, or canonical assets.

Avoid project.godot autoload edits if they risk the owner's pre-existing dirty project.godot; modules may be instantiated directly for M10.

Write:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CODEX_LOG_V01.md`

Push implementation + tests + seed data + docs + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
