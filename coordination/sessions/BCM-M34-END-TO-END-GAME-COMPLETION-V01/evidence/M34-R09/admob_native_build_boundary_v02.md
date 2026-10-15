# R09 V02 Native AdMob Offline Evidence

The isolated test project at `C:\Users\sekip\AppData\Local\BCM-M34-R09-AdmobTestProject` uses Godot AdMob plugin 7.0 and Gradle 8.11.1. Godot 4.7.2 invoked the Android export hook and resolved the plugin's direct dependencies:

- `androidx.appcompat:appcompat:1.7.1`
- `androidx.lifecycle:lifecycle-process:2.8.3`
- `com.google.android.gms:play-services-ads:24.9.0`

The resolved manifest report also identifies AppCompat resources 1.7.1, Play Services Ads API 24.9.0, and Ads Identifier 18.0.0. The six named direct/transitive module-version folders contain 8,050,246 bytes in the local Gradle module cache; this subtotal excludes transform outputs and other transitive modules.

The resulting test-only APK is 96,310,569 bytes with SHA-256 `BEA85F2B25AD5E1EABA7B344863803B8168E259073A122F91406387E537C770F`, package `org.example.bcm.r09admobtest`. AAPT reads its package metadata; apksigner v2 verification passes; APK contents include AdMob plugin/Google Ads classes and manifest declarations. The harness is copied to `admob_test_harness_v02.gd` and uses only Google's sample app ID. Its consent flow gates initialization, and its reward callback explicitly grants no product currency.

This validates native export, Gradle dependency resolution, plugin packaging, and APK signing offline. No physical device was authorized for this cycle. Runtime SDK initialization, consent-form display, and test-ad playback remain `DEFERRED_BY_OWNER_NOT_DEVICE_VERIFIED`, as instructed by the 2026-10-15 owner override. There are no production IDs or production game integrations in this test.
