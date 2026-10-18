# BCM-M34-006 / BCM-M34-007 — Native V05 Independent Audit V01

**Date:** 2026-10-18. **Auditor:** ChatGPT. **Code/evidence examined:** GitHub `main` at `6be8cb7a893c66ad6572347ccf809c5b52bdb8b8`. **Builder log:** `docs/codex-logs/CODEX_LOG_2026-10-18_M34_006_007_NATIVE_V05.md`. Historical audit/evidence only; **root TASKS.md remains the unique live status authority**, and only ChatGPT writes it.

## 1. Verdict
**CONDITIONAL acceptance of technical progress; M34-006 and M34-007 remain BLOCKED.** The repo contains meaningful Godot/GameEconomy/SaveManager persistent reward delivery logic, HTTPS transport, debug-only AdMob adapter, and Play Billing test adapter. However, source audit identified a concrete **MAJOR SSV user binding bug** not exercised by the passing mocks: native test ad requests set only `custom_data` and never set `user_id`, while Worker SSV explicitly requires a matching `user_id`. In a real Google callback missing `user_id`, the Worker rejects the reward. Fix before presenting end-to-end native SSV as viable. No production ads, IAP, native device or cloud deployment approval.

## 2. Contract recovery
Preserve owner gameplay and economy, Godot 4.7.2, XTool/BAT, historical IPA/APK, private files, no disk cleanup, NO GitHub Actions and NO Expo/Orbit. Browser Computer Use origin verification failed; do not bypass. Codex builder never edits TASKS.md. This audit does not authorize native live ads, purchases, identity creation or Worker deployment.

## 3. Branch/scope
Builder baseline fast-forwarded to `474a91acd163b8e85a503bc63b6b22e1fa966e63`, implemented `b7e85ca82d0b2fe1cb8e11e2de8931eb72b3e8c6`, and published log `6be8cb7a893c66ad6572347ccf809c5b52bdb8b8`. Live GitHub main matched logged SHA when queried. Diff adds/refactors `scripts/campaign/mobile_reward_delivery.gd`, `mobile_reward_http_transport.gd`, `admob_test_adapter.gd`, `play_billing_test_adapter.gd`, GameEconomy, AdsService, CampaignNavigationController, Worker/D1 schema/tests and additional M34 probes. TASKS.md unchanged by builder.

## 4. Acceptance matrix
| Criterion | Finding |
|---|---|
| Godot durable reward path | PASS source design: applies transaction-keyed server row, persists economy via campaign SaveManager before ACK, rollback on failed save, resumes pending deliveries. Real network/end-user identity unverified. |
| Correct placement amounts & daily UTC | PASS source: energy 20, daily slots 2–5 amounts, UTC transaction-day/client id and cap guards; note outstanding full-energy settlement policy. |
| HTTP transport | PASS source: HTTPS-only, size limits, authenticated subject checks, disabled by default. Does not itself prove JWT authenticity, delegated to Worker. |
| AdMob debug adapter | PARTIAL: real signal/method names used and native callback cannot directly award; missing SSV `user_id` parameter breaks Worker binding. |
| Worker pending/ACK, D1 unique id | PASS source design with 17 builder-reported tests, un-deployed. |
| Play Billing debug adapter | PARTIAL: gated by StoreService and server verifier; no real store purchases, trusted store verification, durable consume/ACK across app restart. |
| Godot core 19/19, focused 8/8, Worker 17/17 | BUILDER-REPORTED PASS, not independently rerun. |
| Local APK produced | BUILDER-REPORTED: `205,845,262` bytes, SHA `9D2226E5AFFF850AE7B7B446F453EC3E1699A53FAC9B64F7514F6B132699CBFD`, nonshipping `com.sekiph82.beachcocktails.m34debug`, no device run, signing not verified on this V05 run. |
| Release AdMob, identity, UMP/ATT | BLOCKED, intentionally off. |
| iOS StoreKit/IPA | BLOCKED, no macOS/Xcode/GitHub Actions. |
| Store real verification/refunds/restores | BLOCKED, Worker routes fail-closed and product catalog nonbuyable. |

## 5. High-confidence SSV contract defect
**Godot code:** `scripts/campaign/admob_test_adapter.gd`, `_on_claim_created()`:
```gdscript
request.set_ad_unit_id(_ad_id)
request.set_custom_data(str(response["nonce"]))
admob.load_rewarded_ad(request)
```
It never calls `request.set_user_id(...)`.

**Actual bundled plugin API:** `addons/AdmobPlugin/model/LoadAdRequest.gd` implements `set_user_id(a_value: String)` separately from `set_custom_data(a_value: String)`.

**Server:** `backend/mobile-rewards/src/index.js` `handleSsv` extracts `fields.get("user_id")`, rejects absent required fields, and compares it with `claim.user_id`. Google's official SSV reference says it omits the `user_id` callback query parameter when the client does not set a user ID. Therefore this integration, as currently written, cannot satisfy its own server's user binding in a genuine SSV callback. `tests/m34_admob_test_adapter_probe.gd` only checks custom_data nonce, and `backend/mobile-rewards/test/ssv_worker.test.js` constructs a simulated Google callback with user_id already present; neither covers the gap. Add a fail-first integration/contract probe requiring both authenticated subject and nonce, and tests for absent/wrong user ID. Do not invent a player ID, and use the same actual authenticated subject as Worker JWT. For production design, verify Google plugin semantics and consent/privacy before transmitting the subject externally.

## 6. APK signing follow-up
V05 claims `apksigner verify` was not possible because `java` was not on PATH/JAVA_HOME. V04 had a project-scoped checksum-verified Temurin JDK used for Gradle build. Check whether `.godot/toolchains/temurin17/.../bin/java.exe` still exists; run signing verification via a **process-local** `JAVA_HOME` pointing there, without installing a new global JDK or overwriting owner files. Do not label signature VALID until the command succeeds.

## 7. Other engineering caveats
1. The V05 `MobileRewardDelivery.settle_pending_rows` reports `SERVER_ACK_PENDING` on an asynchronously initiated ACK; CampaignNavigationController retries via callback + subsequent pending fetch. A real HTTP→Godot callback-to-save-to-ACK integration (including multiple rows and crash mid-ACK) remains untested by physical network.
2. `GameEconomy.apply_verified_mobile_reward` rejects an energy reward at cap and delivery deliberately does not ACK it. Decide and test expiry/claim UX so an otherwise verified reward does not remain pending forever.
3. `GameEconomy` save state belongs to current profile; an approved identity provider must ensure account↔save binding. The current temporary local subject is test-only.
4. The Play Billing test adapter's in-memory `_pending_completion`/`_completed_tokens` ledger has no durable restart guarantee; before production consumption or acknowledgment, implement server/client idempotent reconciliation and real Play purchase-token verification.
5. Google SSV documentation example shows `ad_unit` as a numeric identifier; verify whether actual callback returns full string matching `ca-app-pub-.../...` or a shorter numeric portion against real/sanitized provider fixture before production. Do not relax matching without evidence.

## 8. Evidence confidence
HIGH for source inspection and specific missing native user-ID binding. MEDIUM for mock/security test interpretation. LOW for reported APK bytes/signer, actual native AdMob/Play SDK behavior, identity, cloud deployment and store accounts; no independent access to Windows local runtime or devices.

## 9. Required next actions
1. Fix the actual native SSV user_id/nonce/claim identity binding and add tests proving it across both plugin request and Google callback/Worker verifier; preserve nonshipping test ID and fail-closed production status.
2. Use existing portable JDK to verify APK signing (no global PATH change); if actual plugin/source changes warrant it, run local rebuild through the current project-scoped Gradle script.
3. Strengthen local simulated request→signed SSV→pending→Godot save→async ACK/retry and account-profile swap tests; consider cap semantics.
4. Advance StoreKit and Play purchase-token verification architecture safely without pretending store/device acceptance; owner only handles genuine legal, identity, privacy, backend deployment, device permissions.
5. Codex commits source and immutable builder log, ChatGPT audits and alone updates root TASKS.md. GitHub Actions remains unavailable, Expo/Orbit rejected.
