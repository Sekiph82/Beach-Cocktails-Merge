# BCM-M34-R06-001 — AdMob SSV trust blueprint

Status: design proposal only. There is no selected backend host, deployed endpoint, durable reward ledger, Android build, or device callback. Production rewarded payout stays disabled. The current Godot `AdsService` client signal is not an AdMob SSV receipt and cannot authorize Coins, Gems, or Energy.

## Trust boundary and minimum service

Use a small HTTPS service with two public routes and a durable SQL database (SQLite on a backed-up persistent volume is adequate for a low-volume single instance; PostgreSQL is a portable option if the chosen host already provides it). No paid vendor is assumed. Host selection, backups, uptime, data region, and operating cost need owner approval before deployment. The service holds no AdMob signing secret: Google signs callbacks; the service stores Google's rotating public keys and verifies them. Store database credentials and any client-authentication secrets in the host's secret store, never in Godot, logs, or repository files.

1. `POST /v1/reward-claims`: authenticate the game account, validate the allowed placement against server configuration, create a cryptographically random opaque nonce, and persist only its hash with account ID, placement, configured reward item/amount, issue time, expiry, and `consumed=false`. Return the opaque nonce and expiry to the client. Put the nonce in AdMob `custom_data` before `show`; set AdMob `user_id` only to an opaque stable account key if needed. Neither value is authentication by itself.
2. AdMob calls a unique `GET /v1/admob/ssv` callback URL. Capture the original raw query bytes before framework decoding/normalization. Require the documented final `signature`, then `key_id` parameters in that order; reject duplicate parameter names and malformed encodings. Verify the ECDSA SHA-256 DER signature over the untouched UTF-8 query prefix ending immediately before `&signature=`. Resolve `key_id` only against the AdMob public-key feed. Do not verify reconstructed or sorted parameters.
3. After cryptographic verification, parse fields once and validate configured app/ad unit, known placement claim, nonce hash, optional user ID match, exact expected reward item and amount, transaction ID, and callback timestamp. Recommended initial policy (owner configurable): nonce validity 24 hours; callback maximum age 24 hours; maximum future skew 5 minutes. These are local policy values, not AdMob guarantees. Store/compare timestamp in milliseconds.
4. In one database transaction, insert `transaction_id` into a table with a global unique constraint, atomically consume the matching nonce, and append the server-side entitlement ledger entry. Unique transaction and nonce constraints make concurrent retries exactly-once. A valid already-recorded transaction gets HTTP 200 with no second entitlement; persist the first transaction's binding so a same-ID/different-user or different-payload callback is flagged and never credited. Commit before sending success.
5. Client earned callbacks only update UI to “verifying”. The client then polls or refreshes an authenticated claim-status/entitlement route. Only the server ledger response updates valuable local economy state. If SSV arrives before the client callback, settle the already-issued claim; if the client callback arrives first, show pending. Retry and app restart resolve through the same claim ID. Offline client state never creates a grant.

## Key lifecycle and callback handling

Fetch `https://www.gstatic.com/admob/reward/verifier-keys.json` over TLS. Cache each key set no longer than 24 hours; refresh on scheduled expiry and once on an unknown `key_id`. Use a bounded timeout and validate the response schema/key IDs. If fetch is unavailable or the key is unknown after refresh, fail closed and alert; never fall back to a bundled stale key or accept a client receipt. A signature failure gets no ledger write. Return 4xx for malformed/invalid callbacks; Google documents retries when it does not receive HTTP 200 (up to five retries one second apart). Return 200 only after a verified durable insert or a verified idempotent duplicate. Monitor retry/invalid rates without logging full callback URLs, nonce values, user identifiers, or signatures.

Do not use reverse DNS as a substitute for signature validation. It can be an additional network-level signal only. Bound request size and parameter count, rate-limit claim issuance, use HTTPS, and keep the callback route free of user-facing secrets. Use generic error responses externally and reason codes in access-controlled metrics.

## Privacy, consent, and age

Before requesting ads, refresh UMP consent state at each launch, complete any required form, and gate requests on `canRequestAds()`. Treat the game account ID and nonce as pseudonymous personal data: transmit the minimum, use an opaque account reference, set short claim expiry, restrict access, and define deletion/retention with the owner before production. Do not place emails, names, or other PII in `custom_data` or `user_id`. The owner must determine audience/age classification and legal markets; apply the corresponding child-directed/under-age settings and consent behavior before serving ads. No child-audience or legal classification is assumed here.

## Deployment gates

- Owner selects a backend operator/host and approves recurring and one-time costs, region, retention, backup, and incident owner.
- Production ad-unit IDs and exact item/amount mapping are configured server-side; test IDs are used in development.
- The account authentication and durable entitlement reconciliation contract is agreed; IAP stays a separate verifier and ledger path.
- Unit, concurrency, replay, key-rotation, outage/retry, privacy, clean-install and physical Android callback acceptance pass. A local mock is only protocol evidence.
- Production payout remains off until a real signed Google callback and the authenticated client reconciliation are independently reviewed.

## Evidence boundary

R05 found plugin v7.0 API/AAR references for `setCustomData`, but did not prove runtime attachment or Google callback delivery. `tests/backend_protocol/m34_r06_ssv_backend_mock.test.js` exercises this proposal with ephemeral local ECDSA keys and in-memory state. It is not a production verifier and is not imported by Godot or shipped with the game.

## Official references checked for R06

- [AdMob rewarded SSV callback validation](https://developers.google.com/admob/android/ssv) — callback fields/order, raw signed query requirements, ECDSA/SHA-256/DER, key feed, 24-hour key-cache limit, millisecond timestamp, unique transaction ID, and retry behavior.
- [Google UMP privacy setup](https://developers.google.com/admob/android/privacy) — refresh consent information on launch and gate ad requests on `canRequestAds()`.
- [AdMob child-directed and under-age settings](https://developers.google.com/admob/android/targeting) — owner must classify audience and configure applicable request flags.
- [Godot 4.7 Android export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html) — OpenJDK 17 and the pinned SDK/Build-Tools/NDK/CMake versions.
- [Android sdkmanager reference](https://developer.android.com/tools/sdkmanager) — scoped SDK root, package management, and standard SDK license flow.
