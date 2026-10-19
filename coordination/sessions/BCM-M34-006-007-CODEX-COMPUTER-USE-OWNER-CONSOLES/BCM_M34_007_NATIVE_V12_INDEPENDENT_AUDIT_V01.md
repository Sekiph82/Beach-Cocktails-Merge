# BCM-M34-007 / BCM-M34-006 — V12 Independent Audit V01

**Date:** 2026-10-19. **Auditor:** ChatGPT. **Audited GitHub `main` source SHA:** `904028d94a65b148a996ea46fa9985d9359f2a5e`. **Builder evidence:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V12.md`. **Authority:** root `TASKS.md` alone tracks live task status; this report is historical evidence.

## 1. INDEPENDENT VERDICT
**PASS at SOURCE LEVEL for the narrowly scoped V12 fail-closed SQL UPDATE protections and strict request-boundary hardening; CONDITIONAL on the builder's local test execution.** The V11 latent journal/entitlement/purchase identity UPDATE problems are addressed by a forward-only migration and corresponding positive/negative tests. No active payment verifier or store grant flow was added. **BCM-M34-007 and BCM-M34-006 remain BLOCKED; progress 146/148 (98.6%).** Do not call a security-hardened *schema* a working billing service.

## 2. REPOSITORY / CHANGE SCOPE
GitHub HEAD matched `904028d94a65b148a996ea46fa9985d9359f2a5e` when fetched. Parent `42be08f6d9ceb65c6ba9740d30379ffa72450ea1`. Changes only in `backend/mobile-rewards` migration, Worker request code/parser, focused tests, README and immutable V12 builder log. No Godot/native plugin, store catalog, AdsService, real owner files, or root `TASKS.md` modifications in this commit.

## 3. DATABASE SOURCE FINDINGS
- **PASS:** `migrations/0004_store_verification_integrity.sql` is a new migration; previous `0001`–`0003` were left intact.
- **PASS:** `store_purchase_history_identity_immutable` guards platform, transaction/order, user, product, package, environment and immutable timestamps; `store_purchase_history_state_transition` permits verified→refunded/revoked/expired but rejects terminal→verified.
- **PASS:** `store_grant_journal_update_integrity` makes owner, product, kind and `grant_payload_json` immutable; a journal may move pending→applied only with exact matching verified purchase; terminal refund revocation triggers reversal and rejects re-apply.
- **PASS:** `store_entitlements_update_integrity` rejects same-refunded-transaction reactivation and account/product transfer; it permits legitimate new verified non-consumable transaction rebinding for the same owner/product.
- **LIMIT:** SQLite triggers constrain **writes to these tables**, not the source of a 'verified' purchase INSERT: only real authenticated Apple/Google provider validation, not a client or a database flag, may authorize that status in any future Worker writer. No writer exists now.
- **LIMIT:** Builder tests use local Python SQLite foreign-key constraints; neither deployed Cloudflare D1 migrations nor transactional multi-request concurrency were verified. No need to pretend a Cloudflare deploy occurred.

## 4. WORKER SOURCE FINDINGS
- `src/store_verification.js`: explicit input keys per platform. Google accepts only `platform,product_id,purchase_token`; Apple only `platform,product_id,signed_transaction`. Unknown fields and wrong-platform proof are rejected.
- `parseStoreRequestBody`: 32 KiB input bound and duplicate-key-aware JSON scan before JSON.parse, including nested object keys. Malformed or oversized requests fail closed.
- `src/index.js`: streaming read bound prevents unlimited store POST bodies; authenticated JWT and configured store-policy guards remain. With owner store policy absent, a request returns `503/grant:false` before detailed body validation. With a configured test policy, invalid JSON or forbidden fields return `400/grant:false`.
- Both `verifyGooglePurchase` and `verifyApplePurchase` still **always reject**, make zero provider API calls, and do not accept client JWS payload decoding as verification. `STORE_VERIFICATION_ENABLED=true` does not allow a grant. `GET /v1/store/restore` remains 503/no-grant for authenticated caller.
- New `store_*\` SQL tables remain **unwired** to Worker purchase or restore routes. There is no production transaction journal read/write or currency grant path.

## 5. TEST EVIDENCE
Builder V12 reports fail-first reproduction of V11 UPDATE bypasses in disposable SQLite 0001–0003, followed by **11/11** SQLite migration checks with 0004. Node Worker tests **24/24**; `git diff --check` PASS; `TASKS.md` unchanged. Reviewer independently inspected source and assertions via GitHub, **did not rerun** local Node/SQLite. Previous V10 STRICT Godot 21/21 and M21 tutorial-aware 100/100 remain historical; backend-only V12 did not need to repeat those tests.

## 6. SECURITY / PROVENANCE
Current store endpoints have **no grant path**. Receipt/token data should never be logged or shipped as secrets. Provider account ownership, app JWT subject mapping and product policy need a real independently authenticated ownership design at activation, including refunds/restore and consumable lifecycle. The V12 triggers do not stand in for trusted API verification or server-side atomic grant logic. No exploit of a live endpoint is alleged. Owner real save `campaign_save.json` prior unsandboxed test impact remains `OWNER_SAVE_STATE_UNKNOWN_NO_BASELINE`; no inspection/repair/delete authorized.

## 7. STILL-BLOCKED ACCEPTANCE
**M34-006 rewarded ads:** physical mobile AdMob bridge applying SSV user_id and custom_data to native rewarded ad, real signed provider callback, approved identity + UMP/ATT/age/privacy policy, approved AdMob account configuration, deployed Worker/D1 and device verification. Production ads OFF.

**M34-007 billing:** approved exact SKUs/quantities/types/prices and entitlement/refund semantics; verified Apple developer/App Store Connect and Google Play app records and sandbox testers; trusted production user identity and provider credentials; authentic Google Play Developer API token validation and Apple StoreKit/App Store-signed transaction JWS certificate-chain verification; connected, transactional Worker D1 purchase/grant/refund journal; actual Google Billing consume/ack and StoreKit compatible Godot/iOS binary + device builds/tests. Catalog `buyable=false`, Worker purchase/restore no-grant.

**Infrastructure restriction:** GitHub Actions unavailable; Expo/Orbit excluded; Computer Use blocked at browser URL-origin validation. No bypass. Preserve personal XTool/BAT and historic IPA/APK, no owner save access or disk cleanup.

## 8. OPEN ISSUES / ENGINEERING STOP RULE
There is **no confirmed new source vulnerability requiring another self-generated mock milestone** within the audited V12 changes. V12's narrow security-hardening objective is accepted at source level. Production use still requires designing and implementing a *genuine provider verifier and server transaction consumer* with credentials, identity, approved catalog and account/device conditions, which are owner/service gates. Do not keep creating successive fake-provider shells to increase local test counts; instead request the minimum necessary owner decisions when they are ready. This is **not** permission to close either canonical task.

## 9. OWNER HANDOFF
The next useful decision is to establish whether real provider-account setup and an authorized testing environment are available. Ask owner for **one consolidated response** on initial product catalog/monetization, identity+backend host, Apple/Google account readiness, availability of native Android/iOS test devices and privacy/consent policy responsibility. If not ready, leave M34-006/007 BLOCKED and preserve a runnable ad-disabled, purchases-disabled build without fabricating acceptance.

## 10. FINAL VERDICT
**V12 code remediation: SOURCE PASS / BUILDER LOCAL TEST CONDITIONAL. M34-006 + M34-007: BLOCKED, 146/148 unchanged.** This closes the V11 SQL hardening *finding*, not the whole commercial feature task.
