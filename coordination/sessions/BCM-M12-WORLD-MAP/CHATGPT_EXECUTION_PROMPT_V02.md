# BCM-M12-WORLD-MAP — Execution Prompt V02

Remediate M12 using:

`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V02.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_V01.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V01.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_V02.md
- coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V01.md

Owner runtime verdict:
- current card/list screen is NOT accepted as a World Map;
- World Map must be a genuine visual map with island destinations placed spatially;
- Sunny Cove must be the only initially open/selectable island;
- all other displayed island destinations must be visibly locked;
- selecting Sunny Cove currently throws an object-locked/free debugger error;
- startup shows unrelated historical R10 parse-error popups.

Fix only M12.

Required:
1. Replace list/card-primary presentation with a real visual island map.
2. Keep state/unlock ownership data-driven through LevelDatabase/CampaignManager.
3. Sunny Cove open/selectable, all other displayed destinations locked.
4. Fix refresh cleanup safely. Do not immediate-free locked UI nodes.
5. Verify repeated select/refresh is debugger-clean.
6. Investigate and safely isolate historical R10 probe parse-error noise from normal owner editor/runtime use without falsifying historical tests.
7. Keep 720x1280 portrait/mobile layout clean.
8. Add focused tests and GUI evidence.

Do not start Island Map, level buttons, timer, VIP, full content, or M13+ work.
Do not change accepted gameplay, physics, R11/M08/M09 behavior, scoring/rewards, gameplay HUD, canonical gameplay assets, or M11 persistence semantics.

Write:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V02.md`

Push remediation + tests + evidence + log, then return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
