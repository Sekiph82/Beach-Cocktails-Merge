# Codex Execution Log — BCM-M34-006/007 V07

**Prompt:** `coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_ANDROID_EXPORT_AND_REAL_SCREENSHOTS_V07.md`

**Start HEAD after safe sync:** `82781fdfb1fe6b61f44120879b67a5fb7ee45588`.

**Implementation/evidence commit:** `dad3e80914747975deffd85152c12be5d22341d1`.

**Branch / remote:** `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

**Builder result:** `PARTIAL_ANDROID_EXPORT_BLOCKED_DAILY_REWARDS_CAPTURE_BLOCKED`; Android export stability is not accepted as solved.

## Sync-first preflight and preserved owner work

The session began at `994acd542096aaaeee118a62378d63dae4b584de`, branch `main`, with no modified tracked paths. `git fetch origin main` moved the remote to `82781fdfb1fe6b61f44120879b67a5fb7ee45588`; divergence was `0 ahead / 3 behind`. The incoming diff contained root `TASKS.md`, the V07 prompt, and the V06 independent audit. It did not overlap the inventoried untracked owner paths. The authorized `git merge --ff-only origin/main` advanced the checkout to `82781fdfb1fe6b61f44120879b67a5fb7ee45588` without stash, reset, rebase, worktree, or deletion.

All pre-existing untracked owner files remained untouched and unstaged, including `_m32_validation/`, M21/M23/M26/M33 evidence, `data/campaign/shop_catalog.json`, the M23 Codex log, root UUID PNG, `tools/capture_godot_window.ps1`, and pre-existing `.gd.uid` files. Root `TASKS.md` was read after synchronization and was not edited. The only `TASKS.md` change in this checkout came from the path-disjoint fast-forward.

## Android AAB export investigation

Added `tools/release/build_android_aab_v07.ps1`, a bounded process-local wrapper. It uses the installed JDK 17 and configured SDK, snapshots and restores `project.godot` byte-for-byte, applies the transient ASTC import setting, captures Godot stdout/stderr separately, classifies Gradle success/failure separately, records abnormal exits and timeout, and runs cached bundletool validation separately only after a clean Godot exit and an existing V07 AAB. It refuses to overwrite the V05 APK or V06 AAB and writes only to ignored `.godot/bcm_release_preflight/android_preview_v07.aab`.

Exactly one V07 export attempt was made with a 600-second bound. Godot exited normally with code `1`; Gradle reported `BUILD_FAILED`, and no AAB was created. Gradle identified two different SDK roots:

- Godot editor `android_sdk_path` / `ANDROID_HOME`: `C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\sdk`.
- `ANDROID_SDK_ROOT` inherited for the wrapper attempt: `C:\Users\sekip\AppData\Local\Android\Sdk`.

Gradle stopped before asset-pack build tasks because its environment and system properties named distinct SDK roots. Bundletool validation therefore did not run. This V07 attempt did **not** reproduce the V06 post-Gradle hang; it also did **not** produce a successful AAB. The wrapper was corrected afterward to set both SDK environment variables to Godot’s existing configured SDK root and to preflight the installed NDK r28b, CMake 3.10.2.4988404, and API 36 directories. The corrected SDK-variable alignment was syntax checked, not export verified; the prompt's one-attempt limit was honored, so no second export was made.

`project.godot` SHA-256 before and after the export attempt was identical: `2aa63354b3747ebfb296baeeca389866cb651adcf9c152afaf5c9cf2d173d8cc`. No JDK, NDK, CMake, SDK component, third-party tool, or Google SDK license was installed or changed. V05 APK and V06 AAB were not overwritten. The V07 result remains **failed / unverified after wrapper correction**, not AAB PASS.

## Actual game captures and marketing composition

The isolated runtime used `.godot/bcm_sandboxes/bcm_m34_v07_20261021_01`, with sandboxed `APPDATA` and `LOCALAPPDATA`. It loaded the production `ApplicationShellScene` in Godot 4.7.2. The five-step campaign onboarding was completed with the real UI. The six-step gameplay tutorial was completed through actual UI actions: launched drinks, produced a merge, delivered the required To-Go order, completed level 1 (observed score 575), and used Retry as instructed. The isolated tutorial state is `completed=true`, SHA-256 `7bcb866de1bfe828ca6b4f80bdf755ff74b6651baffc1a842acaddb553fe9a2d`. No owner save was read or written.

The existing F12 viewport capture script initially failed to compile because the V07 capture-directory change left one stale `CAPTURE_DIRECTORY` reference in the JSON metadata path. That reference was corrected to use the selected capture directory. Subsequent genuine 720×1280 viewport captures were saved with provenance sidecars:

- `docs/release/store_media/captures_v07/desktop_candidate_01_main_menu.png` — Home, SHA-256 `0ebc0509041509d0d42e21051dfeab7a79f41275b8bcdc4d5ecdab0be82e47e9`.
- `docs/release/store_media/captures_v07/desktop_candidate_02_campaign.png` — gameplay board after tutorial completion, no tutorial overlay, SHA-256 `88c006428983ba8a0138ccbc1a10cfeecaa2fa0f97734ee0f8c8a25494594eb1`.

Added `tools/release/build_store_media_v07.py` and a 1080×1920 composition `docs/release/store_media/compositions_v07/04_gameplay_google_play_candidate_v07.png`, SHA-256 `2d77322df62ea9b06b0bab7335391e82561d047fa7e00448b6f46cef241eda45`. It preserves the captured game viewport pixels, adds only a separate caption and truthful `DESKTOP CANDIDATE / DEVICE REVIEW PENDING` footer, and records the source image and completed tutorial hashes. It is not a phone capture or owner-approved listing asset.

The Daily Rewards screen was opened through the real Home button, allowed to settle for 5.5 seconds, and inspected without claiming a reward. F12 capture was interrupted when Computer Use reported user input in the target window, then reported the window minimized. Refresh, target-window re-selection, and activation did not clear the interruption. Windows Computer Use recovery guidance requires stopping further input after the retry fails; no more UI input was sent. No V07 Daily Rewards capture was saved. The V03 Daily Rewards marketing composition remains **HOLD** and must not be represented as the settled recapture.

The Apple 1024 master and Google Play 512 icon candidates were visually inspected for title and drink legibility. The builder review found them legible at their candidate sizes; no owner visual approval is claimed.

## Apple App Store Connect record preparation

Prepared `docs/release/BCM_M34_APP_STORE_CONNECT_RECORD_INPUTS_V07.md` with copy-ready iOS platform and app title, proposed English (U.S.) primary language, proposed canonical bundle ID `com.sekiph82.beachcocktails`, and the exact owner-controlled SKU field. It states the previously inspected team’s scoped `Apps: No Apps` result without repeating that audit. The canonical standalone App ID registration and exact SKU authorization remain unconfirmed. No Apple app record was created, no portal was opened for V07, and no legal agreement was accepted. The proposal expressly rejects substituting the XTool-prefixed identifier.

The EN/TR staging privacy pages now add only source-verified local storage facts for campaign progress, settings, onboarding, and tutorial state. The text explicitly limits those facts to source paths and does not claim that signed builds/SDKs process no other data. Support pages were left unchanged because no verified owner contact or public URL was provided; no identity, contact, or public URL was invented.

Future AdMob source was not changed. Ad placements remain off and purchases remain nonbuyable. Public Android and Apple store release remain **NO-GO**.

## Focused checks and exact results

- `godot --headless --path . --check-only --script res://tools/release/capture_live_game.gd` — exit 0, Godot 4.7.2.
- `godot --headless --path . --check-only --script res://tools/release/capture_live_game_input.gd` — exit 0, Godot 4.7.2.
- PowerShell AST parse of `tools/release/build_android_aab_v07.ps1` — PASS.
- `python tools/release/build_store_media_v07.py` — PASS; repeated build retained source capture SHA-256 `88c006428983ba8a0138ccbc1a10cfeecaa2fa0f97734ee0f8c8a25494594eb1` and composition SHA-256 `2d77322df62ea9b06b0bab7335391e82561d047fa7e00448b6f46cef241eda45`.
- JSON parsing of the V07 capture and composition sidecars — PASS.
- `python -m unittest tests.test_sparse_android_apk -v` — 9/9 PASS (read-only regression check; no PCK cleanup repeated).
- `git diff --check` — PASS.
- No emulator, Android device, GitHub Actions, store upload, public publication, SDK license acceptance, production signing, real AdMob transaction, or billing operation was used.

## Files changed

- `tools/release/build_android_aab_v07.ps1`
- `tools/release/build_store_media_v07.py`
- `tools/release/capture_live_game_input.gd`
- `docs/release/store_media/privacy_policy_staging_en.html`
- `docs/release/store_media/privacy_policy_staging_tr.html`
- `docs/release/BCM_M34_APP_STORE_CONNECT_RECORD_INPUTS_V07.md`
- `docs/release/evidence/BCM_M34_ANDROID_EXPORT_MEDIA_V07_2026-10-21.json`
- V07 viewport captures and metadata under `docs/release/store_media/captures_v07/`
- V07 gameplay composition and metadata under `docs/release/store_media/compositions_v07/`
- This immutable execution log.

## Repository handoff

The implementation/evidence commit `dad3e80914747975deffd85152c12be5d22341d1` was pushed to `origin/main`. Immediately after that push, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `dad3e80914747975deffd85152c12be5d22341d1`; divergence was `0/0`. This log is published as a follow-up commit, after which parity is rechecked in the final builder handoff.

Root `TASKS.md` was not modified. Independent audit and owner review remain pending.
