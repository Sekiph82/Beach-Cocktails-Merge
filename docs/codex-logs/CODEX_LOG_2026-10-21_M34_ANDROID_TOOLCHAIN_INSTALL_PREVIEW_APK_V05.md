# Codex Execution Log — BCM-M34-006/007 V05

**Prompt:** `BCM_M34_ANDROID_TOOLCHAIN_INSTALL_AND_APK_BUILD_V05.md`

**Start HEAD after safe sync:** `f913190dbdb18a590a24438a2d42b62cd5875206`

**Implementation/evidence end HEAD:** `ec6eecf30bfe080cd42d6cfd66dffede8463a0b4`

**Branch / remote:** `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`

**Builder result:** `APK_BUILT_CONTENT_VERIFIED_WITH_SPARSEPCK_LIMITATION`

## Sync-first preflight

The canonical checkout began at `24153ed185fe8fac9a44c3589fe7b61d1489c906`, with no dirty tracked files and 11 pre-existing untracked owner paths. `origin/main` was `f913190dbdb18a590a24438a2d42b62cd5875206`; local main was 0 ahead / 3 behind. The incoming diff contained root `TASKS.md` and the V05 prompt, disjoint from all untracked paths. `git merge --ff-only origin/main` advanced cleanly to `f913190dbdb18a590a24438a2d42b62cd5875206`.

Pre-existing untracked paths were preserved and not staged:

- `_m32_validation/`
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/02_home_reference_941x1672 kritik.png`
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/owner-critique-v02/02_home_owner_critique_v02_941x1672 kritik.png`
- `coordination/sessions/BCM-M23-MASTER-V01/evidence/BCM-M23-CLOSEOUT-001/mobile_qa_initial_headless.txt`
- `coordination/sessions/BCM-M23-MASTER-V01/evidence/M23-R01/`
- `coordination/sessions/BCM-M26-MASTER-V01/evidence/M26-002/reduced_island_unlock_720x1440.png`
- `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05-R02/screenshots/720x1280/`
- `data/campaign/shop_catalog.json`
- `docs/codex-logs/CODEX_LOG_M23_R01_V01.md`
- `f647e4ff-b906-40e7-93f8-3c4b59d95b23.png`
- `tools/capture_godot_window.ps1`

Root `TASKS.md` was read after sync and was not edited. No branch, worktree, emulator, device, GitHub Actions run, cleanup, reset, stash, or rebase was used.

## Toolchain installation

- Checked only the documented JDK and existing SDK locations. The existing Android Studio JBR remained OpenJDK 25.0.3.
- Downloaded Temurin JDK 17.0.20.1+1 x64 MSI from the official Adoptium release. SHA-256 matched the official API checksum `a6013774c5e4a34951e11c1997d8b4641d2de7736d3eac839231f4266bd1116f`; Windows Authenticode status was `Valid`, signer `Eclipse Foundation`. Installed side-by-side at `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.1-hotspot` with MSI features for PATH/JAVA_HOME/registry/jar association excluded. `java -version` and `javac -version` both reported 17.0.20.1. User and machine PATH/JAVA_HOME do not reference the new JDK.
- Installed only `ndk;28.1.13356709` (r28b) and `cmake;3.10.2.4988404` into the existing Android SDK. The October 2026 `sdkmanager.bat` is a compatibility shim for Android CLI and accepts slash-form package paths. The initial legacy semicolon-form invocation returned “Package not found” and installed nothing; the slash-form invocation downloaded and installed only the two approved components. `source.properties`, NDK `clang --version`, and CMake `--version` confirmed the requested package versions.
- No Google SDK license prompt appeared. The pre-existing `licenses/android-sdk-license` file had last-write time `2026-10-15 11:59:51`; this run did not accept, edit, or rewrite any license file. The existing SDK manager completed the exact package install without requesting a new agreement.
- Other build tools: Godot `4.7.2.stable.official.ed1daf0bf`, Gradle `8.11.1`, Android Build Tools `36.1.0`, compile/target SDK 36.

Official JDK references used: [Adoptium Windows MSI installation guide](https://adoptium.net/installation/windows/) and the official [Temurin 17 Windows x64 release API](https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse).

## Files changed

- `export_presets.cfg` — added separate `Android M34 Preview APK (NOT SHIPPING)` preset. It reuses V04’s accepted lean runtime JSON includes/exclusions, selects APK output, arm64 only, min SDK 24 / target SDK 36, debug signing, package `com.sekiph82.beachcocktails.m34preview`, and version `0.0.0-m34preview-NOT-SHIPPING`. The Android store candidate identity and other presets were not changed.
- `docs/release/evidence/BCM_M34_ANDROID_PREVIEW_APK_V05_2026-10-21.json` — compact APK/toolchain/content verification manifest.
- This immutable execution log.

The APK and temporary inspection files remain under ignored `.godot/`. Godot generated four untracked `.gd.uid` sidecars during import (`scripts/campaign/settings_link_config.gd.uid`, `tests/m34_settings_link_probe.gd.uid`, `tools/release/capture_live_game.gd.uid`, `tools/release/capture_live_game_input.gd.uid`); they were not staged or committed. `project.godot` was temporarily given the required ETC2/ASTC import flag for export and restored byte-for-byte afterward. Its final diff is empty.

## Build and APK inspection

- First Godot export correctly stopped with `ETC2/ASTC texture compression is required for Android export`. The setting was enabled only while running the isolated Godot 4.7.2 import/export process, then original `project.godot` bytes were restored. The follow-up `--export-debug` completed with exit 0.
- APK: `.godot/bcm_release_preflight/android_preview_v05.apk`; 198,927,159 bytes; SHA-256 `126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b`.
- `aapt2 dump badging` confirmed package ID, version, target SDK 36, min SDK 24, `debuggable`, and `arm64-v8a`. Merged permissions contain only `android.permission.INTERNET`.
- `apksigner verify --verbose --print-certs` succeeded with APK Signature Scheme v2 and the Godot debug certificate; no production key was used. `zipalign -c -P 16 -v 4` reported `Verification successful`.
- APK native libraries are `lib/arm64-v8a/libgodot_android.so` and `lib/arm64-v8a/libc++_shared.so`. NDK `llvm-readelf -lW` showed every `LOAD` segment aligned at `0x4000` (16 KiB) in both libraries.
- APK has 1,056 expanded `assets/` files. All 1,049 paths in the independently accepted V02 Android PCK manifest were present; zero expected paths were missing and zero forbidden developer/source paths were found. Of those, 1,045 payload SHA-256 values match V02. Four expected differences are regenerated `.godot/global_script_class_cache.cfg`, `.godot/uid_cache.bin`, `project.binary`, and `scripts/campaign/application_shell.gdc`; the compiled application shell includes V04 Privacy/Support changes from commit `7d073fe`, after V02 evidence commit `61fc055`.
- The APK contains `assets.sparsepck` (109,908 bytes, Godot PCK v4 with pack flags `6` = relative file base plus sparse bundle), not a standalone `.pck`. The current release inventory parser fails closed on sparse PCKs. A standalone engine mount accepts the sparse pack but reports references to base APK assets that are unavailable outside the APK. Therefore sparse-index coverage remains **UNRESOLVED**; expanded asset paths and payload hashes were checked directly against V02 as above.
- APK-contained `ads_provider_policy.json` reports default off and all 7 placements disabled. Both store products remain non-buyable. AdMob runtime source is present as compiled GDScript; `apkanalyzer` found no native AdMob or billing package classes, and the APK has no AdMob/Billing native libraries. Existing AdMob source was preserved for future integration.

## Commands, tests and exact results

- Official MSI download verification — SHA-256 exact match and Authenticode `Valid` for Eclipse Foundation.
- Android SDK installation — exact NDK/CMake source revisions and executable checks passed; no license prompt or Codex acceptance.
- Godot headless editor import — exit 0.
- Godot Android preview APK export — exit 0 after the transient ETC2/ASTC setting; generated APK exists and is inspectable.
- `python -m unittest discover -s tests -p test_release_export_boundaries.py -v` — **15/15 passed**.
- `tools/run_isolated_godot_probe.ps1 -Probe tests/m34_settings_link_probe.gd` — exit 0, `M34_SETTINGS_LINK_PROBE_RESULT=PASS`.
- `tools/run_isolated_godot_probe.ps1 -Probe tests/m34_rewarded_ads_lifecycle_probe.gd` — exit 0, `M34_ADS_RESULT=PASS`.
- `python tests/run_regressions.py --strict-runtime-errors tests/m34_settings_link_probe.gd tests/m34_rewarded_ads_lifecycle_probe.gd` — runner stopped before probes because its discovery inventory does not classify the V04 settings-link probe. Direct isolated probe runs above passed. An earlier `--probes` spelling was rejected by the runner CLI; no test was run by that invocation.
- `aapt2` package/permission inspection, `apksigner` verification, `zipalign -P 16`, NDK `llvm-readelf`, APK asset-path/content comparison, monetization policy inspection, and DEX package search — passed except the sparse PCK independent index limitation noted above.
- `git diff --check` — passed after normalizing the JSON evidence file to LF.
- No emulator/device runtime launch, install, screenshot, or on-device 16 KiB runtime check was performed.

## Repository result and handoff

- Implementation/evidence commit `ec6eecf30bfe080cd42d6cfd66dffede8463a0b4` was pushed to existing `main`. At that push, `HEAD = origin/main = remote main = ec6eecf30bfe080cd42d6cfd66dffede8463a0b4` and divergence was `0/0`.
- The immutable log is a follow-up evidence commit; its exact SHA and post-log push parity are reported in the handoff because a commit cannot contain its own SHA.
- Pre-existing owner-local untracked paths were preserved. New `.gd.uid` sidecars and ignored build/APK files remain uncommitted. No owner path was staged.
- Explicit confirmation: root `TASKS.md` was not modified.
- Ads and purchases remain disabled for production. This debug APK is not a Play AAB, shipping package, store submission, native ad integration, or device acceptance. Independent ChatGPT audit remains required; the sparse PCK index and physical-device behavior are still unverified.
