# BCM-M08-TO-GO-DELIVERY-POLISH — Execution Prompt V02

Read:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V02.md

Owner runtime result:
- To-Go completion panel flash is visible and accepted.
- Merge feedback is not perceptible in normal play.
- Yellow To-Go delivery trail is not perceptible in normal play.
- No HUD/table/layout shift exists.

Implement visual-only remediation.

Do NOT slow gameplay, merge timing, physics, or delivery mechanics just to expose the effects.

Preserve the accepted completion flash as-is.

Tune only the transient visual effects so:
1. merge feedback is clearly noticeable at normal game speed but restrained;
2. To-Go trail is clearly noticeable at normal game speed but restrained;
3. effect nodes still self-clean and do not stack noisily.

Prefer alpha, thickness, scale, z-order, easing, and short afterglow persistence over gameplay timing changes.

Do not change physics, R11 table-edge behavior, rails, collider radii, scoring/combo/To-Go logic, HUD placement, canonical assets, persistence, Game Over, restart, audio, or haptics.

Write:
coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CODEX_LOG_V02.md

Push implementation + tests + evidence + log and return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
