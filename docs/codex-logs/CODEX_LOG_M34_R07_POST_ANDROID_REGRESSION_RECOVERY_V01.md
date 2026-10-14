# Codex Log — BCM-M34 R07 Post-Android Regression Recovery V01

## Scope and stop marker

- Active prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R07_POST_ANDROID_REGRESSION_RECOVERY_MASTER_PROMPT.md`.
- Scope: diagnose R06 Godot 4.7.2 regression, restore focused test execution, bounded editor shutdown repro, installed Android toolchain inventory, and nonproduction debug APK export.
- Required handoff marker: `AWAITING_GPT_M34_R07_INDEPENDENT_AUDIT`.
- Root `TASKS.md` was read-only throughout. No code, test, gameplay, campaign data, scene, asset, or production export configuration was changed.

## Preflight and worktree

- Canonical Desktop preflight started at `35ff499596636b3f23c4daa9e4bdae5aca5b09be`, `main`, `0 ahead / 3 behind`; `origin/main` fetched as `5adf38dbee38e244d0933f4c4cee47ed7bc47882`.
- Incoming paths were only `TASKS.md`, the corrected R06 audit, and this R07 prompt; none overlapped the seven modified tracked owner paths or fifteen untracked owner paths.
- Followed the authorized tracked-only safe-sync procedure with `owner-local-safe-sync-35ff499`, leaving untracked files in place. Fast-forwarded canonical Desktop to `5adf38d`; reapplied the stash without dropping it and verified the owner-file hashes. The synchronized `TASKS.md` SHA-256 is recorded in `evidence/M34-R07/canonical_owner_state_before.json`.
- R07 ran in an existing non-Desktop safe worktree detached at latest `origin/main` (`5adf38d`). Two additional detached non-Desktop worktrees were used only for cold-cache/editor-import and Android export verification; no new GitHub branch was created.
- Canonical owner state snapshot records all seven modified tracked paths, fifteen untracked paths (22 actual file hashes), `project.godot`, `TASKS.md`, and 74 stashes, including the named safe-sync stash. No canonical file was edited by R07.

## R07-001 — Regression diagnosis

- R06 source evidence reproduces the original Daily failure after 35 pass markers: unresolved `DailyRewardService`, `application_shell.gd:865` type inference, then the test's `SHELL_SCRIPT.new()` call on a failed script. Its M33 capture reports unresolved `AdsService`/`StoreService` and four passes before the failed script instantiation. Economy was 24/24.
- Independently ran the Daily probe first in a detached checkout with no `.godot` cache and an isolated `APPDATA`: it emitted 35 pass markers and failed with exit `-1`. Captured stderr shows unimported PNG resources reported as “no resource loaders” and dependent global classes unavailable. The project still had no global class cache after this cold `--script` run. The bounded process was stopped only after recording its exact Godot console/child process identity and waiting 180 seconds without exit.
- A cold M33 run also failed before reaching its checks. These cold runs establish that directly invoking `--script` before a Godot project import is not a valid regression-run setup.
- Ran Godot 4.7.2 editor import on that same checkout: 1,688 reimport steps, exit `0`, no project.godot hash change, and a newly written global class cache (`6C4941C2A9EA7D7ECFB82D15E89347E50C7A8F5916A677140DBAE9E4DDB57022`) registering `AdsService`, `StoreService`, and `DailyRewardService`.
- No production parse/type fix was warranted: with the generated project cache present, all required focused suites passed. Recovery is to import/scan the project before direct script probes; the cold-cache failure must not be hidden by changing tests or gameplay source.

## R07-002 — Editor shutdown access violation

- Reproduced a clean checkout import from no `.godot` cache. Godot completed 1,688 reimport steps and exited `0`; the previous `-1073741819` shutdown access violation did not reproduce.
- A second already-imported worktree editor import completed its one pending reimport and exited `0`.
- The R06 access violation remains an unresolved, non-reproduced tooling/editor shutdown event; this run does not claim its underlying cause is fixed. No caches were deleted wholesale.
- The editor rewrote a GameFeelFlow autoload path to a generated UID in the Android-validation worktree. The temporary ETC2/ASTC setting and generated UID rewrite were removed by restoring the tracked `project.godot` bytes; final SHA-256 equals the original `16AEFDC52E70FFEC68CF7BA5726806A607A7BE0B1D0884906CF0E224419EE66A`. Canonical owner `project.godot` remained hash-identical to its post-sync baseline.

## R07-003 — Focused regression and startup

After fresh import, reran the full focused suite in the cold-start checkout with an isolated Godot user profile:

- `tests/m34_daily_rewards_probe.gd`: 38/38, exit `0`.
- `tests/m34_economy_closure_probe.gd`: 24/24, exit `0`.
- `tests/m33_campaign_navigation_probe.gd`: 17/17, exit `0`.
- Headless production startup smoke (`--quit-after 3`): exit `0`.

Exact stdout/stderr and the result manifest are under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R07/`. Startup/import still log the two existing invalid UID fallbacks for `WorldMapScene.tscn` and `main.tscn`; import also logs three empty translation-locale warnings. No false PASS is claimed for cold execution before import.

## R07-004 — Android toolchain and debug export

- Re-inventoried without reinstall or download: Godot 4.7.2 templates; Temurin 17.0.20.1+1; Android command-line tools 22.0; platform-tools 37.0.1; Android platform 35; build-tools 35.0.1; NDK 28.1.13356709; CMake 3.10.2.4988404. Exact paths and existence checks are in `android_toolchain_inventory.json`; `sdkmanager --list_installed`, `java -version`, and `adb version` succeeded.
- No Android ad/billing plugin was installed; no store/account/device action, release key, or production signing was performed.
- A proof-bounded temporary preset named `R07 Nonproduction Debug Validation` used package `org.example.bcm.r07debugvalidation`, no release key, the existing Godot debug keystore, and the prebuilt debug template. Its text is retained as evidence only; it was not added to the production project.
- Godot first rejected a presetless export as expected, then reported that Android required ETC2/ASTC import. In the detached validation checkout only, temporarily set `rendering/textures/vram_compression/import_etc2_astc=true`, exported, and restored `project.godot` byte-for-byte afterward.
- Debug APK export exited `0`; artifact is outside the repository at `C:\Users\sekip\AppData\Local\BCM-M34-R07-Android-Export\BCM_R07_Debug_Validation.apk` (1,353,331,251 bytes, SHA-256 `EDDDDB44CBEFF9FA8C653BEB6621C6168D4D948B66C14559C7D91D5F580A93F5`). `apksigner verify` exited `0` (v2/v3 verified); `aapt dump badging` exited `0` and confirms the nonproduction package/label. The APK was not installed or submitted.
- Export diagnostics still include “No project icon specified” despite producing a signed APK with exit `0`, a build-tools target-version fallback to 35.0.1, and the two scene UID fallback warnings. This is a debug-export artifact only; it is not a store-ready package or device acceptance.

## R07-005 — Publication and owner preservation

- Intended repository changes are builder evidence plus this versioned log; no production source or tests were changed. The APK (1.35 GB) and temporary preset were not added to the repository.
- `git diff --cached --check` passed after line-ending normalization of captured evidence; no substantive console content was changed. All R07 evidence is approximately 1.03 MB.
- Evidence commit: `fbe88c77e39a75c8d8ab638fafe4ee32a554ac5d` (`docs(m34): record R07 regression recovery evidence`). This log is a separate documentation-only follow-up commit. Final synchronized refs and exact final HEAD are verified after publication and reported in the task handoff.
- `TASKS.md` was not modified, staged, or committed by Codex.
- Manual player testing, Android device installation, store readiness, rewarded-ad fulfillment, IAP, and independent acceptance were not performed.

Builder stop marker: `AWAITING_GPT_M34_R07_INDEPENDENT_AUDIT`.