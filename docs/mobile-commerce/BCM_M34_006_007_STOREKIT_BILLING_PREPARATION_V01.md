# BCM-M34-006/007 StoreKit and Play Billing preparation V01

Status: engineering preparation only. Store catalog is still non-buyable and needs owner decisions. Apple Merchant ID `merchant.com.sekiph82.beachcocktails` is not used here; Merchant IDs are for Apple Pay. The StoreKit application id remains the existing bundle id `com.sekiph82.beachcocktails`.

## Proposed catalog for owner review (not configured in either store)

Identifiers below are proposals only. The store-localized price must be approved in App Store Connect / Play Console; the USD suggestions are an initial discussion point, not a configured price or financial instruction.

| Proposed product id | Type | Gameplay basis | Suggested starting price (USD) | Restore / delivery | Status |
| --- | --- | --- | ---: | --- | --- |
| `bcm_remove_ads` | Non-consumable | Existing `remove_ads` placeholder; affects ads only after a real entitlement is designed | $2.99 | Restore current entitlement; server re-checks signed transaction and refund/revocation state | Owner approval required |
| `bcm_coins_500` | Consumable | Existing coin currency used in campaign rewards | $0.99 | No restore of consumed balance; trusted server credits an idempotent ledger entry | Owner approval required |
| `bcm_coins_1500` | Consumable | Same canonical coin currency | $2.99 | No restore of consumed balance; trusted server credits an idempotent ledger entry | Owner approval required |
| `bcm_gems_20` | Consumable | Existing gem currency used by the shop economy | $0.99 | No restore of consumed balance; trusted server credits an idempotent ledger entry | Owner approval required |

No amounts or prices are present in `data/campaign/store_catalog.json`; the proposals above must not be added as sellable rows until the owner approves exact quantities, IDs, localized prices, and refund policy. In particular, no “remove ads” behavior is activated yet because ads are currently disabled and the entitlement semantics must be finalized.

## Provider handoff contract

- Google Play Billing plugin 3.3.0 exposes purchase updates and purchase tokens. The native callback only provides evidence to send to a trusted backend; it does not grant coins, gems, or entitlements.
- Apple StoreKit returns App Store-signed transaction data (`jwsRepresentation` in StoreKit 2). A server must verify the signed transaction, expected bundle/product/environment, revocation/refund state, and unique transaction id before crediting. Restore uses `currentEntitlements`/transaction history and the same verification path.
- The backend ledger key is `(platform, transaction_id)`. Consumable grant is atomic with transaction settlement. Duplicate receipt submissions are idempotent. Refund/revocation notifications transition transaction state and reverse only what the chosen economy policy can safely reverse; no client-only assertion is accepted.
- No StoreKit native binary has been copied: official Godot StoreKit 2 release binaries do not target project Godot 4.7. StoreKit purchase and sandbox behavior remain unverified until a compatible native build is produced and tested on macOS/Xcode.
- `backend/mobile-rewards` has fail-closed `/v1/store/verify` and `/v1/store/restore` routes that return `503` and `grant:false`. Apple App Store Server Library integration and Google Play Developer API purchase-token verification require owner-approved bundle/product configuration, developer account record, server identity/credentials, and the chosen production host; no credentials belong in Git.

## Setup and evidence still required

- Owner chooses the exact product quantities, identifiers, localized prices, refund semantics, and whether an ad-removal entitlement is desired.
- Apple Developer/App Store Connect: confirm the canonical App ID and app record; create approved IAP products and sandbox testers. Do not accept agreements or create Apple Pay materials for StoreKit.
- Google Play Console: create/use the existing canonical app record; register products; configure license testers and backend service-account access through protected provider settings.
- Choose trusted backend identity provider and hosting; configure secrets only in provider secret storage.
- Test purchases, pending purchases, cancellation, restoration, duplicate delivery, refunds/revocations and offline recovery in each store sandbox. Physical-device and store-console proof are still required.
