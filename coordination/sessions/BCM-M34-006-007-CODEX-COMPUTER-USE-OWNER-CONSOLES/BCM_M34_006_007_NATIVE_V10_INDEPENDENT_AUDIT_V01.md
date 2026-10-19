# BCM-M34-006 / BCM-M34-007 — V10 Independent Audit V01

**Date:** 2026-10-19. **Auditor:** ChatGPT. **Audited GitHub main:** `09d5327ee1d59ec680078108fe5dcd69a2fa439c`. **Product/test implementation:** `35b46d9b6b8402a2e4bd43edcc2137d1e26ce984`. **Immutable builder log:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V10.md`. This file is historical audit evidence, never a live tracker; root `TASKS.md` remains the sole live status authority and only ChatGPT edits it.

## 1. VERDICT
**PASS for V10 SOURCE-LEVEL focused remediation; CONDITIONAL for reported Windows test execution; NOT A PASS for native monetization release.** The six timer-not-in-tree errors were caused by detached AdsService *test fixtures* and are source-corrected without touching production. Strict Godot diagnostic classification was added as opt-in without changing legacy exit-code semantics. The M21 full 100-level progression probe now respects a true isolated completed-tutorial fixture, and the builder reports an error-free 21/21 strict core plus a successful 100/100 M21 probe. Neither M34-006 nor M34-007 is complete; **146/148** remains.

## 2. CONTRACT RECOVERY
Preserve accepted Godot 4.7.x game, 20-Energy semantics, UTC Daily Rewards, NO TIMER gameplay ruling, owner assets and original user saves. Keep GitHub Actions unavailable, no Expo/Orbit/EAS, no unauthenticated Computer Use/browser bypass, no live ads/payments, Cloudflare deployment, or actual device installation. No cleanup, no XTool/BAT, IPA/APK or owner-untracked changes. Historical `OWNER_SAVE_STATE_UNKNOWN_NO_BASELINE` is still unresolved; lack of baseline does not prove damage or parity.

## 3. BRANCH / HEAD / DIFF SCOPE
Builder synchronized from `4e69258edcd55b3b695ead819b6856fe86298418` and committed test-only implementation `35b46d9b6b8402a2e4bd43edcc2137d1e26ce984`, followed by immutable V10 log `09d5327ee1d59ec680078108fe5dcd69a2fa439c`. Code paths: `tests/m34_economy_closure_probe.gd`, `tests/m34_daily_rewards_probe.gd`, `tests/m21_full_progression_probe.gd`, `tests/run_regressions.py`, `tests/test_run_regressions_discovery.py`. No production source/Worker/catalog/SDK was changed, and builder did not edit root `TASKS.md`. GitHub main matched builder final SHA at review.

## 4. ACCEPTANCE CRITERIA MATRIX
| Criterion | Independent status | Evidence scope |
|---|---|---|
| Detached AdsService timers in two M34 probes | **PASS SOURCE** | Both tests now `root.add_child(ADS_SCRIPT.new())` before timer-driven calls. Production AdsService unchanged. |
| Exact six prior timer diagnoses | **SOURCE-CONSISTENT, builder log only** | Reported `ads_service.gd:281` error stack and three occurrences per probe match fixture cause; original local JSON unavailable to reviewer. |
| Strict runtime-error flag and opt-in behavior | **PASS SOURCE** | Anchored `SCRIPT ERROR:`, `Parse Error:`, `ERROR:`; separate `exit_code_pass`, `strict_pass`, `runtime_errors`, preserved stack lines. |
| Discovery/strict classifier unit tests | **BUILDER PASS 5/5** | Two new Python tests added; no independent Python run. |
| Isolation refusal | **BUILDER PASS 1/1** | Separate synthetic profile; no real owner save accessed by builder claim. |
| M34 targeted strict probes | **BUILDER PASS 5/5** | Zero classified Godot runtime errors, actual local process evidence reported. |
| Full default core `--strict-runtime-errors` | **BUILDER PASS 21/21 ERROR-FREE** | Zero classified errors as reported; non-fatal warnings are not strict failures. No independent Windows Godot run. |
| M21 100-level tutorial-aware full progression | **BUILDER PASS 4/4 (incl runner overhead)** | Probe 100/100, five SaveManager checkpoints at L1/L25/L50/L75/L100, 300 cumulative stars, Tiki unlocked + L1 launchable, 111.2 s; source tutorial fixture/readiness asserted. |
| Full historical `--all` regressions | **UNVERIFIED/NOT RERUN** | Four other prior 100-level timeouts and GUI/harness categories not verified by V10. |
| Native rewarded ads + real receipt/payment/store | **BLOCKED** | No SDK SSV forwarding on physical device, production identity, UMP/ATT, live SSV/Cloudflare, StoreKit/Play end-to-end. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH
V10 execution log accurately describes test-only code, all commands, fixed timer fixture boundary, and owner-save preservation claim. Diff confirms `AdsService` is attached before `show_rewarded` and `daily.claim`, with no production modification. `tests/run_regressions.py` strict verdict checks actual anchored Godot output, not arbitrary word “error”; default remains exit-code mode. `tests/m21_full_progression_probe.gd` asserts tutorial `completed`, invisible and step >=5 in the isolated profile, and checks result action visibility. All PASS counts are **builder reports**, not independently rerun.

## 6. FILE / SYMBOL EVIDENCE
- `tests/m34_economy_closure_probe.gd::_new_ads_service` & `tests/m34_daily_rewards_probe.gd::_new_ads_service`: add test-owned services to `root`.
- `tests/run_regressions.py::classify_godot_runtime_errors`: anchored Godot diagnostic collection/stack preservation.
- `tests/run_regressions.py::probe_verdict`, `--strict-runtime-errors`: separate legacy exit result and strict result.
- `tests/test_run_regressions_discovery.py`: synthetic classifier/opt-in strict contract.
- `tests/m21_full_progression_probe.gd::_mount_fresh_shell`: asserts actual completed test tutorial; `_complete_level` validates result overlay + action before trigger.
- `scripts/campaign/campaign_navigation_controller.gd::_present_pending_terminal_result`: original tutorial gate preserved, no production changes.

## 7. FOCUSED TEST EVIDENCE
Codex reports: discovery **5/5**, isolation **1/1**, targeted M34 **5/5 strict**, M21 **4/4 strict**, core **21/21 strict**, `git diff --check` PASS. M21 111,203ms and five checkpoint reloads confirmed only in builder report. Earlier V09 38.16 seconds was a failed fixture run, not an accepted baseline performance target.

## 8. REGRESSION EVIDENCE
The previously demonstrated timer errors are resolved in test fixture source, and builder's targeted/strict core has zero classified errors. One representative M21 100-level proof is now reported PASS with tutorial and island-map assertions. Previous V08 broad `--all` **113/121** and four other extended test cases were not rerun; do not falsely replace that history with a global all-probes PASS. No source change to previously accepted gameplay.

## 9. SECURITY / SAFETY REVIEW
Owner data remains off limits; no user `campaign_save.json` inspection requested or performed. All builder Godot tests reportedly used per-run project sandbox profiles; retained test data and original tracked report restoration were logged. Strict classifier only catches anchored Godot ERROR families, not warning classes, process signals hidden by shell or every possible engine failure; do not treat it as device-runtime attestation. Ads and billing stay fail closed.

## 10. ARCHITECTURE CONSISTENCY
Native Godot game unchanged. Existing AdMob/plugin binaries, signed debug Android APK evidence, Node/SQLite synthetic Worker/D1 interface and test-only Play Billing remain separate from live provider authorization. No StoreKit-compatible iOS bridge or physical SDK proof exists.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS
Builder correctly refrained from editing `TASKS.md` or claiming release acceptance. Coordinator should update root `TASKS.md` to V10's verified source advances, remove stale six-timer and M21 failure as *current* blockers, and list genuine remaining native/backend/store and owner gates. Progress stays 146/148.

## 12. FINAL REPOSITORY STATE
Audited source GitHub main `09d5327ee1d59ec680078108fe5dcd69a2fa439c`. This audit/tracker/next engineering prompt commits will advance main without modifying V10 production.

## 13. OPEN CROSS-MILESTONE FINDINGS
Earlier broad suite 113/121 and four never-retried long probes still historical incomplete coverage. Owner historical campaign save integrity unknown, not proof of damage. No automatic cleanup, test regeneration of tracked evidence or silent owner-profile access allowed.

## 14. DEFECTS BY SEVERITY
- **V10 local test blockers:** NONE CONFIRMED in the audited diff. Strict core builder PASS.
- **MAJOR/RELEASE:** AdMob native SDK user-ID/nonce SSV forwarding and physical runtime UNVERIFIED.
- **MAJOR/RELEASE:** Trusted production player identity, consent/age/UMP/ATT and deployed Cloudflare Worker/D1/live Google SSV absent.
- **MAJOR/RELEASE:** Worker store `/v1/store/verify` & restore still 503, authentic Apple/Play purchase verification and compatible StoreKit binary missing.
- **NOTE:** Broad `--all` historical incomplete; owner-save earlier event not reconstructable without baseline.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES
Avoid further circular probe-only iterations. Safely implement the **remaining technical store verification backend** as disabled-by-default, testable provider adapters and ledger, separated from owner account activation; keep all catalog items non-buyable. Require proper owner decisions for any cloud deployment or live store transaction. No repeat huge `--all` or APK build without actual code change.

## 16. UNVERIFIED ITEMS
Local Windows test outputs independently, real Android/iOS SDK forwarding and device behavior, AdMob live signed callback and approval, owner age/privacy, identity issuer, D1 deployed keys, actual Google Play/Apple App Store purchase validation, StoreKit native compile, refunds/restore/consumption on provider, device release signing, owner historical save.

## 17. REGRESSION RISK
**LOW-to-MEDIUM for audited test-only source diff**, **HIGH for full commercial feature launch**.

## 18. AUDIT CONFIDENCE
**HIGH** in source-level changes, **MEDIUM** in builder-reported local tests, **LOW** in commercial/device/account readiness.

## 19. FINAL VERDICT
**V10 technical remediation: SOURCE PASS / LOCAL RUN CONDITIONAL. M34-006/007 release: BLOCKED. Tracker: 146/148 (98.6%).** Do not equate passing synthetic tests with live native acceptance.

## 20. REQUIRED REMEDIATION
No more arbitrary legacy test loops. Next useful Codex scope: implement a **disabled-by-default, provider-verifiable store backend and trusted ledger with adversarial tests**, under the existing M34-007 task; still require owner-approved catalog and authorized real credentials/devices for activation. M34-006 live SDK/account steps remain genuinely gated by owner and native device. Preserve all existing tests/records and security boundaries. Codex must not edit TASKS.md.
