# BCM-M08-TO-GO-DELIVERY-POLISH — Execution Prompt V01

Implement M08 under:

`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-R11-TABLE-EDGE-CLOSURE/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md

Implement only bounded visual polish:
1. restrained To-Go delivery animation;
2. short order-completion feedback;
3. short merge feedback;
4. lightweight cleanup-safe effects.

Do not change accepted physics, R11 table-edge behavior, rails, collider radii, scoring/combo/reward math, To-Go eligibility/storage rules, HUD placement, canonical assets, rapid-launch, persistence, Game Over or restart.

Prefer existing assets/tweens/procedural effects. Do not start M09 audio/haptics.

Add focused tests and normal 720x1280 GUI evidence, run active regressions, and write:

`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CODEX_LOG_V01.md`

Push implementation + tests + evidence + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
