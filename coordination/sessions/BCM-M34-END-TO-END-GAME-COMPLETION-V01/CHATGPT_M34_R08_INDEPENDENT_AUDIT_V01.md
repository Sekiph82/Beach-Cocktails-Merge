# BCM M34-R08 INDEPENDENT AUDIT V01

Verdict: **PASS for bounded R08 investigation and export-size optimization; BLOCKED for native/device acceptance.** This independent review inspected the published Codex R08 execution log and apk_size_comparison.json in GitHub. Godot tests and APK signatures were run by Codex, not independently reproduced by GPT.

R08-001: ADB queried successfully but detected no device: NOT_DEVICE_VERIFIED. Owner must connect an authorized Android device with USB debugging and approve the device pairing prompt before installation, screenshots, tap/safe-area testing or performance acceptance.

R08-002: AdMob v7.0 archive pin/hash verified; isolated project desktop import/smoke PASS with ads disabled. Native Android build remains BLOCKED by missing cached Gradle 8.11.1 distribution/Maven dependencies, and upstream Godot 4.7 AAR discovery issue #124 is unresolved. NO production plugin integration, and NO live rewarded delivery claims.

R08-003: SSV nonshipping mock 8/8 PASS as reported; no live backend/verifier, account claims or signed Google callback. Production coins/gems/energy must remain fail closed without server-side SSV verified transaction and idempotent ledger. IAP separately blocked.

R08-004: audited 1,353,363,654-byte unfiltered same-profile control vs 301,979,173-byte filtered APK. Reduction 1,051,384,481 bytes (77.69%). The exclusions are coordination/**, assets/ui_assets/source/**, and assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png; no repository source deleted. Static package inspection found ten gameplay surfaces, ten geometry profiles and core HUD/L01-L12 assets; physical device visual equivalence remains unverified. Filtered package is a nonproduction test artifact and optimization has NOT been integrated into a persistent release export preset.

R08-005: fresh import -> Daily 38/38, Economy 24/24, M33 Navigation 17/17 and smoke exit 0; repeated after temporary Android texture profile, same results. Existing UID fallback, missing icon, build-tools fallback are open warning items. Root TASKS.md, project.godot, gameplay and owner file hashes preserved by builder evidence.

M34 remains in progress. Next implementation priority: owner Android-device debug smoke on filtered artifact; create/review safe reproducible export preset with proven exclusions; Gradle dependency provenance and native AdMob debug compatibility without enabling production rewards. No app store deployment.
