# BCM-M34-006 / BCM-M34-007 — V07 Independent Audit V01
**Date:** 2026-10-19. **Auditor:** ChatGPT, independent source review of GitHub `main=a9a318d55fc37962d5263af859ae0e29e4d976df`, implementation `ce016bc58592af799559ada075c8f0de7394cb62`. **Builder evidence:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V07.md`. This is historical evidence; root `TASKS.md` alone is authoritative live status, and Codex must never edit it.

## 1. VERDICT
**CONDITIONAL acceptance of substantive V07 source advances, with one source-confirmed **MAJOR** regression in the `--all` test discovery pathway.** The fail-closed isolated test guard and genuine local synthetic-SSV→HTTP→Worker/SQLite→Godot/SaveManager→ACK harness exist in source. M34-006/007 remain BLOCKED and progress remains 146/148. The owner save incident remains UNKNOWN (no historical before-hash); no owner save accessed during reported V07.

## 2. CONTRACT RECOVERY
Godot 4.7.x, approved gameplay/energy and Daily Rewards, no Expo/Orbit, no GitHub Actions, no cloud deploy, browser Computer Use stopped at official-URL safety barrier, historical XTool/BAT and IPA/APK unchanged, no destructive cleanup, owner personal `user://campaign_save.json` is strictly off limits without separate explicit approval. Codex only edits source and immutable builder logs; ChatGPT alone writes root `TASKS.md`.

## 3. BRANCH / HEAD / DIFF SCOPE
Builder started from `05b63ad002a125bbb263d30cb235b18535e52b65`, implemented `ce016bc58592af799559ada075c8f0de7394cb62`, logged `a9a318d55fc37962d5263af859ae0e29e4d976df`; inspected `main` matched builder end SHA. 67 changed implementation paths, including 51 save-aware SceneTree probes, sandbox guard/base, Python test runner, direct PowerShell launcher, historical M27 safety gate, Node SQLite Worker and Godot HTTP E2E test harness, M33 owner playtest and Android build scripts. No builder `TASKS.md` modification in inspected commits.

## 4. ACCEPTANCE CRITERIA MATRIX
| Criterion | Status | Source evidence / limitation |
|---|---|---|
| Fail-closed guard before save-aware test startup | **PASS SOURCE** | `tests/support/test_sandbox_guard.gd` checks exact markers, project sandbox, isolated APPDATA/LOCALAPPDATA, real Godot `user://` mapping; affected `_init()` probes now invoke it before deferred `_run`. |
| Unsandboxed invocation refusal | **BUILDER PASS + SOURCE** | Separate unmarked negative profile, exit 70 expected, save absent. No owner path tested. |
| Unique project-scoped test data & preservation | **PASS SOURCE** | `tests/run_regressions.py` uses `.godot/bcm_sandboxes`, unique `mkdtemp`, isolated env; retains test data without deletion. |
| Real owner save untouched in V07 | **BUILDER REPORTED; HISTORICAL UNKNOWN** | No independent Windows access; missing preincident baseline prevents retroactive parity proof. |
| Local synthetic ECDSA SSV → Node SQLite → Worker HTTP → actual Godot HTTP → SaveManager → ACK → new process deduplication | **PASS SOURCE DESIGN / BUILDER PASS** | `tests/m34_worker_sqlite_godot_e2e.mjs` + `..._probe.gd`; in-memory SQLite and TEST-ONLY signature/key, NOT deployed Cloudflare/Google. |
| Full core Godot 21/21, Worker 20/20, check-only 56/56, isolation 1/1 | **BUILDER REPORTED PASS** | Reviewed harnesses; not independently executed. `--check-only` not runtime validation. |
| `python tests/run_regressions.py --all` runnable-headless suite | **FAIL, deterministic source incompatibility** | Newly added negative-only probe and E2E external-harness script, plus support SceneTree helper, are discovered as ordinary runnable scripts; source selection omits needed exclusions. |
| Real native AdMob SSV options reached loaded Android/iOS rewarded ad | **UNVERIFIED** | `LoadAdRequest` serializes fields, installed AAR bridge is opaque; no device. |
| Production identity, policy/consent, Worker D1, App Store/Play billing | **BLOCKED** | No production provider/consent/deployment, verified store purchase, StoreKit iOS SDK/build or physical device acceptance. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH
Builder statements 1/1, 21/21, 20/20, 56/56 and offline E2E are test execution claims, not independently reproduced. Source inspection confirms guard, runner env, harness, M27 owner-data refusal, and `TASKS.md` untouched by builder. Source itself shows `--all` is not protected against non-runnable and negative-only SceneTree files. Neither the builder log nor this auditor ran `--all`. Do not call it a measured failed test; it is a **source-proven expected failure** on that mode.

## 6. FILE / SYMBOL EVIDENCE
- `tests/support/test_sandbox_guard.gd::validate,enforce`: verifies `BCM_TEST_MODE`, `BCM_TEST_BUILD_MARKER`, `BCM_TEST_SANDBOX_ROOT` and resolved user-data directory.
- `tests/support/isolated_test_scene_tree.gd::_init`: only enforces guard; no ordinary test body/quit.
- `tests/run_regressions.py::main` `elif args.all:`: discovers `*.gd` if source header contains `extends SceneTree` **or** `isolated_test_scene_tree.gd`, excludes only NEEDS_DISPLAY and NEEDS_HARNESS. Does **not** exclude `tests/support`, the special negative probe, or the Node-orchestrated E2E probe.
- `tests/m34_sandbox_guard_negative_probe.gd`: uses `extends SceneTree`; its *success* is when markers **are missing**. With `run()` setting valid markers for every ordinary `--all` probe, `validate()` succeeds, so this negative probe deliberately returns exit **1**. Thus `--all` cannot be green as currently selected.
- `tests/m34_worker_sqlite_godot_e2e_probe.gd`: `extends "res://tests/support/isolated_test_scene_tree.gd"`, requires `BCM_E2E_WORKER_ENDPOINT`, `BCM_E2E_AUTH_TOKEN`, `BCM_E2E_USER_ID` and a Node local server; `--all` would invoke it without that harness, so it also must be excluded/handled by explicit launcher.
- `tests/support/isolated_test_scene_tree.gd`: extends SceneTree, discovered as an ordinary probe, has no `quit()` and can hang until timeout.
- `tests/m34_worker_sqlite_godot_e2e.mjs`: `node:sqlite`, signed synthetic callback, local TCP loopback, two launched Godot subprocesses with project isolated profiles.
- `tests/m27_isolated_godot_runner.ps1`: top-level `throw` disables previous runner that traversed/hash-owner tree.
- `tools/run_isolated_godot_probe.ps1`: project scoped direct launcher, process env restored.
- `tools/mobile/build_m34_android_debug.ps1` and M33 playtest launcher updated to project-scoped profile; APK not rebuilt.

## 7. FOCUSED TEST EVIDENCE
Codex log reports refusal 1/1, direct isolated async 4/4, final core 21/21, Worker 20/20, changed-script parse 56/56, SQLite migration+queue 50/51, Node HTTP E2E PASS. Test save SHA-256 primary/backup were logged for isolated test profiles. This GitHub reviewer inspected code and cannot verify output hashes or physical disk. Positive checks only cover described TEST-ONLY workloads.

## 8. REGRESSION EVIDENCE
**New regression introduced by widened runnable-file discovery.** Current `--all` cannot pass for the reasons above; current default CORE may pass as builder reported. Prior guarded legacy launchers (notably M27) are intentionally disabled; the loss of old harness acceptance coverage must remain explicit. Changing 51 scripts affects historical harness invoking them directly: ensure sanctioned safe wrappers exist; do not relax the real owner save guard.

## 9. SECURITY / SAFETY REVIEW
Most meaningful advancement is fail-closed isolation before controller startup and no test cleanup. Some environmental-path checks are lexical and do not prove absence of malicious Windows junction/reparse points; do not claim adversarial isolation against a malicious local operator. Do not run guard-negative tests with the owner's default user directory, even to demonstrate refusal. Avoid source probes that access owner logs, saves or backups. Test fixtures and JWT private signing keys are local only. Production AdMob/billing still fail closed. Newly accumulated test sandboxes consume disk and should not be automatically deleted under owner no-cleanup policy.

## 10. ARCHITECTURE CONSISTENCY
Godot remains game engine; Worker/D1 remote architecture modeled locally by Node/SQLite; native option bridge and cloud identity still absent. Synthetic ECDSA signature cryptographically tests format and Worker signature validation, but not live Google verification/key retrieval. No Expo or GitHub Actions used.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS
Builder avoided TASKS.md; V07 log is immutable evidence. Root TASKS.md still describes P0 isolation as pending, so coordinator should update it. Keep both canonical M34 rows BLOCKED and progress 146/148.

## 12. FINAL REPOSITORY STATE
Audited GitHub main `a9a318d55fc37962d5263af859ae0e29e4d976df`. Audit/tracker/prompt commits after this will move HEAD without altering the audited source code. No owner data accessed by GitHub-source auditor.

## 13. OPEN CROSS-MILESTONE FINDINGS
Historical owner `campaign_save.json` unknown after unsandboxed test; owner data remains protected. Previous M27 harness cannot run and explicitly exits with unknown-owner-save marker. All legacy direct scripts should be launched through an approved isolated runner; any headful performance/capture acceptance from earlier commits remains historical.

## 14. DEFECTS BY SEVERITY
- **MAJOR:** `--all` dispatches negative-only and external Node harness and test support SceneTree.
- **RELEASE BLOCKER:** Native Android/iOS AdMob bridge/consent/SSV device acceptance absent.
- **RELEASE BLOCKER:** Real production identity/Worker D1, StoreKit, Play billing security and store app/account/test approvals absent.
- **NOTE:** Historical owner save impact unknown; no evidence of corruption, and not repairable by guessing a before-hash.
- **NOTE:** No new Android APK requested/produced in V07, as expected.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES
Explicit metadata/allowlist for runnable probes and separate `--isolation-only`, Node E2E and headful launch categories. Negative-probe trust check should be run only with fake isolated unmarked APPDATA and expected exit 70. Use source-level tests for discovery classification without starting Godot outside synthetic profiles. Extend safe test run documentation and avoid silently hiding skipped probes. Do not modify production SaveManager for test isolation.

## 16. UNVERIFIED ITEMS
All device SDK calls, native User ID/nonce transfer, real SSV callback, Cloudflare deployment/D1, identity, real consent/ATT/UMP, purchase/refund/restore, StoreKit/Xcode, test APK native launch, owner-save preincident state, and source-discovered `--all` result (not actually run).

## 17. REGRESSION RISK
**MEDIUM** for newly modified 51 historic tests / discovery and launcher compatibility; **HIGH** for commercial feature readiness.

## 18. AUDIT CONFIDENCE
**HIGH** for concrete test discovery bug and source isolation guards; **MEDIUM** for builder reported offline E2E/tests; **LOW** for physical/sdk/store/owner save.

## 19. FINAL VERDICT
**CONDITIONAL source progress acceptance, with one MAJOR test-harness regression requiring repair. Neither M34 task is complete.** `146/148` unchanged.

## 20. REQUIRED REMEDIATION
Codex may safely fix `--all` classification with explicit test metadata/exclusions, verify by running the genuine full-all category under per-process isolated profiles only; preserve negative isolation test separately and Node e2e under its orchestrator. Then document tested/unverified native bridge boundaries and remaining owner-only gates, and continue any genuinely actionable local SDK/API contract tests without blocking on CI. No owner save read or restore. No GitHub Actions, Expo/Orbit, unverified Computer Use.
