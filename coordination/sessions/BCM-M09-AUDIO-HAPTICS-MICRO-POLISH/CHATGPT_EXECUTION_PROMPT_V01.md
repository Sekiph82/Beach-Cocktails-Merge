# BCM-M09-AUDIO-HAPTICS-MICRO-POLISH — Execution Prompt V01

Implement M09 under:

`coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-R11-TABLE-EDGE-CLOSURE/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md

Owner-directed runtime change:
- first To-Go target must be L5;
- second must be L6;
- third must be L7;
- then resume the existing normal target-selection behavior.

Preserve the existing reward table exactly. Do not invent an L5 reward.

Also implement bounded M09 audio/haptic hooks and micro-polish according to the locked criteria.

Preserve:
- accepted M08 merge feedback;
- accepted M08 completion flash;
- current yellow delivery trail;
- all physics;
- R11 table-edge behavior;
- rails;
- collider radii;
- scoring/combo math;
- HUD placement;
- canonical visual assets;
- persistence/Game Over/restart.

Do not start campaign/M10 architecture.

Add focused tests, run active regressions, and write:

`coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CODEX_LOG_V01.md`

Push implementation + tests + evidence + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
