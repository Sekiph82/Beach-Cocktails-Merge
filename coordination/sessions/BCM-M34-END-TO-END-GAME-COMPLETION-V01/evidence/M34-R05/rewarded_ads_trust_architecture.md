# BCM-M34-R05-003 — Rewarded ads trust architecture

## Repository and package evidence

The inspected official v7.0 Android release archive is pinned to source tag commit `4b4ddceab0be81f0dcb12a6313038dba6cf9eacf`; the downloaded ZIP SHA-256 is recorded in `admob_v7_ssv_api_evidence.json`. The GDScript package declares `rewarded_ad_user_earned_reward(ad_info, reward_data)`. `LoadAdRequest` exposes `set_custom_data` and `set_user_id`, and `Admob.gd` forwards the request dictionary to the native singleton. Both debug and release AAR bytecode constant pools reference `ServerSideVerificationOptions`, `setServerSideVerificationOptions`, and `Builder.setCustomData` for rewarded video and rewarded interstitial classes. This establishes a plausible plugin API path for setting SSV data. It does not prove successful Android runtime application or delivery to Google without a build/device callback.

The client reward signal has no AdMob SSV `transaction_id`, signature, `key_id`, timestamp, or verified receipt. The app's current `AdsService.accept_provider_reward` and economy settlement require a nonempty receipt and reject duplicate receipt/transaction claims. No production adapter is wired, so existing behavior remains fail closed.

## Trust decision

- **Explicitly nonvaluable test-only option:** a debug-only/test-harness local grant may respond to the native earned callback, deduplicate with an app-generated test transaction, and operate only on disposable test state and Google test ad units. It must not create a production `provider_receipt`, feed production save/economy state, or imply provider verification. No such test grant is implemented in R05.
- **Production reward option:** configure AdMob rewarded SSV and send a server-issued opaque claim nonce in `custom_data` before showing the ad. A backend must preserve the callback's signed query bytes/order, fetch/cache AdMob public keys, verify the ECDSA signature, validate app/ad-unit/reward amount/item/timestamp and nonce-to-user/placement binding, reject stale/unknown/replayed `transaction_id`, and atomically record the verified provider event and award. The client must claim or refresh state from the backend's authoritative response; a client callback alone cannot authorize valuable payout. Backend service, persistent ledger, HTTPS route, nonce issuance, key rotation/cache and observability are absent. Therefore production rewarded claims remain disabled.
- **IAP remains separate:** no client-only fulfillment. Catalog entries remain placeholders/nonbuyable until approved SKU/pricing and trusted store receipt verification are provided. No payables.

## First Android debug/device dependency checklist

1. Owner-approved isolated JDK 17, Android command-line tools, platform-tools/ADB, Android platform 35, Build-Tools 35.0.1, CMake 3.10.2.4988404, NDK 28.1.13356709 and Godot 4.7.2 Android export templates.
2. Owner-approved package/app identity and test ad units; consent/UMP decisions; correct debug manifest/application ID; plugin archive and AAR loading confirmed by first Android build.
3. A reachable HTTPS backend with SSV callback configuration, signature/key rotation handling, durable idempotent reward ledger, per-user claim nonce issuance, and authenticated client claim endpoint before production valuable rewards.
4. Android device, USB debugging/ADB authorization, clean install route and owner observation.
5. For IAP, approved product IDs/prices and trusted verifier integration are separate prerequisites.

## Focused test plan

- Build: plugin init and AAR discovery; debug export/install/launch; test ad load/show; verify `set_custom_data` is attached before show and observed in server callback; verify earned callback occurs once and close/skip/error do not earn.
- Lifecycle: background/resume, activity recreation, callback ordering, no-fill, offline, duplicate callback, app restart during pending claim.
- SSV backend: valid Google test callback; altered signature; unknown/rotated key; malformed or missing fields; wrong package/ad-unit/reward amount/item; unknown or user-mismatched nonce; stale timestamp; duplicate `transaction_id`; concurrent replay; backend timeout/retry; ledger atomicity and exactly-once entitlement.
- Client/server reconciliation: no local payout before authoritative backend response for production; duplicate response is idempotent; offline retry recovers one grant; forged native client callback alone cannot pay.
- IAP: invalid receipt, wrong product, replayed store transaction and verifier outage all fail closed; no placeholder can be bought or fulfilled.

Status: `OWNER_APPROVAL_REQUIRED` for Android toolchain/download/device setup; production ads remain `DISABLED_PENDING_BACKEND_AND_DEVICE_EVIDENCE`.
