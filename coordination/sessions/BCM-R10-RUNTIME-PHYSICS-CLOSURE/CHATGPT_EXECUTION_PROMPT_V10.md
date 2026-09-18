# BCM-R10-RUNTIME-PHYSICS-CLOSURE — Execution Prompt V10

Implement the remediation defined in:

`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V10.md`

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V07.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V07.md
- coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V10.md

Owner runtime V09 failed:
- rear/opposite-edge gap still visible;
- cocktails can visibly escape left/right accepted table boundaries.

Independent audit also found a bad visual-hull transform composition.

Mandatory order:
1. reproduce the owner failure using real production runtime physics;
2. fix exact Visual -> Sprite transform composition for the hull;
3. audit/fix segment selection / finite-segment containment so drinks cannot escape and rear contact is visually correct;
4. keep V05 rails frozen;
5. preserve circle drink-to-drink physics;
6. keep one authoritative containment solver for live motion + merge correction;
7. add pre/post failure evidence, stress tests, GUI capture, and full regression.

Do not bring back scalar V06-V08 edge widths as the primary model.

Write:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V08.md`

Push implementation + log and return:
- log URL
- implementation SHA
- regression result
- AWAITING_AUDIT

Then STOP.
