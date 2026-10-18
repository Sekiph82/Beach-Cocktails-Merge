# BCM-M34-006 / 007 — Native V03 independent source audit V01
Date: 2026-10-18. Reviewer: ChatGPT. Source head: `d7f12b5ff83e43cb1346e254211af6c13cc68343`.
Builder evidence: `docs/codex-logs/CODEX_LOG_2026-10-18_M34_006_007_NATIVE_V03.md`.
**Authority:** root `TASKS.md` only for live status. This immutable audit is historical evidence, not a separate tracker.

## 1. VERDICT
**FAIL as a completion/clean-regression claim; CONDITIONAL as useful incremental engineering.** M34-006 and M34-007 stay open. A pre-existing regression *test file* fails now because this implementation changed `StoreService.get_catalog()`'s return shape. Do not treat it as independent/unrelated without baseline proof. Native SDKs are installed but never invoked in production; end-to-end verification is missing.

## 2. CONTRACT RECOVERY
Keep Godot 4.7.2, existing physics/merge/To-Go/VIP/NO TIMER, immutable mobile artifact/BAT, reward/payment verification fail closed. Codex codes/tests; ChatGPT independently audits and alone edits `TASKS.md`.

## 3. BRANCH / HEAD / DIFF SCOPE
Builder start `6a0f332911367f40c7f40a712c0aa1e1cf630b92`; implementation `37268143c98d52b9ab40bb48453c1ff625474153`, parser correction `090552ce113675ecff632a013960e4abb8110d29`, log commits ending `d7f12b5...`. Verified GitHub `main` equals `d7f12b5...` at inspection. Source changes include Godot AdMob and Play Billing plugin directories/binaries, iOS libraries, Worker/D1, `StoreService`, editor plugins, tests, docs, logs. No `TASKS.md` write in this builder change range.

## 4. ACCEPTANCE CRITERIA MATRIX
| Criterion | Status | Grounding |
|---|---|---|
| Existing IPA/APK found and metadata inventoried | PARTIAL | Local inspection/log; auditor cannot independently read owner's local Downloads files. |
| BAT preserved | PARTIAL | Builder reported matching SHA before/after; no device replay. |
| Plugins added to repo | PASS | Godot addon and iOS plugin files and `project.godot` verified by source. |
| Native mobile SDK runtime verified | UNVERIFIED | No APK/IPA build, SDK init, test ad or purchase observed. |
| Worker SSV source & local tests | PARTIAL | Source/SQL inspected; builder reports 15/15; no independent Worker/D1 execution or deployment. |
| StoreKit IAP / Apple Pay separation | PASS | Apple Pay Merchant ID not part of StoreKit implementation. |
| Legacy economy regression | FAIL | `tests/m34_economy_closure_probe.gd:164` uses former keyed-dictionary contract. |
| Android CI native plugin export | FAIL/UNVERIFIED | `android-apk.yml` sets `gradle_build/use_gradle_build=false` while official Google Play Billing plugin docs require Gradle build. No native APK built. |
| Real SSV + trusted player grant | UNVERIFIED | No deployment, authenticated issuer integration, mobile session wiring or award claim consuming ledger. |
| Real store purchase / refund / restore | UNVERIFIED | All actual routes still return 503 and StoreService products remain unavailable. |

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH
The builder's description of add-on installation and fail-closed behavior matches source. “The economy probe had a pre-existing failure” does **not** match the diff evidence: before V03 `StoreService.get_catalog()` returned a dictionary keyed by `remove_ads` and `currency_pack_placeholder` (all dictionary values were products); after V03 it returns the parsed schema object containing `schema_version`, `status`, and `products`. The unchanged line 164 calls `store.get_catalog().values().all(func(item): return not item.get(...))`. Scalar schema values have no `.get()`, causing the observed float error. The **test file** predates V03, but the **failure is introduced by the changed public interface** unless an independently observed prior failure refutes this. Report as an introduced incompatibility, not an unrelated baseline defect.

## 6. FILE / SYMBOL EVIDENCE
- `scripts/campaign/store_service.gd`: new `CATALOG_PATH`, `FALLBACK_CATALOG`, `get_catalog()`, `_product()`.
- `tests/m34_economy_closure_probe.gd:164`: old dictionary-return contract.
- `tests/m34_store_catalog_boundary_probe.gd`: tests *new* schema only, does not cover old caller compatibility.
- `.github/workflows/android-apk.yml:79`: `gradle_build/use_gradle_build=false`, contradicts upstream `godot-sdk-integrations/godot-google-play-billing` README “Enable Gradle Build”.
- `.github/workflows/android-play-aab.yml`: gated signed path sets `gradle_build/use_gradle_build=true`, but it has not been used for native acceptance.
- `.github/workflows/ios-ipa.yml`: macOS runner already exists; Windows having no Mac/Xcode is not a sufficient reason to avoid *CI feasibility checking*.
- `scripts/campaign/ads_service.gd`: production adapter remains disabled.
- `backend/mobile-rewards/src/index.js`: SSV verifies signed callbacks and settles D1 ledger, but no deployed claim issuer and no game currency grant wireup.
- `backend/mobile-rewards/src/index.js`: store verify/restore routes explicitly return 503 without any grant.
- `addons/AdmobPlugin/{android_export.cfg,ios_export.cfg}`: test IDs and `is_real=false`; iOS ATT disabled pending policy.
- `addons/AdmobPlugin/AdmobPlugin.gd`: iOS export injects `NSAppTransportSecurity` with arbitrary-load allowances. Justify or minimize this Apple/privacy setting before shipping, and test actual exported Info.plist.

## 7. FOCUSED TEST EVIDENCE
Builder V03 reports focused Godot **5/5**, Worker/JWT **15/15**, SQLite schema PASS, plugin GDScript check-only PASS. Auditor read source and test code but **did not run the tests independently**, did not inspect proprietary binary contents or the on-disk mobile artifacts.

## 8. REGRESSION EVIDENCE
The separate M34 economy probe **FAILED**. A passing targeted subset does not establish that the full existing regression suite passes. Rerun full core suite and the failed probe after contract repair, then explicit Android native export checks.

## 9. SECURITY / SAFETY REVIEW
Fail-closed ad and store paths are positive. Worker checks signature, replay, idempotency, binding, expiry, and JWT in source; correctness in production requires deployed D1, authenticated issuer, Google key delivery, real AdMob callback, downstream entitlement ledger integration, monitoring, and realistic adversarial tests. The JWT signing secret must never be embedded in the client. Review unsafe iOS `NSAllowsArbitraryLoads` export XML before Apple release. No live ad/store call or public launch is authorized by this audit.

## 10. ARCHITECTURE CONSISTENCY
Game remains Godot-native. No Expo or Orbit. Godot Android export must include native plugins and compatible Gradle toolchain. iOS mobile build may use existing GitHub macOS workflow. Host/backend and identity decisions remain pending.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS
Root `TASKS.md` still lists older V02 preparation; refresh to reflect V03 source changes, newly revealed regression, and next Codex action. Keep both canonical task rows **blocked** and total **146/148** until genuine acceptance.

## 12. FINAL REPOSITORY STATE
Observed `main=d7f12b5...` at audit; no builder changes were reverted. Auditor did not mutate source or run builds. Any subsequent tracker/prompt commits will move `main` beyond the audited SHA.

## 13. OPEN CROSS-MILESTONE FINDINGS
Historical test consumers of `get_catalog()` should be enumerated; recheck gameplay/economy tests after fixes. Apple account legal and Play account physical-device gates remain; do not bypass them.

## 14. DEFECTS BY SEVERITY
- **MAJOR:** `StoreService.get_catalog()` contract break causing M34 economy test failure.
- **MAJOR:** Android debug APK workflow non-Gradle export despite native billing dependency.
- **MAJOR/PENDING:** No real SDK runtime wiring, grant consumption, StoreKit purchase, end-to-end backend deployment.
- **MINOR/RELEASE RISK:** iOS unrestricted transport plist injection requires review and rationale.
- **NOTE:** Local lack of JDK/Mac is not itself a GitHub-hosted CI build blocker.
- **NOTE:** Browser helper cannot verify URL; account operations safely paused rather than guessed.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES
Test contract shape explicitly; keep backward compatibility or migrate **all** consumers, not only the failing test. Provide one safe unsigned/debug GitHub Actions build per platform to validate native plugins; preserve legacy XTool/BAT. Make store/catalog schema validation robust against future malformed definitions. Add signed-source provenance and minimum-needed native artifact checks.

## 16. UNVERIFIED ITEMS
All Windows local artifact bytes/hash, AdMob live approvals, Cloudflare deployment, App Store/Play records, plugin-binary on-device initialization, Android/iOS signing, Apple StoreKit, paid purchase/refund/restore, owner account legal consents, live test ad impression and secure real reward delivery.

## 17. REGRESSION RISK
**HIGH until catalog interface and native export tests are resolved.**

## 18. AUDIT CONFIDENCE
**HIGH** in source-level catalog regression and Android workflow mismatch; **MEDIUM** in broader security correctness (source-only plus builder tests); **LOW** in native/runtime/mobile/account readiness (no access).

## 19. FINAL VERDICT
**FAIL for completion and clean regression; CONDITIONAL for useful incremental implementation.** Do not mark 006/007 complete or unblock production advertising/IAP.

## 20. REQUIRED REMEDIATION
Use follow-up **V03** prompt in the same coordination directory. Priority 1: fix catalog API contract and test, run full suite. Priority 2: repair/debug nonshipping Android Gradle/plugin CI, exercise iOS macOS CI; preserve prior IPA/APK and XTool. Priority 3: implement safe native wiring and authenticated claim flow with end-to-end tests; leave deployment, accounts, financial/legal/physical-device decisions with owner. Codex must not edit root `TASKS.md`.
