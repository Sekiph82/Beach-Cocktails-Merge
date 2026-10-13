# M34-006 Ads and Rewarded Provider Matrix

## Project inventory

- The project has no AdMob/ads SDK under `addons/`, no ad unit/app IDs, no Android export preset, and no iOS export project. The task-added `AdsService` is a provider abstraction with an explicit adapter boundary; it is not a native SDK integration.
- Rewarded placements are opt-in and disabled by default. No banner or interstitial is shown. No ad request occurs unless the adapter and an explicit consent state are supplied.
- `AdsService` rejects absent consent/provider, reports skip/close as cancellation, accepts only a matching transaction while the session is showing, and rejects empty or duplicate receipts. Navigation routes only a `verified_rewarded` signal for `energy_20` into the Energy ledger.
- A provider adapter must make `accept_provider_reward()` only from the native SDK’s completed-reward callback. This GDScript boundary does not authenticate a provider receipt itself; no live adapter is wired.

## Candidate SDK research (not vendored)

| Candidate | Upstream provenance | License | Godot/platform claim | M34 disposition |
|---|---|---|---|---|
| Godot AdMob Plugin v7.0 | `godot-sdk-integrations/godot-admob`, release tag `v7.0`, release commit `4b4ddce` | MIT | Release notes claim Godot 4.7 support and unified Android/iOS API. An open Android issue reports initialization trouble on Godot 4.7; follow-up cites an AAR discovery workaround. | Do not vendor in this pass. No local AAR, checksum, export config, app IDs, consent decisions, build, or device proof. Record as a candidate requiring a pinned artifact + reproducible package hash and Android/iOS smoke tests. |
| Google Play Billing v3.3.0 (IAP candidate) | `godot-sdk-integrations/godot-google-play-billing`, release `3.3.0`, commit `e494f37` | MIT | Release uses Google Play Billing Library 9.1.0; release note states Godot 4.2+ compatibility. Android Gradle/AAR and Play Console setup are still required. | Not an ads SDK. No Android plugin is installed or build/device-verified. Keep for M34-007 evaluation only. |
| Godot StoreKit 2 (IAP candidate) | `godot-sdk-integrations/godot-storekit2` | MIT | Upstream README describes an ongoing, unstable API and instructs placing its native plugin under `ios/plugins`, then enabling it in an iOS export preset. No pinned release/Godot 4.7 qualification was established in this pass. | Do not vendor. Requires an immutable compatible release pin, Xcode/iOS export and device tests. |

The AdMob release’s stated Godot 4.7 support is not equivalent to a working project integration: the open issue is specifically about v7.0 failing to initialize on Godot 4.7 Android. A version pin is a source reference, not a reproducible package checksum; no SDK artifact was downloaded, copied, built, or packaged here.

## Safety and verification state

| Scenario | Result |
|---|---|
| No consent / no provider | Fails closed; no reward. |
| Provider unavailable / no fill | Fails closed; no reward. |
| User skips/closes without reward | State becomes `CANCELLED`; no receipt signal. |
| Reward callback | Must match the currently showing transaction and nonempty unique provider receipt. Mocked callback path is probe-only and does not constitute an SDK pass. |
| Duplicate transaction/receipt | Rejected or idempotently ignored by transaction/reward ledgers. |
| App background / lifecycle | No native lifecycle adapter exists; platform behavior is unverified. The UI remains opt-in and no automatic gameplay interruption is configured. |
| EEA/UK consent, age-directed status, COPPA, iOS ATT | Defaults remain disabled/owner-required; no requests or identifiers are sent. Privacy policy and disclosures are not yet approved. |
| Android/iOS device | `NOT_DEVICE_VERIFIED`. |

Owner setup before enabling: choose audience/age status; approve privacy wording and disclosures; create app IDs and test-unit IDs; approve consent and ATT behavior; pin compatible native dependencies with license notices and hashes; configure Android Gradle/AAR and iOS native plugin/export; run real test ads and verified callback/skip/failure/background/restart cases on devices. Keep all production unit IDs out of repository evidence.

## Source references

- [AdMob v7.0 release](https://github.com/godot-sdk-integrations/godot-admob/releases) and [open Godot 4.7 Android initialization issue](https://github.com/godot-sdk-integrations/godot-admob/issues/124).
- [AdMob MIT license](https://github.com/godot-sdk-integrations/godot-admob/blob/main/LICENSE).
- [Google Play Billing v3.3.0 release](https://github.com/godot-sdk-integrations/godot-google-play-billing/releases) and [MIT license](https://github.com/godot-sdk-integrations/godot-google-play-billing/blob/master/LICENSE).
- [StoreKit 2 repository and compatibility warning](https://github.com/godot-sdk-integrations/godot-storekit2) and [MIT license](https://github.com/godot-sdk-integrations/godot-storekit2/blob/main/LICENSE).
- [Godot 4.7 Android plugin packaging guide](https://docs.godotengine.org/en/4.7/tutorials/platform/android/android_plugin.html).
