# BCM-M34-R09 Slim Android Export / AdMob / Device Builder Log V02

- Work item: `BCM-M34-R09-001..005`.
- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R09_SLIM_EXPORT_AND_NATIVE_ADMOB_MASTER_PROMPT.md`.
- Prompt version: R09, including the owner override dated 2026-10-15 to defer physical Android testing and continue offline work.
- Start HEAD: `c37ee4cd8b9958d38d7cd745970bd94be2358fe0`.
- End HEAD before this evidence commit: `c37ee4cd8b9958d38d7cd745970bd94be2358fe0`.
- Checkout: detached isolated worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; no branch created.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync preflight: canonical Desktop checkout had synchronized to origin/main before task work; `HEAD...origin/main` was `0 0`. Incoming R09 commits were path-disjoint from seven tracked and fifteen untracked owner-local paths. The standing safe-sync procedure preserved those paths; they were not staged or edited here. This isolated worktree starts at synchronized origin/main, with `HEAD...origin/main` `0 0`.
- `TASKS.md`: read-only; not modified or staged.

## Work and evidence

- Existing persistent preset remains `Android Production-Targeted Slim Debug (Nonshipping)`, package `org.example.bcm.r09slimdebug`, version `0.0.0-r09-nonshipping`, using only the three R08-proven exclusions: `coordination/**`, `assets/ui_assets/source/**`, and `assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png`.
- Re-exported the preset with Godot 4.7.2 from the isolated worktree. A first attempt correctly failed because Android ETC2/ASTC import was disabled. A temporary `textures/vram_compression/import_etc2_astc=true` setting enabled the export; Godot's generated GameFeelFlow UID rewrite and the temporary setting were restored. Final `project.godot` diff is empty.
- New slim APK is external to Git at `C:\Users\sekip\AppData\Local\BCM-M34-R09-V02-Evidence\BCM_R09_Slim_Nonshipping_Debug_V02.apk`: exit `0`, 301,983,466 bytes, SHA-256 `4E00378E3E47843A1B1E8585EBFE6F5B44B50996AF9F6BD0F7D60A9800FCCCC2`. This matches the R09 V01 byte size and +4,293-byte / +0.0014% delta from the 301,979,173-byte R08 filtered baseline. Its SHA-256 differs from V01; both APKs use the same debug signing certificate, so byte-for-byte deterministic output is not claimed.
- AAPT `dump badging` exited `0`; package/version/SDK metadata match the preset. APK contains 2,161 entries; zero coordination, UI source-art, or contact-sheet entries; ten imported gameplay surfaces; ten R04 profiles; ten canonical island level files plus the separately retained `tiki_island_full.json`; twelve L01-L12 imports; four HUD panel imports; and ApplicationShell. Dynamic content probe validates all 1,000 canonical records. `apksigner verify --verbose` exited `0`; v2 and v3 schemes verified. Build-Tools 36.1.0 was used. Godot emitted the existing missing-project-icon warning; no icon asset was invented.
- Fresh import ran with `godot --headless --editor --path <isolated-worktree> --quit`, exit `0`. Captured output records 1,688 import steps. Existing stale scene UID text-path fallbacks and empty locale warnings remain.
- Post-import focused checks, each exit `0`: `tests/m34_r09_slim_export_content_probe.gd` (PASS, all 1,000 campaign records and dynamic resource paths), `tests/m34_daily_rewards_probe.gd` (38/38), `tests/m34_economy_closure_probe.gd` (24/24), `tests/m33_campaign_navigation_probe.gd` (17/17 across ten islands), and headless application startup smoke (`--quit-after 3`). Full stdout/stderr files and the machine-readable result summary are in `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R09/`.
- In the strictly isolated test project, Godot 4.7.2 invoked the AdMob Android export hook. Plugin 7.0 and Gradle 8.11.1 resolved direct dependencies `androidx.appcompat:appcompat:1.7.1`, `androidx.lifecycle:lifecycle-process:2.8.3`, and `com.google.android.gms:play-services-ads:24.9.0`; the merged manifest shows Ads API 24.9.0 and Ads Identifier 18.0.0. Six selected module-version folders total 8,050,246 bytes (a scoped subtotal, not the full Gradle/SDK cache). Native test APK export exited `0`, size 96,310,569 bytes, SHA-256 `BEA85F2B25AD5E1EABA7B344863803B8168E259073A122F91406387E537C770F`, package `org.example.bcm.r09admobtest`; AAPT and v2 signature verification passed. The APK includes the AdMob plugin and Google Ads classes. Harness uses Google's sample app ID only, initializes only after acceptable consent, and grants no product currency. The harness source and captured export logs are retained as R09 evidence.
- Process toolchain: Godot 4.7.2; Android SDK/JDK installed for this project; old generated Gradle/template output and cache directories were preserved rather than deleted.
- Owner override state: physical Android install, runtime, consent UI, ad playback, logcat, screenshots, and mobile visual review were not performed. R09-003 is `DEFERRED_BY_OWNER_NOT_DEVICE_VERIFIED`; no ADB/device permission or follow-up is requested in this cycle.

## Commands and exact outcomes

- Fresh import: `godot --headless --editor --path <isolated-worktree> --quit` — exit `0`.
- Slim export: `godot --headless --path <isolated-worktree> --export-debug "Android Production-Targeted Slim Debug (Nonshipping)" <external-apk>` — first attempt exit `1` with the ETC2/ASTC setting requirement; retry with temporary isolated setting exit `0`.
- APK metadata: Android `aapt.exe dump badging <apk>` — exit `0`; Android `apksigner.bat verify --verbose <apk>` — exit `0`, v2/v3 verified.
- Content, Daily, Economy, M33 Navigation, startup smoke — exits `0`; results above and raw captures under `evidence/M34-R09/`.
- Native AdMob export: Godot `--export-debug "R09 AdMob Native Test Only" <external-test-apk>` with process-scoped Android SDK/JDK environment — exit `0`; AAPT and apksigner v2 verification exit `0`.
- `git diff --check` — PASS.

## Scope and limitations

- No production scripts, scenes, campaign/economy data, visual assets, export preset, or project settings are changed by V02. APKs and generated caches remain outside Git. Root `TASKS.md` remains unchanged.
- No active Focus feature, timer behavior, or paid-reward callback was introduced. Existing production policy keeps rewards unavailable without a trusted provider/receipt. The offline AdMob test harness cannot satisfy release SSV, production monetization, or phone runtime gates.
- Remaining warnings: unconfigured project icon, two stale scene UID fallbacks, and three empty translation locales. Package size repeated exactly, but APK hash changed from V01 despite the same debug certificate; byte-reproducibility cause is not isolated.
- No owner visual acceptance, physical-device acceptance, or independent milestone audit is claimed.

## Repository state and handoff

- Files changed are limited to this V02 log and new R09 V02 evidence/log captures.
- `TASKS.md` was not modified.
- Final commit SHA: recorded in the repository commit for this log/evidence package and in the completion handoff.
- Required stop marker: `AWAITING_GPT_M34_R09_INDEPENDENT_AUDIT_AND_OWNER_ANDROID_DEVICE`.
- Independent ChatGPT audit and any tracker transition remain pending.
