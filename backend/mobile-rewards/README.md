# BCM mobile reward verification Worker

This is an un-deployed Cloudflare Worker + D1 implementation scaffold for AdMob server-side verification (SSV). It uses Google's rotating ECDSA public keys, verifies the exact raw query prefix before `signature` and `key_id`, binds signed SSV fields to an authenticated short-lived reward claim, and atomically inserts one reward-ledger row and settles the claim in D1. Repeated delivery of the same signed transaction is idempotent; a transaction reused across claims is rejected.

## Current safety state

- There is no Cloudflare account, D1 database, Worker secret, route, custom domain, or app JWT issuer configured by this task.
- `wrangler.toml` contains a non-deployable database placeholder. Do not deploy until the owner chooses the host and identity provider and supplies/sets secrets locally in the provider console.
- `APP_JWT_SECRET`, `APP_JWT_ISSUER`, and `APP_JWT_AUDIENCE` are mandatory runtime bindings. The client must send a short-lived provider-issued HS256 app JWT; anonymous client-generated IDs are not authentication.
- `AD_REWARD_POLICY_JSON` must be set from the approved app/ad-unit mapping. It defines the app request's full `ad_unit` (`ca-app-pub-.../...`), the exact numeric `ssv_ad_unit` Google returns in its signed callback, and server-owned reward item/amount. Both values are required and independently matched; do not assume the request and callback encodings are identical.
- Google’s [Android SSV parameter reference](https://developers.google.com/admob/android/ssv) describes `ad_unit` as the AdMob ad-unit ID and shows its numeric callback value; it also states that Google omits `user_id` when the app does not set it.
- Apply migrations in filename order. `0002_admob_ssv_unit_binding.sql` records the SSV callback unit per claim. `0003_store_verification_journal.sql` prepares store transaction ownership, verified-purchase grant journaling and non-consumable restore entitlements; SQLite constraints and triggers reject cross-account transaction reuse, grants without matching verified purchases, and consumable/refunded restore entries.
- The Worker caps outstanding active claims plus unacknowledged settled rewards at 50 per authenticated user. A full queue returns `429 REWARD_QUEUE_FULL`; a server-verified reward remains pending until the client durably applies it and ACKs it.
- The client `consent_granted` and `consent_state` request fields are lifecycle assertions, not independent legal/compliance proof. This Worker scaffold is not production consent enforcement; do not enable live requests until the owner-approved consent/age/ATT policy and trusted identity flow are established.
- Daily rewarded claims carry a separate `client_transaction_id` such as `daily:YYYY-MM-DD:3`; the Google SSV `transaction_id` remains the server ledger/ACK key. This keeps UTC slot idempotency distinct from Google's receipt identity.
- Store verify/restore routes require the existing app JWT, but intentionally return `503` with `grant:false` until a reviewed Apple/Google verifier, exact owner-approved application/product policy, provider credentials and native identity exist. `src/store_verification.js` currently contains sealed rejecting adapters: it does not decode client JWS payloads, call a provider endpoint, or accept synthetic success. Setting `STORE_VERIFICATION_ENABLED=true` does not enable grants. The production Worker does not write the new journal tables while trusted verification is unavailable.
- The browser-based Cloudflare account was not inspected or changed. Local deterministic tests use an in-memory D1 contract fake and generated ephemeral signing keys; they are not a production D1 test or deployment.

## Required bindings before any owner-authorized deployment

1. `DB`: D1 binding with `migrations/0001_mobile_rewards.sql` applied.
2. `APP_JWT_SECRET`: high-entropy secret set with Wrangler/provider secret management, never committed. Identity provider issues `iss`, `aud`, `sub`, `exp`, and preferably `iat`.
3. `APP_JWT_ISSUER`, `APP_JWT_AUDIENCE`: exact identity configuration.
4. `AD_REWARD_POLICY_JSON`: owner-approved per-placement policy that agrees with AdMob ad-unit reward settings and the in-app economy.
5. AdMob SSV callback URL registered in AdMob only after the Worker has a live HTTPS endpoint and callbacks have been verified.

## Local tests

```powershell
npm test
```

`npm test` verifies ECDSA signature acceptance/rejection, exact query handling, stale/incorrect claim binding, replay prevention, and store endpoint/policy/provider fail-closed behavior with synthetic data. Run `python test/verify_store_migration.py` to apply all migrations to local in-memory SQLite and check transaction uniqueness, owner binding, grant gating and restore restrictions. These checks do not contact a live store, prove Apple signature chains or Google Play purchase verification, or exercise deployed D1/device billing.
