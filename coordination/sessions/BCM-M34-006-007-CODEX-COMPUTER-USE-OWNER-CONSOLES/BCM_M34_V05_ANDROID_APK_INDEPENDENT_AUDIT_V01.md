# BCM-M34-006/007 — V05 Android APK Independent Audit V01

Date: 2026-10-21. Reviewer: ChatGPT. Builder source/result head: `771c226846ea56968ff00b06e1a56d5ee174a5fc`; product/evidence code commit `1510d062f765b7682e604878dbca2c35e8cab372`, normalization commit `ec6eecf30bfe080cd42d6cfd66dffede8463a0b4`, log commit `771c226846ea56968ff00b06e1a56d5ee174a5fc`. Evidence: `docs/release/evidence/BCM_M34_ANDROID_PREVIEW_APK_V05_2026-10-21.json`, `docs/codex-logs/CODEX_LOG_2026-10-21_M34_ANDROID_TOOLCHAIN_INSTALL_PREVIEW_APK_V05.md`. Historical audit, NOT a competing live tracker; root `TASKS.md` alone is authoritative.

## VERDICT

**CONDITIONAL PASS: V05 Android nonshipping preview APK generated and OS/toolchain blockers resolved according to builder evidence.** Independent GitHub source review confirms the new preview-only Android export preset and published manifest/log. The actual APK binary lives in an ignored local Windows directory, not available to the reviewer for an independent checksum, ZIP, sparse index, signature or device run. **DO NOT CALL THIS A SIGNED PRODUCTION APK/AAB OR A RELEASE ACCEPTANCE**. Sparse PCK directory-versus-external-APK asset accounting is still open. Both stores remain **NO-GO**, M34-006/007 **BLOCKED**, canonical 146/148 unchanged.

## CONTRACT / BRANCH / SCOPE

- GitHub main was independently fetched at builder head `771c226...`. Compare from ChatGPT-owned prior head `f913190...` shows exactly 3 commits adding only `export_presets.cfg` preview preset, an immutable APK verification JSON and an immutable builder log. Codex did not change root `TASKS.md`. Builder reports owner untracked/dirty paths preserved, with 4 new Godot-generated UID files deliberately left untracked.
- Existing Apple and Android **store candidate** profiles were not intentionally replaced; `preset.3` is `Android M34 Preview APK (NOT SHIPPING)`, `com.sekiph82.beachcocktails.m34preview`, version `0.0.0-m34preview-NOT-SHIPPING`, Gradle APK, arm64 only, min SDK24, target SDK36, export filter matching previously accepted lean candidates, debug signing. This distinct preview identity is correct; no Play release identity change.
- Initial Android export blocked on ETC2/ASTC; builder says required setting temporarily enabled and `project.godot` restored byte-for-byte. GitHub diff supports no tracked `project.godot` change. Ads and purchase catalogs remain OFF.

## SOURCE-VERIFIABLE BUILDER ARTIFACT RECORD

- APK reported at local ignored `.godot/bcm_release_preflight/android_preview_v05.apk`; **198,927,159 bytes**; **SHA256 `126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b`**; no GitHub remote artifact was published. These are **builder-supplied** numbers, not independently re-hashed binary evidence.
- Manifest reports `aapt2` package `com.sekiph82.beachcocktails.m34preview`, version and target API36/min24; Android debug signing verified APK signature scheme v2; only INTERNET permission; arm64-v8a, `libgodot_android.so` and `libc++_shared.so` native ELF LOAD align 0x4000, `zipalign -P 16` PASS. These checks are **builder-reported**, not re-executed by ChatGPT.
- Builder reports 1,056 APK-expanded `assets/` entries; all 1,049 accepted V02 PCK file paths present (0 missing, 0 forbidden development paths), 1,045 payload hashes matching V02 and 4 explained differences (3 regenerated engine caches/binary, 1 V04 application shell compiled script). This is useful partial coverage. The new `settings_links.json` and compiled code are among extras/differences, consistent with V04.
- All 7 ad placements OFF, store products `buyable=false`, no AdMob native SDK or Play Billing classes, future AdMob runtime source preserved. This **does not** certify future monetized ad/SSV or billing.
- Installer evidence reports official signed Eclipse Temurin **JDK 17.0.20.1+1** side-by-side with JDK25, official NDK **28.1.13356709**, CMake **3.10.2.4988404** in approved SDK, per-process JDK selection only; Authenticode and official checksum checks reported. SDK accepted only exact allowed packages; installation license prompt **did not appear** and builder says no license file touched. The owner's prior approved installation scope was not broadened.

## MAJOR REMAINING TECHNICAL GAP: ANDROID sparse PCK index

The APK stores expanded `assets/` plus `assets.sparsepck` (109,908 bytes, Godot PCK v4 flags **6**, relative file base + sparse bundle). The existing standalone PCK parser `tools/release/pck_directory.py` **intentionally rejects sparse bundles**. Therefore V05 **did not independently validate the sparse directory**. A Godot engine mount of that sparse index outside its APK asset context cannot verify the asset bytes, because sparse bundles dereference external project-relative resources.

Godot's `file_access_pack.cpp` distinguishes sparse `PACK_SPARSE_BUNDLE` paths from ordinary in-PCK payloads and opens referenced files from an external directory rather than an embedded offset (see `core/io/file_access_pack.cpp` in the version-matched Godot source). A faithful standalone ZIP-aware sparse inspector should parse every directory record, reject unexpected flags/paths, map references to the APK's expanded `assets/` entries, verify every referenced external ZIP entry exists and that its bytes/checksum match the sparse directory record under actual Godot semantics. Verify exact Godot 4.7.2 format and whether MD5 fields are intended for every sparse referenced payload; **do not assume** sparse index is a conventional PCK file with internal payload intervals. Include negative tests for path traversal, duplicates, missing/altered ZIP assets, invalid flags, forged checksum, unindexed extra assets and source-leak forbidden paths; add a bounded real APK inspection report. If semantic accounting is incomplete, stay fail-closed `SPARSEPCK_INDEX_UNVERIFIED`.

This is not permission to revisit previously accepted Android/iOS V02 1,049-entry PCK cleanup or broadly delete other assets. Priority is ONE precise sparse external-reference check, then proceed to genuine Play AAB toolchain preparation.

## FOCUSED TEST AND SAFETY REVIEW

Builder-reported 15/15 Python boundary tests PASS, Settings link probe PASS, Ad lifecycle probe PASS; full two-probe strict runner **did not execute** due to discovery classification. Do not claim strict runner passed. No emulator, phone, device install, Google Actions, production signing, store app creation, public Ads/Billing or actual SSV/receipt testing. Owner real Godot save `user://campaign_save.json` never authorized for access, historical uncertainty preserved. Existing iPhone BAT/XTool and IPA/APK remain protected.

## NEXT RELEASE GATES

1. Codex: ONE bounded APK sparse-index/external-asset forensic acceptance; optionally produce **nonshipping AAB preview** under separate synthetic package/debug identity and verify metadata/contents if feasible with already installed tools, avoiding store and production signing. Do not falsely call an unsigned/debug AAB Play-ready.
2. High-quality store icon visual approval (1024 Apple/512 Play), stable non-tutorial game screenshots/device display QA, Play feature graphic, signed-install mobile validation. Keep Google physical-device verification on owner only (no emulator). Installed Android toolchain now **ready for local Android export**.
3. Public privacy/support URLs, real controller/contact/retention/age/data safety review and OS/network SDK inventory, APP Store Connect actual app and App ID record (previous inspected team Apps empty), iOS macOS/Xcode26 signed archive/TestFlight, future AdMob/StoreKit/Play native integration and provider-verification/backends after approvals.

**FINAL:** V05 real APK accomplishment **CONDITIONAL PASS**, sparse bundle audit unresolved, public release **NO-GO**, canonical 146/148 unchanged.
