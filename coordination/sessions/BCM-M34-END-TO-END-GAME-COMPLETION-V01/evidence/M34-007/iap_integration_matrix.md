# M34-007 In-App Purchase Integration Matrix

## Current implementation

`StoreService` is a fail-closed service seam only. The catalog contains blank Android/iOS IDs, no approved prices, and `buyable:false` placeholders for nonconsumable `remove_ads` and a generic consumable currency pack. The UI says store items are disabled until the owner catalog and receipt verification setup exist.

The service has no native billing provider or trusted verifier by default. A purchase is rejected; restore is rejected without a provider and trusted transaction verification. `accept_verified_transaction()` refuses all client-submitted receipts until a verifier implementing the external trust boundary is explicitly supplied. A validated nonconsumable entitlement is deduplicated by transaction ID. No paid currency or entitlement is granted from a client success flag.

## Platform assessment

| Platform | Candidate | Evidence | Status |
|---|---|---|---|
| Android | Godot Google Play Billing v3.3.0, release commit `e494f37`, Billing Library 9.1.0, MIT | Upstream release states Godot 4.2+ support; Android v2 plugin packaging/Gradle integration is required. No plugin, export preset, Play product, test account, or backend verifier exists in this project. | `BLOCKED_LIVE_PAYMENT_VERIFICATION`; not built or device-tested. |
| iOS | Godot StoreKit 2 upstream plugin, MIT | Upstream repository warns that API is ongoing and unstable and requires native iOS plugin/export setup. No immutable release pin or Godot 4.7 project verification was established. | `BLOCKED_LIVE_PAYMENT_VERIFICATION`; not built or device-tested. |

No app-store accounts were accessed. No products or prices were created. No purchase, restore, signing, upload, or charge was attempted.

## Required verified flow before enabling

1. Fetch native purchases through the platform provider and retain the provider transaction/order identity.
2. Send the transaction to a trusted backend/store verifier; reject pending, invalid, revoked, refunded, or mismatched product transactions.
3. Apply entitlements idempotently by verified transaction ID. Persist ownership outside the client as required by product type.
4. Acknowledge/consume/finish a transaction only after verification and durable entitlement commit.
5. Reconcile restore and reconnection against the trusted ledger, then run kill/restart, duplicate, pending, refund/revoke, offline, and restore cases on signed test builds.

This M34 build intentionally cannot complete those external steps. The safe outcome is no buyable button or local fulfillment path.

## Owner-required decisions

- Approve whether to sell Remove Ads, currency, or boosters, and exact product IDs and prices per store.
- Decide whether Remove Ads controls only approved banner/interstitial placements; it must not suppress rewarded ads without a separate explicit ruling.
- Supply a trusted receipt-verification backend design and operational owner; never put service credentials or receipt tokens in the repository.
- Select immutable compatible SDK/plugin releases and preserve their license notices and exact artifact hashes before adding native files.
- Provide Apple/Google test products, sandbox accounts, signing/export configuration, and device acceptance evidence.

All catalog entries remain nonbuyable and no store is declared production-ready.
