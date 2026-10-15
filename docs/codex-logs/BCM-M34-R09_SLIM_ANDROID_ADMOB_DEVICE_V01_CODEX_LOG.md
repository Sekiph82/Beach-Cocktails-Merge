# BCM-M34-R09 Slim Android Export / AdMob / Device Builder Log V01

- Work item: BCM-M34-R09-001..005
- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R09_SLIM_EXPORT_AND_NATIVE_ADMOB_MASTER_PROMPT.md`
- Start HEAD: `1c6dc333c193bd02277c7c5fc9e754a4e3a1bcf6`
- End implementation/evidence HEAD: `d6962b321a05ffadba49b3960d15f39baae638bf`
- Worktree: isolated managed checkout at `C:\Users\sekip\.codex\worktrees\bcm-m34-r09\Beach Cocktails - Merge`, detached at synchronized `main`; no branch created.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Preflight: fetched `origin main`; `git rev-list --left-right --count HEAD...origin/main` = `0 0` before implementation commit.
- Canonical Desktop owner paths: the prior safe-sync inventory covered 7 modified tracked and 15 untracked paths. Hashes were preserved across sync. No canonical owner-local path was edited or staged by this task.
- `TASKS.md`: not modified or staged; its synchronized origin content remained the read-only project tracker.

## Changes

- Added persistent Android preset `Android Production-Targeted Slim Debug (Nonshipping)` in `export_presets.cfg`, using only the three R08-proven exclusions: `coordination/**`, `assets/ui_assets/source/**`, and `assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png`. The preset uses distinct package id `org.example.bcm.r09slimdebug`, nonshipping version, debug signing, and internet permission. Full source art/evidence remain in Git.
- Added `tests/m34_r09_slim_export_content_probe.gd`: dynamically validates the campaign manifest's 1,000 level records, ten canonical island IDs and their map/gameplay assets/R04 profiles, L01-L12, ApplicationShell, and repository-resident contact-sheet source.
- Added R09 evidence in `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R09/`.
- No production gameplay, campaign, economy, asset, or `project.godot` changes. `project.godot` was temporarily changed only in this isolated worktree to run the Android ETC2 import profile; it was restored byte-for-byte before staging. No generated UIDs, APKs, `.godot`, or local caches were staged.

## Commands and results

- Godot 4.7.2 fresh editor import after enabling the Android ETC2/ASTC import profile in the isolated checkout: exit 0. Existing invalid scene UID references for `WorldMapScene.tscn` and `main.tscn` fell back to text paths; no parse/import failure.
- R09 dynamic slim-export content probe after import: PASS; CampaignContentManifest validated all 1,000 records, ten island entries and runtime resource paths resolved, L01-L12 resolved, ApplicationShell loaded, and contact-sheet source stayed available in the repository.
- Daily Rewards regression: 38/38 PASS.
- Economy closure regression: 24/24 PASS.
- M33 navigation regression: 17/17 PASS across ten islands.
- Main-scene startup smoke: exit 0. Existing autoload diagnostics and the two UID fallback warnings are in the captured log.
- R09 slim debug Android export: exit 0 with Godot 4.7.2. APK is outside Git at `C:\Users\sekip\AppData\Local\BCM-M34-R09-Android-Export\BCM_R09_Slim_Nonshipping_Debug.apk`; 301,983,466 bytes; SHA-256 `D38AC083933D60E6B18A63CEEF708B3AC6C78575D2F3A99DD01B4C13C7C4694C`. This is +4,293 bytes / +0.0014% versus the R08 filtered 301,979,173-byte baseline.
- `aapt dump badging`: exit 0; package `org.example.bcm.r09slimdebug`, version `0.0.0-r09-nonshipping`, min SDK 24, target SDK 36. Package inventory has no excluded coordination/source-art/contact-sheet entries; ten canonical level files and all 1,000 records validated; ten gameplay surfaces, ten geometry profiles, twelve cocktail imports and required HUD assets present. One additional `tiki_island_full.json` is retained in the APK and is separate from the ten canonical manifest files.
- `apksigner verify --verbose`: exit 0; v2/v3 signature verified. The export selected SDK Build-Tools 35.0.1 as a fallback while target SDK 36 was requested. Godot warned that no project icon was configured; the default Android icon resources were present. No owner art was invented.
- Android ADB check: `adb devices -l` returned only `List of devices attached`; no authorized device was listed. `NOT_DEVICE_VERIFIED`. No install, gameplay-on-phone, logcat, screenshot, or device performance check was performed.
- Gradle wrapper: official Gradle 8.11.1 distribution downloaded into task-specific `C:\Users\sekip\AppData\Local\BCM-M34-R09-GradleHome`; ZIP SHA-256 `F397B287023ACDBA1E9F6FC5EA72D22DD63669D59ED4A289A29B1A76EEE151C6`; isolated Gradle home after template build 1,299,312,857 bytes. `gradlew assembleDebug --no-daemon`: BUILD SUCCESSFUL, 104 tasks. This was the vanilla Godot Android template, not an AdMob-exported project. It installed Android SDK Platform 36 (106,195,794 bytes) and Build-Tools 36.1.0 (144,142,253 bytes) additively. C: remained above 40 GiB free.
- AdMob test project import: exit 0; app test config is `is_real=false` with Google's sample app ID. The R08-pinned plugin lists AppCompat 1.7.1, Lifecycle Process 2.8.3, and Play Services Ads 24.9.0. These Maven coordinates were not present in the R09 Gradle cache after the vanilla template build. No AdMob-native test APK was built: this shell could not resolve `godot` from PATH and no Godot AI editor session was registered, so the Godot export hook was not invoked. Plugin AAR discovery, Maven cache footprint, and native AdMob APK are UNVERIFIED; details and precise next step are in `evidence/M34-R09/admob_native_build_boundary.md`. The native template APK at `C:\Users\sekip\AppData\Local\BCM-M34-R09-AdmobTestProject\android\build\build\outputs\apk\standard\debug\android_debug.apk` is not evidence of AdMob integration.
- Focus/timer preservation inspection: no active Focus UI/item added; legacy Focus is retired by economy migration tests. Production level data has no positive `time_limit_sec`; session config is `time_limit_sec=0.0`, `timer_configured=false`. MOVES/tutorial and gameplay/economy/navigation content were not changed. This is source/regression evidence only.
- `git diff --cached --check`: PASS. Staged scope contains the R09 preset, content probe, R09 evidence, and this execution log only; no tracker or `project.godot` edits.

## Manual checks

- Performed: source/reference scan found no `res://` references to the three excluded roots under addons, data, scenes, scripts, or `project.godot`; package inventory inspection; APK badging/signature inspection; disk-space checks; local Android SDK/Gradle footprint checks.
- Not performed: physical Android installation, in-game touch/tutorial review, screenshots, logcat, owner visual acceptance, AdMob SDK initialization on Android, consent form display on device, or production/release monetization validation.

## Known limitations and owner action

- To continue device testing, keep the phone unlocked and USB-connected in File Transfer mode. Accept the separate Android `Allow USB debugging?` computer/RSA prompt (optionally check “Always allow from this computer”). Then `adb devices -l` must list the phone as `device`; it currently does not.
- To finish native AdMob validation, run the isolated R09 AdMob test preset from a Godot 4.7.2 editor/CLI with the Android export template installed. Keep Google test IDs, consent gating, and no client-side product currency grant; inspect generated Gradle dependencies and the resulting APK. Recheck free disk before downloads and keep the minimum 25 GiB reserve.
- No live ad IDs, production payouts, or SSV release-gate changes were used. Native AdMob/device acceptance remains incomplete; this log does not claim milestone acceptance.

## Repository evidence and handoff

- Implementation/evidence commit: `d6962b321a05ffadba49b3960d15f39baae638bf`.
- Builder stop marker: `AWAITING_GPT_M34_R09_INDEPENDENT_AUDIT_AND_OWNER_ANDROID_DEVICE`.
- `TASKS.md` was not modified. Independent ChatGPT audit and tracker ownership remain pending.