# BCM mobile reward verification Worker

This is an un-deployed Cloudflare Worker + D1 implementation scaffold for AdMob server-side verification (SSV). It uses Google's rotating ECDSA public keys, verifies the exact raw query prefix before `signature` and `key_id`, binds signed SSV fields to an authenticated short-lived reward claim, and atomically inserts one reward-ledger row and settles the claim in D1. Repeated delivery of the same signed transaction is idempotent; a transaction reused across claims is rejected.

## Current safety state

- There is no Cloudflare account, D1 database, Worker secret, route, custom domain, or app JWT issuer configured by this task.
- `wrangler.toml` contains a non-deployable database placeholder. Do not deploy until the owner chooses the host and identity provider and supplies/sets secrets locally in the provider console.
- `APP_JWT_SECRET`, `APP_JWT_ISSUER`, and `APP_JWT_AUDIENCE` are mandatory runtime bindings. The client must send a short-lived provider-issued HS256 app JWT; anonymous client-generated IDs are not authentication.
- `AD_REWARD_POLICY_JSON` must be set from the approved app/ad-unit mapping. It defines only server-owned placement/platform → ad unit/reward item/reward amount values.
- The client `consent_granted` and `consent_state` request fields are lifecycle assertions, not independent legal/compliance proof. This Worker scaffold is not production consent enforcement; do not enable live requests until the owner-approved consent/age/ATT policy and trusted identity flow are established.
- Daily rewarded claims carry a separate `client_transaction_id` such as `daily:YYYY-MM-DD:3`; the Google SSV `transaction_id` remains the server ledger/ACK key. This keeps UTC slot idempotency distinct from Google's receipt identity.
- Store verify/restore routes intentionally return `503` with `grant:false` until Apple/Google server verification is implemented and credentials, product ids, and owner-approved products exist. No store assertion is trusted by this Worker.
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

The local tests verify ECDSA signature acceptance/rejection, exact query handling, stale/incorrect claim binding, duplicate/replay prevention, server-only grants, and fail-closed authentication/configuration. They do not contact a live AdMob account or a real D1 database.
