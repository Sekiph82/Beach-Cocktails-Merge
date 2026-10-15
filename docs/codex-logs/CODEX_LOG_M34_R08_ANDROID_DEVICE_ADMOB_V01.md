# Codex Log — BCM-M34 R08 Android Device and AdMob Readiness V01

## Scope and stop marker

- Active prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R08_ANDROID_DEVICE_ADMOB_TEST_MASTER_PROMPT.md`.
- Scope: R08-001 through R08-005; connected-device check, isolated AdMob v7.0 feasibility, SSV trust boundary, nonproduction APK size investigation, and fresh-import-before-regression confirmation.
- Required handoff marker: `AWAITING_GPT_M34_R08_INDEPENDENT_AUDIT_AND_OWNER_DEVICE_REVIEW`.
- Root `TASKS.md` was read-only. No gameplay, economy, campaign, production plugin, project configuration, asset source, or test source was changed.

## Sync preflight and owner data

- Canonical Desktop preflight began at `aa164691abc8aeb9223d3100937b8a42d3128782`, branch `main`, 0 ahead / 3 behind after fetching `origin/main` at `afaaeecb1d64e2b12e77673f23c9f87771b67323`.
- Incoming paths were only `TASKS.md`, the R07 independent audit, and this R08 prompt; all were disjoint from the seven modified tracked owner files and fifteen untracked owner files.
- Applied the required path-disjoint safe-sync procedure using the tracked-only stash `owner-local-safe-sync-aa16469`; no untracked files were stashed. All seven tracked owner-file hashes matched their pre-sync values, all fifteen untracked owner-file hashes matched, the working tree matched the new stash, and no owner path was staged. The pre-existing 75 stashes were retained; stash count is now 76 due to this required preservation stash.
- Read synchronized `AGENTS.md`, `TASKS.md`, this prompt, the R07 audit, and the R07 builder log. Active task is `BCM-M34-006`; no separate R08 criteria file was linked.
- Work ran in a detached non-Desktop worktree at `C:\Users\sekip\.codex\worktrees\bcm-m34-r08`, starting at `afaaeecb1d64e2b12e77673f23c9f87771b67323`. Remote is `origin`; no branch was created.
- `TASKS.md` matched the starting commit blob and was never modified, staged, or committed by Codex.

## R08-001 — Android device check

- Used the installed ADB at `C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\sdk\platform-tools\adb.exe`; ADB 1.0.41 / platform-tools 37.0.1.
- `adb devices -l` exited 0 and reported an empty device list. No install, device-setting change, logcat session, screenshot, touch test, or device permission request occurred.
- Rehashed the existing R07 debug APK before considering installation: `1,353,331,251` bytes, SHA-256 `EDDDDB44CBEFF9FA8C653BEB6621C6168D4D948B66C14559C7D91D5F580A93F5`. It matches the locked prompt hash. The host had 82.68 GB free at the check.
- Result is `NOT_DEVICE_VERIFIED`. Owner action: connect an Android device with USB debugging enabled, accept its ADB authorization prompt, and rerun `adb devices -l` until it reports state `device`.

## R08-002 — Native AdMob feasibility

- Reused the locally available official AdMob Android v7.0 archive; no download was made. Archive SHA-256 is `CE38B75AEB4BB870FDA8B74E1513D807696D8485D237C263B7B7A9613493AEE8` (265,845 bytes), tag commit `4b4ddceab0be81f0dcb12a6313038dba6cf9eacf`.
- Static inspection found debug/release AARs and the v2 export plugin. The declared Android dependencies are `androidx.appcompat:appcompat:1.7.1`, `androidx.lifecycle:lifecycle-process:2.8.3`, and `com.google.android.gms:play-services-ads:24.9.0`. The official release says it supports Godot 4.7; upstream issue #124 is open and reports v7.0 initialization failure on Godot 4.7. The reporter suspected AAR discovery and described manually copying the AAR under `android/build/bin`.
- An isolated project at `C:\Users\sekip\AppData\Local\BCM-M34-R08-AdmobTestProject` imported successfully (exit 0) and desktop-smoked (exit 0) with ads disabled and only Google's sample app ID; the desktop process correctly reported no Android `AdmobPlugin` singleton. No production identifiers, ad units, or account were used.
- First Android export attempt exited 1 because the isolated project had no project-local Android Gradle template. The already installed `android_source.zip` was copied into this external test project only. Its Gradle wrapper requires Gradle 8.11.1; the wrapper distribution and all three Maven dependencies above are absent from the local Gradle cache. No large download was started. AAR discovery, Android plugin build, runtime initialization, callbacks, and ad lifecycle remain `UNVERIFIED`; no AdMob APK was produced.

## R08-003 — SSV production boundary

- Reviewed the existing R05 plugin API evidence and R06 SSV blueprint. Static plugin APIs expose `LoadAdRequest.set_custom_data()` / `set_user_id()` and the AAR contains SSV custom-data references; that does not prove live SSV delivery.
- The native `rewarded_ad_user_earned_reward(ad_info, reward_data)` client signal is not an SSV receipt and does not expose a cryptographically verified transaction ID. It must not directly authorize production Coins, Gems, or Energy. The handoff maps the safe path: authenticated claim nonce in `custom_data`, verified raw-query SSV callback and durable idempotent server ledger, then authenticated client entitlement reconciliation.
- Existing `node --test tests/backend_protocol/m34_r06_ssv_backend_mock.test.js` exited 0 (8/8). It uses ephemeral local ECDSA keys and in-memory state; it is not a live Google callback or production backend. No backend host, account contract, callback registration, production ad unit, consent/age ruling, or paid deployment was selected. Production payouts and IAP remain disabled.

## R08-004 — APK size and nonproduction export

- Central-directory inspection of the R07 APK found 5,704 entries, 1,286,299,358 bytes across 1,659 `.ctex` entries, and 2,399 coordination entries. The dominant issue is the all-resources export carrying historic coordination/evidence images and reference material.
- Runtime-source scans found no references to the excluded paths/names. A nonproduction export preset excluded only `coordination/**`, `assets/ui_assets/source/**`, and `assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png`. These are export-only filters; no project art, source, documentation, or owner file was deleted.
- Same-flag unfiltered control export: 1,353,363,654 bytes, SHA-256 `F5AB02F20A05726723C9DB1992962727B4D76898297079BA2FD3580E0D5F4241`, within 32,403 bytes of the R07 APK. Filtered nonproduction debug APK: 301,979,173 bytes, SHA-256 `D4BC7647608ADBC583D7669EB0D6789B9641CDD5AC9D9A154F8A6D55247998E3`; reduction 1,051,384,481 bytes / 77.69% from the same-flag control.
- The filtered APK badging identifies package `org.example.bcm.r08sizetest`; AAPT exited 0 and `apksigner verify` exited 0 (v2/v3 verified). Static package checks found the main scene, all ten gameplay surfaces, all ten R04 geometry profiles, L01-L12, logo, HUD panels, progression strip, and danger line.
- Focused tests and startup smoke passed after the texture-import profile change. The APK was not installed or visually/device-tested, so image quality and owner visual acceptance remain open. Export still reports the missing project icon, build-tools fallback to 35.0.1, and the existing stale scene UID fallbacks.

## R08-005 — Fresh import and regression

- In the isolated worktree, a fresh Godot 4.7.2 editor import exited 0 and created global class cache SHA-256 `6C4941C2A9EA7D7ECFB82D15E89347E50C7A8F5916A677140DBAE9E4DDB57022`.
- Only after import, ran `tests/m34_daily_rewards_probe.gd` (38/38, exit 0), `tests/m34_economy_closure_probe.gd` (24/24, exit 0), `tests/m33_campaign_navigation_probe.gd` (17/17, exit 0), and headless startup smoke (`--quit-after 3`, exit 0). Godot user data was redirected to the task-specific `BCM-M34-R08-GodotUser` directory.
- Repeated the same four checks after the temporary Android texture-import profile: import 0, Daily 38/38, Economy 24/24, Navigation 17/17, smoke 0. The temporary `project.godot` import flag and editor-generated GameFeelFlow UID rewrite were restored to the starting commit; the temporary root export preset was removed. No production source or preset remains changed.

## Changed files, publication, and builder limits

- Evidence commit: `d0f30d17528dccde5176145c5d100ee1cefa32bc` (`docs(m34): capture R08 Android device and AdMob readiness`), containing only `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R08/**`.
- This log is a documentation-only follow-up commit. R08 APKs remain under local AppData and were not committed. The plugin test project remains isolated under AppData; it was not copied into product `addons/`.
- `TASKS.md` was not modified. Independent audit, physical Android install/visual acceptance, native AdMob build/runtime, production SSV, store/IAP, and release signing were not performed.
- Before claiming completion, push both commits without force and verify `HEAD`, `origin/main`, and remote `refs/heads/main` equality. Final stop marker remains `AWAITING_GPT_M34_R08_INDEPENDENT_AUDIT_AND_OWNER_DEVICE_REVIEW`.
