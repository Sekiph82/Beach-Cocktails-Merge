# Mobile SDK provenance and redistribution notes

## Godot AdMob plugin

- Upstream: [godot-sdk-integrations/godot-admob](https://github.com/godot-sdk-integrations/godot-admob)
- Release: `v7.0`, source commit `4b4ddceab0be81f0dcb12a6313038dba6cf9eacf`
- Release archive: `addons/godot_admob/AdmobPlugin-Multi-v7.0.zip` (retained byte-for-byte as supply-chain evidence)
- Archive SHA-256: `d96e1734b889434c0a77f0bafe2f09f4cdb9e5b518b9d6809757b251a17cf8a2`
- Plugin license: MIT; see `addons/AdmobPlugin/LICENSE`.
- Declared integration dependencies in the release source: Android `play-services-ads:24.9.0`, `appcompat:1.7.1`, `lifecycle-process:2.8.3`; iOS Swift Package Manager Google Mobile Ads product at `12.14.0`; iOS deployment target 14.3.
- The plugin exposes UMP consent update/form signals, ATT callbacks, rewarded load/show/dismiss callbacks, and `LoadAdRequest.set_user_id()` / `set_custom_data()` for SSV binding. Its client earned-reward signal is not proof of a trusted reward.
- Both platform export configs deliberately set `is_real=false` and use Google's sample AdMob app IDs. The plugin's built-in rewarded unit IDs are Google's sample test units. No production app or unit IDs are copied into these export configs. Replace only after owner-approved privacy decisions and backend/device gates.
- Godot editor export hooks and the plugin are enabled in `project.godot`. The running game does not initialize AdMob or request/show ads: `AdsService.configure_production()` remains fail-closed pending owner privacy choices, account consent setup, authenticated server claim delivery, SSV endpoint deployment and native device validation.
- The checked release declares Godot 4.7 support. Native execution still requires platform export toolchains and device verification.

## Google Play Billing plugin

- Upstream: [godot-sdk-integrations/godot-google-play-billing](https://github.com/godot-sdk-integrations/godot-google-play-billing)
- Release: `3.3.0`, source commit `e494f370ee591fa11823ad2749a070ed1149de99`
- Release archive: `addons/GodotGooglePlayBilling/GodotGooglePlayBilling-3.3.0.zip` (retained byte-for-byte as supply-chain evidence)
- Archive SHA-256: `20d75623d6f337f08d8283c83098b73678d5f575e39247af5a8eb80588b18568`
- Plugin license: MIT; see `addons/GodotGooglePlayBilling/LICENSE`.
- Release source uses Google Play Billing Library `9.1.0`. The plugin README says its master/release line supports Godot 4.2+; this project pins Godot 4.7.2.
- The Android plugin is available to Gradle Android exports. The existing non-Gradle personal sideload APK path is retained and was not rewritten.
- The SDK is installed as an export dependency. Store purchases remain disabled because the live catalog has no approved product IDs or prices and the Worker store routes deliberately reject all purchase/restore assertions until trusted Apple/Google verification exists.

## Dependency rights boundary

The MIT notices cover the Godot plugin source and bundled plugin bridge binaries. Google Mobile Ads and Google Play Billing are separate Google SDK dependencies resolved for native exports; their terms, privacy/data disclosures, and current SDK notices remain applicable. No Google SDK source or Maven AAR was copied into this repository. Review upstream notices and store disclosures again when updating either plugin or SDK version.

## StoreKit

The official Godot StoreKit 2 plugin currently offers binary release builds for Godot 4.5/4.6, not 4.7. This repository does not copy its older binary into the Godot 4.7 project. The StoreKit adapter contract and verification handoff are documented in `docs/mobile-commerce/BCM_M34_006_007_STOREKIT_BILLING_PREPARATION_V01.md`; native Apple purchase execution remains unverified until an official compatible binary/source build and macOS/Xcode validation are available.
