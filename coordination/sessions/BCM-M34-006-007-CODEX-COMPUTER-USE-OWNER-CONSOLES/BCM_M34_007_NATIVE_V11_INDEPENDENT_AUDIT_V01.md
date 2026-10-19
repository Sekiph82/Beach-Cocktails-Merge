# BCM-M34-007 / BCM-M34-006 — V11 Independent Audit V01

**Date:** 2026-10-19. **Auditor:** ChatGPT, independent GitHub source-level review. **Audited GitHub main:** `3ad56eb4721ce0d7f2a216c4257db9f87f56e6f1`. **Builder log:** `docs/codex-logs/CODEX_LOG_2026-10-19_M34_006_007_NATIVE_V11.md`. Historical audit only: root `TASKS.md` is the unique canonical live task tracker and only ChatGPT updates it.

## 1. VERDICT
**CONDITIONAL SOURCE PASS for authentication and deliberately fail-closed billing boundaries. NOT a working Apple/Google purchase verifier, not a server-side grant service, and not a completed BCM-M34-007.** No production store/ads activation. **HIGH-PRIORITY LATENT SCHEMA INTEGRITY FINDING:** migration `0003` enforces owner/verification/restore rules on INSERT but is insufficiently guarded on certain **UPDATE** statements; if future Worker code writes these tables, it may be possible to reopen an entitlement after refund or mutate a journal row's user/payload without a matching verified transaction. Fix proactively before adding any trusted provider grant path.

## 2. CONTRACT RECOVERY
Preserve Godot 4.7.x, owner-approved gameplay and economic rules, `buyable=false`, deployed Worker/D1 absent, trusted identity issuer absent, local XTool/BAT+IPA/APK, owner data and untracked state. OWNER: GitHub Actions unavailable; no Expo/Orbit/EAS, account/browser Computer Use (origin safety block), deployment, real purchases, ads, or native device testing without explicit authorization. Root TASKS.md is sole live tracker and builder must not edit it.

## 3. BRANCH, HEAD, DIFF SCOPE
Implementation+log in `3ad56eb4721ce0d7f2a216c4257db9f87f56e6f1`, parent `80a1fb50c5b97bdecefd1176bb4b762e35c6cfe5`. GitHub main matched builder SHA when audited. New `src/store_verification.js`, migration `0003_store_verification_journal.sql`, migration tests, Worker route edits, Worker tests, README, builder log. No Godot/native changes, no root TASKS.md edits.

## 4. ACCEPTANCE MATRIX
| Criterion | Verdict | Evidence |
|---|---|---|
| `POST /v1/store/verify` JWT authentication | **PASS SOURCE** | `index.js::handleRequest` calls `authenticate`, rejects without JWT (401); no anonymous grant route. |
| `GET /v1/store/restore` JWT authentication | **PASS SOURCE** | Authenticated requests return 503/no grant, unauthenticated 401. |
| Configured per-platform product allowlist and submission normalization | **PASS SOURCE/PARTIAL** | `store_verification.js::parseStorePolicy` and `validateStoreSubmission`; client authority blacklist rejects known spoofed fields, but unknown extra keys are ignored rather than rejected. |
| Google Play Developer API purchase-token verification | **NOT IMPLEMENTED** | `verifyGooglePurchase` always rejects and never calls provider. |
| Apple StoreKit/App Store signed-JWS verification | **NOT IMPLEMENTED** | `verifyApplePurchase` always rejects, no certificate chain/trust check. |
| Production purchase/restore grants | **PASS FAIL-CLOSED** | Even if flag `STORE_VERIFICATION_ENABLED=true`, returned result always 503/grant:false. |
| D1 migration transaction identity / duplicate constraints | **PASS INSERT / UPDATE GAPS** | PK, verified-insert triggers, entitlement insert/update identity checks, and refund cascade present, but see section 5. |
| Actually connected Worker purchase journal | **NOT IMPLEMENTED** | No Worker route writes or reads new store tables. |
| Worker `npm test` 23/23 and Python SQLite 4/4 | **BUILDER-REPORTED PASS** | Code/tests inspected, executions not independently rerun. |
| Physical store billing, native StoreKit/Play, real devices | **UNVERIFIED/BLOCKED** | No device/store/account/credential evidence. |

## 5. SOURCE-CONFIRMED DATABASE INTEGRITY GAPS (latent until store-writing implementation)
**A. Grant journal update bypass.** `store_grant_journal_verified_insert` trigger checks a purchase is owned and verified **only on INSERT**. The `store_grant_journal` FK is just `(platform,transaction_id)`, not the account and product. There is no accompanying UPDATE identity/verified-purchase guard. A future writer could INSERT a legitimate verified row for account A, then UPDATE `user_id`, `product_id`, `product_kind`, or `grant_payload_json` on the existing row without retriggering the INSERT check. Primary key idempotency alone does not prevent mutable grants. No current API exposes this operation: this is **hardening needed before activation**, not a claim of live exploit.

**B. Non-consumable entitlement reactivation.** `store_purchase_reversal_propagation` automatically changes `store_entitlements.state` to `revoked` or `expired` after refund/revocation/expiry. But `store_entitlements_verified_nonconsumable_update` fires only for UPDATE OF `user_id,product_id,platform,transaction_id`, **not `state`**. Thus an UPDATE of `state='active'` alone can bypass the verified-purchase guard even if parent purchase remains refunded. This is also latent while the Worker has no store writer.

**C. Purchase history immutability.** `store_purchase_history` primary key secures `platform,transaction_id`, but row `user_id,product_id,product_kind,application_id,environment` can be changed after verification, potentially breaking the owner-binding contract of existing journal/entitlements. Refund-state transition should not be silently converted back into `verified` without an independent trusted new provider check and explicit policy.

**D. Client request allowlist language.** `validateStoreSubmission` rejects known CLIENT_AUTHORITY_FIELDS but does not reject all unknown top-level keys. Because these extra fields are ignored and providers currently reject every request, this does **not** enable a grant now. The builder description should say *known* spoofed fields rejected, not every possible client claim.

**Acceptance criteria for remediation:** use a forward-only **new** migration `0004` (do not edit already-added `0003` history), with SQLite/D1-compatible immutable identity and state-transition enforcement; test fail-first UPDATE attacks, refunded reactivation, cross-user reassignment and legitimate reversal cascade. Do not introduce unapproved automatic currency clawback.

## 6. FOCUSED TEST EVIDENCE
Builder V11 reports `npm test` **23/23**, migration test `4/4`, `git diff --check` PASS. No Godot, mobile build, Google/Apple API, deployed D1 or physical verification was run. Auditor has reviewed code/test assertions via GitHub but has **not run** Node/SQLite independently.

## 7. SECURITY REVIEW
Positive: no real provider calls, no tokens/secrets in tracked source, JWT required before route, product policy required, no client-side success accepted and `grant:false` all routes. Avoid treating a JWT subject alone as store account ownership proof: authenticated app identity is distinct from a provider-verified purchase account binding. No deploy authorized. `parseStorePolicy` requires both Apple and Google entries with at least one enabled product, which may be too rigid for staged single-platform launch; owner-approved product design and release policy not yet decided, so this is a design constraint, not a proven vulnerability.

## 8. TEST COVERAGE
Existing migration tests prove unique INSERT/verified parent/reversal and fake-verifier rejection, but contain no adversarial UPDATE after a previously verified INSERT or reactivation after refund. Add those. Real Apple certificate trust and Google Developer API purchase-state checks remain absent and must not be reported as implemented.

## 9. AUTHORITY / TRACKER
Builder respected root TASKS.md ownership and safe account/device boundaries. Update root TASKS.md after independent source review: V11 local no-grant guard and schema exist, but actual provider verifier/Worker ledger integration absent; legacy V10 test quality is accepted at source level; canonical tasks stay blocked and progress **146/148**.

## 10. FINAL VERDICT
**V11 fail-closed preparation: SOURCE CONDITIONAL PASS. Store schema needs UPDATE hardening before becoming writable. M34-007 / M34-006 remain BLOCKED.** Next bounded Codex work is meaningful SQL trigger hardening + local adversarial tests, then a truthful owner-gated provider-verifier handoff; avoid endless mock-only scaffolding or claiming store readiness.
