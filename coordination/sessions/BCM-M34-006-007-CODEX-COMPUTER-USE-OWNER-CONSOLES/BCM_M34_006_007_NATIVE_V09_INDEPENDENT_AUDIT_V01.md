# BCM-M34-006 / BCM-M34-007 — V09 Independent Audit V01

**Date:** 2026-10-19. **Auditor:** ChatGPT. **GitHub source HEAD inspected:** `f800e83e3076688db67f2b174f93c9f244da208e`. **Builder implementation:** `dadfd1477699cbb0b7e40f04fb7ff2d7d33b36bd`. **Builder evidence:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V09.md`. Historical evidence; root `TASKS.md` remains sole live tracker, edited only by ChatGPT.

## 1. VERDICT
**CONDITIONAL source-level PASS for V09 bounded legacy triage and corrected M26 display classification, NOT broad-suite or M34 acceptance.** M26 real GUI captures and M27 headless unlock target passed as builder-reported. One 100-level M21 probe completed its loop in 38.16 seconds but **failed** its acceptance due to a tutorial-timing test setup incompatibility. **Additional MAJOR:** core 21/21 means subprocess exit codes were zero; the builder also reports three Godot timer-not-in-scene-tree runtime errors in **each** of M34 economy and M34 daily reward probes (six errors). That is **not clean regression acceptance** despite green exit codes. M34-006 and M34-007 remain blocked; 146/148 unchanged.

## 2. CONTRACT RECOVERY
Godot 4.7.x, approved gameplay/economy, no timers in gameplay, no gameplay physics tuning. Preserve real owner `user://campaign_save.json`, historical IPA/APK, XTool/BAT, untracked files and stashes. NO GitHub Actions (unavailable), Expo/Orbit/EAS, unsafe Computer Use/browser, cloud deployments, live rewarded ads, production billing or device installations without explicit owner permission.

## 3. BRANCH / HEAD / DIFF SCOPE
Builder synced from `c535fce45e0cd8f6d22f5037650a89a7fbbe65e4`, committed `dadfd1477699cbb0b7e40f04fb7ff2d7d33b36bd` (exactly three test-only paths: `tests/run_regressions.py`, `tests/test_run_regressions_discovery.py`, `tests/m21_full_progression_probe.gd`) and log `f800e83e3076688db67f2b174f93c9f244da208e`. GitHub main matched final logged SHA on review; root `TASKS.md` unchanged by builder. No production changes.

## 4. ACCEPTANCE CRITERIA MATRIX
| Criterion | Verdict | Grounding |
|---|---|---|
| M26 GUI capture correct category | **PASS SOURCE** | Added to `NEEDS_DISPLAY`, removed from `ALL_HEADLESS_PROBES`; discovery assertions validate source GL requirement. |
| Discovery contract | **BUILDER PASS 3/3** | 117 headless, 18 display, remaining special categories disjoint and fail-closed; reviewer examined changes. |
| Sandbox refusal | **BUILDER PASS 1/1** | No owner save touched by reported V09, synthetic profile retained. |
| M26 GUI actual PNG capture, M27 targeted headless | **BUILDER PASS 5/5** | Four PNG dimensions/bytes and M27 semantic tests in log; reviewer has no bytes for independent image inspection. |
| Default core Godot | **EXIT-CODE PASS 21/21 WITH RUNTIME ERRORS** | Six timer-not-in-scene-tree errors from two M34 probes reported; cannot call error-free. |
| M21 100-level proof | **FAIL** | Completed loop 38.16 s in profiling, but first-level result action attempted while tutorial still prevented overlay; later assertions cascade. |
| Other four 100-level probes | **UNVERIFIED** | Not re-run after V08 timeouts, which remain historical, not independently confirmed hangs. |
| Worker/backend/native commerce | **NO NEW EVIDENCE** | V09 only test harness work; earlier Node/SQLite synthetic E2E and test-only Billing/AdMob remain; live native SDK bridge, consent, identity, deployment, transactions unverified. |
| Owner real save historical integrity | **UNKNOWN_NO_BASELINE** | No before-hash for earlier event; V09 reports no owner save accessed. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH
Builder correctly states M21 acceptance FAIL despite 100 levels completing, and reports timer errors despite green 21/21 counts. Source inspection confirms `CampaignNavigationController::_present_pending_terminal_result` defers terminal result overlay while visible tutorial is before step 5; `tests/m21_full_progression_probe.gd::_complete_level` calls `get_result_feedback_overlay().trigger_action("ISLAND_MAP")` immediately after simulated orders, without proving tutorial completion. Thus failure is consistent with fixture/tutorial timing. Neither the runtime errors nor exact capture bytes can be reproduced by this remote source auditor. Do NOT claim a product failure from the M21 fixture alone, and do NOT claim clean core test acceptance.

## 6. FILE / SYMBOL EVIDENCE
- `tests/run_regressions.py`: display category includes M26 capture; `run()` marks probe PASS when `proc.returncode==0` only, while `error_lines` still gathers `SCRIPT ERROR`, `Parse Error`, or `ERROR` lines. **Important:** `error_lines` are currently diagnostic only, not a failing condition; zero-exit "PASS" can mask Godot runtime errors.
- `tests/test_run_regressions_discovery.py`: third unit checks M26 display classification and GL framebuffer usage.
- `tests/m21_full_progression_probe.gd`: new optional `BCM_PROFILE_PROGRESS=1` logging, actual 100-level loop and result overlay trigger.
- `scripts/campaign/campaign_navigation_controller.gd::_present_pending_terminal_result`: properly waits for tutorial step >=5, so test must drive or seed a completed tutorial using **isolated synthetic fixture** instead of weakening production gate.
- `tests/m34_economy_closure_probe.gd` and `tests/m34_daily_rewards_probe.gd`: builder reported three timer-not-in-scene-tree errors each; exact Godot stack/line evidence currently remains only in ignored local `.godot/m34_v09_core.json`, not the GitHub builder log.
- `tests/m26_002_campaign_unlock_presentation_probe.gd`: source explicitly requires actual framebuffer PNGs.
- `tests/m27_002_campaign_unlock_probe.gd`: skips headless screenshot only; targeted semantic/particle checks passed as builder reported.

## 7. FOCUSED TEST EVIDENCE
Builder reports discovery 3/3, isolation 1/1, M26/M27 targeted 5/5, Godot core 21/21 subprocess exits 0 **but** six timer errors, M21 profiled 100 levels in 38.16 s then exit 1. `git diff --check` PASS. V09 did **not** rerun full broad `--all`, Worker tests, node E2E, APK or physical device.

## 8. REGRESSION EVIDENCE
Previously misclassified M26 capture source fixed; M27 broad flake did not reproduce alone, root contention not proven. One of five previously timed-out full progression probes was **not stuck** and completed 100 levels in ~38s under sequential isolated profiling, but failed tutorial-acceptance. Other four remain unverified. In M34 core, unhandled timer errors despite exit-0 are a new **audit finding**, which may be historic rather than introduced by V09 since V09 changed no production code; baseline origin must be measured rather than guessed.

## 9. SECURITY / SAFETY REVIEW
Reported owner save not read/hashed/written; test `.godot/bcm_sandboxes` profiles retained. Untracked new GUI PNG preserved; tracked test-generated reports restored against pre-run HEAD as reported. No destructive cleanup. Browser safety and no cloud deployment unchanged. Next tests must not use real save or global Godot profile. The UI/gameplay tutorial gate must never be bypassed in production to make a test pass.

## 10. ARCHITECTURE CONSISTENCY
Godot game, Worker local synthetic Node/SQLite, debug-only AdMob and Play Billing remain separate. M26 GUI change is test categorization only. A 100-level test completing in 38s does not prove any hardware device performance target.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS
Builder did not edit `TASKS.md`; coordinator must replace stale V08 status with V09 triage results and note masked runtime errors. Keep existing 146/148 task completion ratio.

## 12. FINAL REPOSITORY STATE
Observed main `f800e83e3076688db67f2b174f93c9f244da208e` at audit. This report/prompt/tracker commits follow audited SHA and do not mutate production.

## 13. OPEN CROSS-MILESTONE FINDINGS
M21 core 100-level *tutorial-aware* proof still failed and four other extended probes are not accepted. M34 economy and daily tests report real runtime errors. Historical owner save unknown. Native monetization release gates remain separate.

## 14. DEFECTS BY SEVERITY
- **MAJOR TEST HARNESS:** `run_regressions.py::run` uses exit=0 as sole PASS; six `timer-not-in-scene-tree` Godot errors in core M34 probes are not reflected in its verdict.
- **MAJOR LEGACY ACCEPTANCE:** M21 100-level completion is not a clean test due to missing tutorial readiness at first-level result action.
- **MINOR/UNVERIFIED:** Four formerly timed-out progression probes and M27 concurrent broad-run behavior not rechecked.
- **RELEASE BLOCKERS:** Native Android/iOS AdMob SSV bridge propagation, real identity+consent/deployed Worker, mobile device acceptance, StoreKit and Play real payment verification.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES
Add **opt-in strict runtime-error gate** to local runner, with exact allowed benign message classifications if validated, never globally hide Godot `SCRIPT ERROR`/internal Godot `ERROR`. Capture bounded stack traces/line context. Correct tutorial fixture via completed synthetic tutorial or driving required steps in test without changing production navigation. Rerun only affected probes first, then core strict, without another `--all` full rerun. Retain 117/18 discovery classification and owner save guard.

## 16. UNVERIFIED ITEMS
Exact Godot timer stack traces on Windows; whether errors predate V09; independent PNG contents; other four 100-level probes; real AdMob native SSV options, Google signed callback, D1 backend, UMP/ATT/age/identity, iOS/StoreKit and real Play purchase/refund/restore/device test, historical owner save parity.

## 17. REGRESSION RISK
**MEDIUM** in local test harness/legacy acceptance, **HIGH** for unverified commercial features.

## 18. AUDIT CONFIDENCE
**HIGH** in source-level M26 classification, runner error-line PASS gap, M21 tutorial gating; **MEDIUM** in builder-reported local tests; **LOW** for device, store, real save historical integrity.

## 19. FINAL VERDICT
**V09 source remediation: CONDITIONAL PASS. Core subprocess suite: 21/21 exits 0 but not error-free. M21 100-level acceptance: FAIL. M34-006/007 remain BLOCKED, 146/148 unchanged.**

## 20. REQUIRED REMEDIATION
Single coherent next Codex batch: 1) obtain isolated local Godot error lines for two M34 probes, fix underlying **test lifecycle or true runtime** cause without suppressing errors; 2) introduce rigorous but scoped error-aware regression reporting (no blanket false green); 3) make one M21 full-progression probe tutorial-aware via synthetic isolated initialization or legitimate scripted tutorial completion; run targeted only and isolated strict core; 4) keep native commerce hard gates documented, no repeated broad sweeps or unnecessary APK builds. No owner save access, Actions/Computer Use, live ads/payments/deployments. GitHub source/log and TASKS ownership rules unchanged.
