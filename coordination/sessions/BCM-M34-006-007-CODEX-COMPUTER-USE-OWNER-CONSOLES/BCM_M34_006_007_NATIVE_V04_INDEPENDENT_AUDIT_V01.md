# BCM-M34-006 / BCM-M34-007 — Native V04 Independent Audit V01

**Date:** 2026-10-18. **Coordinator/auditor:** ChatGPT. **Audited code HEAD:** `98abe780c171d44c0a29dc12b1d70e8a9b391ab2`. **Builder log:** `docs/codex-logs/CODEX_LOG_2026-10-18_M34_006_007_NATIVE_V04.md`. Evidence document only; **root TASKS.md is the sole live tracker**. Builder is not authorized to edit TASKS.md.

## 1. VERDICT
**CONDITIONAL: V03 remediation is source-confirmed, real Windows debug APK build is reported with detailed packaging evidence, and SSV local recovery logic improved. M34-006 and M34-007 are NOT complete.** Keep native production ads and billing disabled. Builder test output and on-disk APK remain independent-runtime UNVERIFIED because they were not accessible to this GitHub-only audit.

## 2. CONTRACT RECOVERY
Preserve Godot 4.7.2, owner-approved gameplay, economy, no-timer, all historical downloads, XTool/BAT, private data, no destructive disk cleanup. **OWNER: GitHub Actions UNAVAILABLE; do not run or rely on them.** Expo/Orbit rejected. App Store/Google/AdMob Computer Use halted by URL-verification policy; do not bypass.

## 3. BRANCH / HEAD / DIFF SCOPE
Builder: baseline `3478cb232b383e6a136c39c4dd3be9c4c12bb68f` → implementation `723407d1c3e9ce35c535f54235c3add3984a774d` → test `713b7edcda015b0cd8dfecbb50aa3d15caee0039` → execution log `98abe780c171d44c0a29dc12b1d70e8a9b391ab2`. GitHub branch `main` equaled audited SHA when inspected. Scoped code diff modified store service, Worker/D1, AdMob iOS export flags, tests, nonshipping Android PowerShell build script and gitignore. No builder TASKS.md edit.

## 4. ACCEPTANCE CRITERIA MATRIX
| Criterion | Verdict | Evidence and boundary |
|---|---|---|
| M34 economy regression fixed | PASS, source | `get_catalog()` returns keyed product dictionaries again; `get_catalog_document()` provides schema; old failing line 164 no longer invokes get on schema scalar. |
| Exact historical `get_catalog()` API semantics | PARTIAL | Prior product rows used `product_type`, current parsed rows use `kind`. Keyed-dictionary shape recovered; check any consumers requiring the old field names. |
| Product purchases remain safely gated | PASS, source | `StoreService` checks nonbuyable flag before provider/verification; real purchase/restore not implemented. |
| Local Worker reward pending / ACK | PASS, source | Authenticated endpoints consult D1 verified ledger, user scope and server ACK; untrusted claim consent boolean is not authoritative policy proof. |
| Crash-safe exactly-once grant in **real Godot economy** | UNVERIFIED | JS test uses a `Set` plus in-memory balance, not actual `GameEconomy` + `SaveManager`, atomic persistent save or restart. |
| Godot focused 7/7, core 13/13; Worker 16/16 | BUILDER-REPORTED PASS | Audit inspected tests/source but did not independently run Godot/Node on owner's machine. |
| Local native Android Gradle debug APK | BUILDER-REPORTED PASS | Script and exact package/build metadata present; APK is in ignored owner-local `.godot/` and not independently materialized to auditor. |
| Android device native AdMob and Billing | UNVERIFIED | Packaging/Dex analysis does not prove runtime initialization, permissions/UI, rewarded callback or purchase. |
| iOS ATS restriction | PASS, source | Broad `NSAllowsArbitraryLoads` removed from AdMob plugin export hook; media and web-content exceptions retained; exported plist not inspected. |
| Worker real deployment, real Google callback | UNVERIFIED | No Cloudflare resources/secrets or live AdMob signed callbacks configured. |
| iOS StoreKit / app signing | UNVERIFIED | No Apple-compatible StoreKit plugin proven with Godot 4.7.2, no available Mac or Actions, no new IPA. |
| Real Play Billing / receipt verification | UNVERIFIED | Provider not wired; store verify/restore return 503 and no grant; catalog deliberately unapproved. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH
The new API functions, Worker routes and tests, isolated build script, ATS flag and enabled Gradle preset are present in GitHub source. Builder's 13/13, 7/7, 16/16 counts, 205,813,760-byte debug APK and `141ED1ECF4F74AA22FE9C4BF3D919B8DB4C96ECAD54CE98A7F71B50E75E168F6` hash are correctly classified as reported local evidence, NOT independently reproduced. Desktop screenshot/browser accounts and local APK bytes were not available to this audit.

## 6. FILE / SYMBOL EVIDENCE
- `scripts/campaign/store_service.gd`: `get_catalog`, `get_catalog_document`, `accept_verified_transaction`.
- `tests/m34_economy_closure_probe.gd:164` old keyed-map consumer; `tests/m34_store_catalog_boundary_probe.gd` updated.
- `backend/mobile-rewards/src/index.js`: `listPendingRewards`, `acknowledgeReward`, `handlePendingRewards`, `handleAcknowledgeReward`, `handleCreateClaim`; `backend/mobile-rewards/migrations/0001_mobile_rewards.sql` `reward_delivery_ack`.
- `backend/mobile-rewards/test/ssv_worker.test.js`: mock crash/reopen, wrong-user ACK, consent checks.
- `tools/mobile/build_m34_android_debug.ps1`: project-isolated SHA-verified Temurin 17 JDK, Android Gradle, distinct package, test AdMob application IDs, restore original project and preset bytes in finally.
- `addons/AdmobPlugin/AdmobPlugin.gd`: narrowed ATS exceptions.
- `scripts/campaign/ads_service.gd`: production still explicitly fail closed; no live native bridge.
- `scripts/campaign/game_economy.gd`: existing `grant_verified_ad_energy`, `grant_reward`, transaction ledgers; still not connected to Worker verified pending/ACK flow.

## 7. FOCUSED TEST EVIDENCE
Builder reports 7/7 focused and 13/13 full **core** Godot suite, 16/16 local Worker/JWT, PowerShell parse and SQLite schema PASS, `git diff --check` PASS. Independent reviewer did source-level inspection only; actual process output not rerun or authenticated. Full core suite does not include every legacy/headful/mobile probe.

## 8. REGRESSION EVIDENCE
V03 catalog scalar .get failure no longer structurally present in fixed API. Other regressions pass as builder reported. Need additional real save/persistent reward cross-crash and plugin-initialization tests, not just string-contains probe; re-run unchanged gameplay tests after new adapter wiring.

## 9. SECURITY / SAFETY REVIEW
AdMob/live store disabled, Worker verify/restore fail closed, app JWT server-secret-only contract retained, user-scoped D1 queries and transaction idempotency improve security. **CRITICAL DESIGN REMAINDER:** `consent_granted=true` in client request is not independently verifiable user consent; must come from validated consent/UMP state and server policy; do not treat it as production-ready. A client ACK is not server proof that reward was durably written to an untrusted device. Actual save must commit transaction ID + balance atomically before ACK, with recovery when ACK fails or app crashes. Any offline replay, reinstall, malformed/oversized responses, forged auth and duplicate reward flows require tests. No production credentials in repo.

## 10. ARCHITECTURE CONSISTENCY
Godot remains native game. Standalone Worker D1 owns signed SSV and ledger; Godot must **consume only server-verified, user-bound rewards** and persist deduped payout before ACK. Native AdMob API still not wired to the game; plugin DEX packaging alone is not gameplay integration. StoreKit absent, Play Billing addon present but unconnected to verified purchase lifecycle.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS
The builder correctly refrained from updating root `TASKS.md` or claiming production acceptance. Root status is now stale because it still describes the catalog regression and missing Gradle debug export. Coordinator updates status without changing `146/148`.

## 12. FINAL REPOSITORY STATE
Audited GitHub `main` SHA `98abe780c171d44c0a29dc12b1d70e8a9b391ab2`. Current audit/tracker/prompt commits will be later; no production source changes made by reviewer.

## 13. OPEN CROSS-MILESTONE FINDINGS
Native ads reward energy and Daily Rewards; preserve 20 Energy cap, UTC daily claim rules, coins/gems and local save ledgers. The old API `product_type`/new `kind` discrepancy may affect consumers; enumerate and explicitly test. iOS, Play and AdMob owner account legal/privacy/device approvals remain separate.

## 14. DEFECTS BY SEVERITY
- **BLOCKER (release):** No native AdMob runtime bridge or trustworthy production identity/consent/SSV deployment, no physical device verification.
- **BLOCKER (release):** No functional StoreKit integration and no trusted Play purchase/restore/refund verification.
- **MAJOR (verification):** JS `Set` fixture does not demonstrate persistent Godot GameEconomy/SaveManager crash-consistent reward delivery.
- **MINOR / compatibility risk:** `get_catalog()` restored map form but returns product `kind`, whereas old public map values used `product_type`; confirm actual downstream expectations and normalize if needed.
- **NOTE:** No Actions or Mac available, so current iOS native build is legitimately blocked; no need to halt other coding.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES
Add API contract tests for catalog field compatibility; authenticated claim and pending/ACK end-to-end local integration tests crossing Worker and Godot economy/save; Android debug test-only AdMob initialization and callbacks; safe local-native Play Billing initialization behind store gate; mock transport failure/response size tests; archive local APK hash/provenance in log without uploading sensitive artifact.

## 16. UNVERIFIED ITEMS
APK bytes and install, Android device runtime, native Google SDK init/UMPs, JWT issuer, real Google SSV keys HTTP and callback, D1 deployment, published privacy/consent, Apple iOS StoreKit/TestFlight/IPA, App Store Connect and Google Play records, purchase/refund/restore, real live ads.

## 17. REGRESSION RISK
**MEDIUM** for currently audited source (previous issue addressed), **HIGH** for still-unimplemented commercial feature acceptance.

## 18. AUDIT CONFIDENCE
**HIGH** for source-level catalog/Worker/ATS/probe findings; **MEDIUM** for local build confidence (builder metadata, no physical bytes); **LOW** for actual mobile/cloud/account acceptance.

## 19. FINAL VERDICT
**CONDITIONAL progress accepted, milestone acceptance BLOCKED.** Existing canonical M34-006 and M34-007 remain `[!]`. No fake native PASS.

## 20. REQUIRED REMEDIATION
Execute next scoped same-milestone V04 implementation prompt: address real Godot ledger+save atomic recovery and native AdMob safe test adapter, check legacy catalog product field expectations, expand automated integration tests. Keep GitHub Actions OFF; do not deploy Worker, allow live ads or purchase without owner approvals. Continue local tests and offline prep even if iOS/portal blocked.
