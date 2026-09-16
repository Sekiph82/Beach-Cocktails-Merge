# BCM-M03 Reward Values Remediation V01 — Independent Re-Audit

## 1. VERDICT

**PASS**

The owner-approved To-Go rewards `L6=1000` and `L7=1800` were applied exactly. L8-L12 rewards remained unchanged. The remediation is bounded, regression-backed, and does not begin M04/V7 work.

## 2. CONTRACT RECOVERY

Authoritative remediation contract:
- apply only owner-approved `L6=1000`, `L7=1800`;
- preserve L8-L12 rewards;
- update deterministic M03 expectations;
- rerun M01, M02, M03 probes and Godot import/startup checks;
- do not edit `TASKS.md`;
- do not start M04 or V7 integration.

## 3. BRANCH / HEAD / DIFF SCOPE

Remote implementation commit audited: `6f7313cfd42eb333a879e990badc3125ed36a6ec` (`Apply approved M03 To-Go reward values`).

Compared against remediation-work-order base `942ff9a2a08759b4072893bc874e50c67acd3397`.

Changed paths are exactly:
- `data/drinks.json`
- `tests/m03_economy_regression.gd`
- `docs/codex-logs/BCM-M03_REWARD_VALUES_REMEDIATION_V01_CODEX_LOG.md`

No `TASKS.md`, production physics, visual asset, scene, UI, M04, or V7 path is in the diff.

## 4. ACCEPTANCE CRITERIA MATRIX

- L6 reward = 1000: **PASS**
- L7 reward = 1800: **PASS**
- L8 = 3000 unchanged: **PASS**
- L9 = 5000 unchanged: **PASS**
- L10 = 8000 unchanged: **PASS**
- L11 = 12000 unchanged: **PASS**
- L12 = 18000 unchanged: **PASS**
- immediate-order payout L6-L12: **PASS**
- stored-order payout L6-L12, To-Go only: **PASS**
- one stored matching drink consumed: **PASS**
- L12 stored/future-order behavior: **PASS**
- duplicate merge/order payout protection: **PASS**
- merge score table L2-L12: **PASS**
- combo x1-x6+ and timeout: **PASS**
- persistence / corrupt-save fallback: **PASS**
- danger-line timing: **PASS**
- Game Over / restart: **PASS**
- M01 regression: **PASS**
- M02 regression: **PASS**
- Godot import/parse: **PASS**
- Godot configured main-scene startup: **PASS**
- `TASKS.md` unchanged by Codex: **PASS**
- M04/V7 not started: **PASS**

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

GitHub diff independently confirms the production data change is limited to the two approved `order_reward` values. The deterministic probe was expanded rather than replacing production logic. The Codex log reports the full approved table and exact payout observations for both immediate and stored fulfillment.

## 6. FILE / SYMBOL EVIDENCE

`data/drinks.json` now defines:
- L6 `order_reward = 1000`
- L7 `order_reward = 1800`
- L8 `3000`
- L9 `5000`
- L10 `8000`
- L11 `12000`
- L12 `18000`

The log records exact immediate totals, including L6 `350 + 1000 = 1350` and L7 `600 + 1800 = 2400`, plus stored-delivery totals where only the To-Go reward is paid.

## 7. FOCUSED TEST EVIDENCE

`M03_PROBE_RESULT=PASS`, process exit code `0`.

The probe covers the complete L6-L12 reward table, immediate fulfillment, stored fulfillment, one-time payout, multiple stored matches, L12 retention, duplicate payout protection, score/combo, persistence, danger line, Game Over, and restart.

## 8. REGRESSION EVIDENCE

- `M01_PROBE_RESULT=PASS`, exit code `0`.
- `M02_PROBE_RESULT=PASS`, exit code `0`.
- Godot import exit code `0`.
- Main-scene startup exit code `0`.

## 9. SECURITY / SAFETY REVIEW

No secrets, saves, `.godot` cache, build/export output, or machine-specific artifacts were added. No destructive Git operation is reported.

## 10. ARCHITECTURE CONSISTENCY

Reward values remain canonical data in `data/drinks.json`. Tests consume production scene/classes rather than duplicating game rules into a parallel implementation.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

Codex did not edit `TASKS.md`. The log correctly identifies itself as builder evidence and does not self-approve the milestone.

## 12. FINAL REPOSITORY STATE

GitHub `main` contains the remediation commit and immutable log. The previously open owner-decision blocker for L6/L7 reward values is resolved.

## 13. OPEN CROSS-MILESTONE FINDINGS

Final collider-to-V7-sprite footprint alignment remains intentionally deferred to M05. Native-device/export and owner-native visual acceptance remain future milestone work.

## 14. DEFECTS BY SEVERITY

- BLOCKER: none.
- MAJOR: none.
- MINOR: none blocking M03 closure.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

Keep M03 economy regression as a permanent regression suite through later visual integration and release milestones.

## 16. UNVERIFIED ITEMS

Native mobile hardware behavior and release export are outside M03 scope.

## 17. REGRESSION RISK

Low. Production change is two data values, with M01/M02/M03 regression coverage all passing.

## 18. AUDIT CONFIDENCE

High.

## 19. FINAL VERDICT

**PASS — BCM-M03-001 is accepted and M03 may close.**

M04 asset validation may begin after ChatGPT advances the canonical tracker.
