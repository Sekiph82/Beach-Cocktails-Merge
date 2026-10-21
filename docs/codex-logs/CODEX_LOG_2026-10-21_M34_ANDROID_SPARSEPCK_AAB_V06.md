# Codex Execution Log — BCM-M34-006/007 V06

**Prompt:** `coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_ANDROID_SPARSEPCK_AND_AAB_PREFLIGHT_V06.md`

**Start HEAD after safe sync:** `83ee1fa` (full SHA recorded in Git history)

**Implementation/evidence commit:** `4f278c4c09eea73d859477fb5e127b6e35689794`

**Branch / remote:** `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`

**Builder result:** `SPARSEPCK_INDEX_PASS_AAB_CREATED_BUNDLETOOL_VALIDATED_GODOT_EXIT_ANOMALY`

## Sync-first preflight and preserved work

The canonical checkout was `main` at `771c226846ea56968ff00b06e1a56d5ee174a5fc`, with no modified tracked paths. `git fetch origin main` advanced the remote reference to `83ee1fa`; local main was 0 ahead / 3 behind. Incoming paths were root `TASKS.md`, the V06 prompt, and the V05 audit. None overlapped the complete inventoried untracked owner paths, so the authorized `git merge --ff-only origin/main` advanced to `83ee1fa` without stash, reset, rebase, worktree, or owner-file mutation.

All pre-existing untracked paths remained untouched, including `_m32_validation/`, M21/M23/M26/M33 evidence, `data/campaign/shop_catalog.json`, `docs/codex-logs/CODEX_LOG_M23_R01_V01.md`, the root UUID PNG, `tools/capture_godot_window.ps1`, and the four V05-generated `.gd.uid` sidecars. The two new V06 Python source/test files were staged explicitly. No owner-local path was staged.

`TASKS.md` was read after sync and was not modified. No APK/PCK cleanup, emulator, Android device, GitHub Actions, store account, public release, production key, or SDK license operation was performed.

## Sparse APK index verification

The version-pinned Godot 4.7.2 sources were reviewed: `core/io/file_access_pack.cpp` and `platform/android/export/export_plugin.cpp` at `https://github.com/godotengine/godot/tree/4.7.2-stable`. Runtime semantics open a sparse resource as a separate path after `res://` normalization; the PCK offset is not treated as an embedded contiguous payload interval. The directory's per-file MD5 values were independently recalculated against the APK asset bytes; SHA-256 was also recorded for every entry and folded into a sorted path/size/hash manifest.

Before inspection, the preserved V05 APK was rehashed: `.godot/bcm_release_preflight/android_preview_v05.apk`, 198,927,159 bytes, SHA-256 `126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b`.

`tools/release/inspect_sparse_android_apk.py` parsed the APK's `assets/assets.sparsepck`: PCK v4, Godot 4.7.2, flags 6, directory offset 104, 1,054 records. All 1,054 referenced external APK assets were present. **117,390,634 indexed payload bytes** matched recorded sizes and MD5 values; per-entry SHA-256 values were computed and the sorted path/size/SHA-256 manifest digest is `838b369cf39e46e1595dad8b50c1d877af8fe2f7bb44be371a01e700a25c4cb5`. There were zero missing paths, size differences, MD5 differences, forbidden indexed paths, or forbidden archive paths. Of 1,055 expanded APK assets (sparse index excluded), the sole unindexed asset was the expected Godot command-line flags file `assets/_cl_` (94 bytes, SHA-256 `d1074de3d76a1aa6a8b2635cb2b6c9856870a46ff0a995dc71ecf483f721cd6f`). APK ZIP integrity passed. Result: `SPARSEPCK_INDEX_PASS`.

The reader rejects encrypted/sparse directory forms it cannot inspect, entry encryption/removal/delta flags, unknown flags, invalid bounds/sizes/offsets, malformed/duplicate/case-colliding/traversal paths, missing referenced files, secret/private/test path classes, and forbidden unindexed APK archive entries. It reads files without extracting or modifying the APK.

## Preview AAB build and inspection

Added a distinct `Android M34 Preview AAB (NOT SHIPPING)` export preset at index 4 in `export_presets.cfg`. It uses the same runtime include/exclude filters and preview-only package/version as the V05 preview APK; output is ignored at `.godot/bcm_release_preflight/android_preview_v06.aab`. The V05 APK and Android store-candidate preset remain unchanged.

The already installed Godot 4.7.2 Android template and Gradle 8.11.1 built an AAB with the existing Temurin JDK 17 and Android SDK. No JDK, NDK, CMake, SDK component, or third-party tool was installed. A transient `textures/vram_compression/import_etc2_astc=true` setting was applied to `project.godot` for Android export and restored byte-for-byte in a PowerShell `finally` block.

**Export process limitation:** Gradle logged `BUILD SUCCESSFUL in 5s` and wrote the complete AAB. The Godot console process then remained alive without CPU activity. Its exact task ownership was confirmed by PID, parent PID, executable, and command line (`Godot_v4.7.2-stable_win64_console.exe` PID 29964, child of this export's PowerShell PID 7024, running the requested AAB preset). That process alone was stopped so the `finally` block could restore `project.godot`; the wrapper returned `-1`. The resulting AAB was independently opened and validated successfully with cached official `bundletool` 1.16.0. The wrapper's nonzero exit is retained as an evidence limitation and is not represented as a clean Godot exit.

AAB: 147,028,717 bytes; SHA-256 `b22ba20b3ff1bf5b3b77f9077f7a67b9783b1e3e8d44581fcbca90bab3985c15`; ZIP integrity and `bundletool validate` passed. The bundle contains base module `base` and install-time asset pack `assetPackInstallTime`. The base manifest reports `com.sekiph82.beachcocktails.m34preview`, label `Beach Cocktails Merge M34 Preview`, version `0.0.0-m34preview-NOT-SHIPPING`, min SDK 24, target SDK 36, debuggable true, icon resource `mipmap/icon`, and only `android.permission.INTERNET`. The bundle icon resource and icon density variants were present.

The install-time asset pack has the same 1,054 indexed resources, with zero missing/size/MD5 differences and the same sorted path/size/SHA-256 manifest digest as the APK. Its only unindexed asset is `_cl_`. Neither APK nor AAB contained forbidden coordination, docs, tests, tools, backend, Godot AI/editor, secret, or private-key path classes. BundleConfig declares uncompressed native libraries with `PAGE_ALIGNMENT_16K`; both `arm64-v8a` ELF64 libraries have every PT_LOAD alignment equal to 16,384 bytes. DEX search found no native AdMob or Play Billing SDK classes.

Ads policy remained default-off with all seven placements disabled; both store products remain nonbuyable. Future AdMob project source remains preserved. No production keystore or upload key was used; this debug/nonshipping AAB is not Play-upload-approved.

## Files changed

- `tools/release/inspect_sparse_android_apk.py` — read-only, fail-closed sparse APK index and external asset verifier.
- `tests/test_sparse_android_apk.py` — nine targeted parser regressions.
- `export_presets.cfg` — separate preview-only AAB preset.
- `docs/release/evidence/BCM_M34_ANDROID_SPARSEPCK_V06_2026-10-21.json` — APK sparse index and AAB evidence.
- This immutable execution log.

No runtime gameplay or AdMob implementation was changed. Root `TASKS.md` was not modified.

## Focused commands and results

- `python -m unittest tests.test_sparse_android_apk -v` — **9/9 passed**. Covers valid index; invalid header and truncated directory; missing external reference; same-size mutated payload; duplicate and traversal paths; forbidden indexed and unindexed test/secret paths; unsupported entry flags.
- `python tools/release/inspect_sparse_android_apk.py .godot/bcm_release_preflight/android_preview_v05.apk --summary-only` — **SPARSEPCK_INDEX_PASS**.
- Python ZIP integrity checks for V05 APK and V06 AAB — **PASS**.
- Cached `bundletool 1.16.0 validate --bundle android_preview_v06.aab` — **PASS**.
- `bundletool dump manifest`, `dump resources`, and `dump config` — package/label/version/SDK/permission/icon and 16 KiB metadata inspected.
- AAB sparse asset comparison, payload hash/size checks, APK DEX native-class search, and ELF PT_LOAD inspection — **PASS**.
- `git diff --check` — **PASS**.
- V05 APK SHA-256 after AAB export remained exactly `126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b`.
- No emulator, device, GitHub Actions, user save, Play Console, public store, production signing, SDK license acceptance, or installation was used.

## Release handoff and limits

Public Android and iOS release remain **NO-GO**. Before a Play shipping conversion, the owner must select and lock the final immutable application ID; configure owner-held Play App Signing and upload key; complete real Android developer-device verification; approve store icons, real-device screenshots and feature graphic; publish approved public HTTPS privacy/support URLs; complete Play policy/data-safety declarations; and meet the applicable closed-test eligibility requirements. Do not create accounts or keys as part of this preview task.

The generated AAB is a debuggable local preview candidate, not a signed production artifact, Play acceptance result, or device-tested build. Native AdMob, store billing, and trusted SSV remain unimplemented; no live ad requests, purchases, or rewards were tested. The successful Gradle task and bundletool validation are usable build evidence despite the non-clean Godot wrapper exit; independent ChatGPT review remains required.

The implementation/evidence commit is `4f278c4c09eea73d859477fb5e127b6e35689794`. The immutable log was published in a subsequent commit; that final repository SHA and the post-push `HEAD = origin/main = remote main` check are recorded in the handoff.
