# Codex Execution Log — BCM-M34-006/007 V08

**Prompt:** `coordination/sessions/BCM-M34-006-007-CODEX-COMPUTER-USE-OWNER-CONSOLES/BCM_M34_AAB_EXPORT_RETRY_AND_DAILY_REWARDS_V08.md`

**Start HEAD after safe sync:** `8d3843b875f88b901d85449a2fc38455f3800a04`.

**Implementation/evidence commit:** `e661443e1cbe230c1df301411adfd7a7e4a9818e`.

**Branch / remote:** `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

**Builder result:** `AAB_EXPORT_AND_ARTIFACT_VALIDATION_PASS; DAILY_REWARDS_CAPTURE_UNAVAILABLE`.

## Sync-first preflight and preserved owner work

At session start the canonical checkout was at V07 log commit `2731172bd87b39f855abb84ab61d4dce74a72a64`, with only pre-existing untracked owner files and no modified tracked paths. After `git fetch origin main`, local main was `0 ahead / 3 behind`. Incoming paths were root `TASKS.md`, the V08 prompt, and the V07 independent audit; none overlapped an inventoried owner-untracked path. `git merge --ff-only origin/main` advanced to `8d3843b875f88b901d85449a2fc38455f3800a04`. No stash, reset, rebase, worktree, cleanup, or deletion was used. Existing owner-untracked files remained untouched and unstaged.

Root `TASKS.md` was read after synchronization and not edited. Its working-tree and staged diffs were empty at handoff. PCK cleanup was not repeated.

## Single V08 Android AAB export

Added `tools/release/build_android_aab_v08.ps1`. Its read-only preflight confirmed the Godot 4.7 editor setting, `ANDROID_HOME`, and `ANDROID_SDK_ROOT` all resolve to `C:\Users\sekip\AppData\Local\BCM-M34-Android-4.7.2\sdk`; the existing Temurin JDK `17.0.20.1`, NDK r28b `28.1.13356709`, CMake `3.10.2.4988404`, Android API 36, Build Tools 36.1.0, and cached bundletool 1.16.0 are present. No toolchain installation or Google license acceptance occurred. The synthetic mismatched-root preflight rejected the wrong SDK pair without starting an export.

Exactly **one** actual V08 export was run, with a 600-second cap, debug preview identity `com.sekiph82.beachcocktails.m34preview`, and output `.godot/bcm_release_preflight/android_preview_v08.aab`. It completed in 293 seconds: Godot exited `0`; Gradle's task-specific daemon log `.godot/gradle-home/daemon/8.11.1/daemon-19680.out.log` reports `BUILD SUCCESSFUL in 2m 58s`. The fresh 147,028,717-byte AAB SHA-256 is `b22ba20b3ff1bf5b3b77f9077f7a67b9783b1e3e8d44581fcbca90bab3985c15`, byte-identical to the already accepted V06 AAB.

V05 APK remained 198,927,159 bytes with SHA-256 `126e30713ab1c9687277899ab3c8eed44f1f53b988f583ce1d8a1b537e9bd92b`. V06 AAB remained 147,028,717 bytes with SHA-256 `b22ba20b3ff1bf5b3b77f9077f7a67b9783b1e3e8d44581fcbca90bab3985c15`. Neither old artifact was overwritten.

The first wrapper's cached bundletool call used `java -jar` against a library JAR without a `Main-Class` manifest and reported `no main manifest attribute`; the original raw run result JSON retains that exact failure. The wrapper was corrected to use an explicit JDK 17 runtime classpath from the existing Gradle cache via a local Java argument file. Without rerunning export, the newly produced V08 AAB was then validated with cached bundletool 1.16.0 (`validate`, `dump manifest`, and `dump config`, all exit 0). This post-run validation is recorded separately in `docs/release/evidence/BCM_M34_AAB_EXPORT_DAILY_REWARDS_V08_2026-10-21.json`.

Inspection results:

- ZIP integrity passed; bundle modules are `base` and `assetPackInstallTime`.
- Base manifest is debug-only preview: package `com.sekiph82.beachcocktails.m34preview`, version `0.0.0-m34preview-NOT-SHIPPING`, min SDK 24, target SDK 36, and only `android.permission.INTERNET`.
- Bundle config declares `PAGE_ALIGNMENT_16K`. Both `base/lib/arm64-v8a/libc++_shared.so` and `libgodot_android.so` have all PT_LOAD segments aligned to 16,384 bytes and page-congruent offsets.
- The AAB ZIP has no root development-evidence entries under `docs`, `tests`, `tools`, `backend`, `.github`, or `coordination`. Existing export preset filters were not changed; sparse PCK cleanup was not repeated.
- Source policy still has all seven ad placements disabled and store catalog products nonbuyable. Future AdMob source/configuration was not changed.
- `project.godot` was restored byte-for-byte; before/after SHA-256 is `2aa63354b3747ebfb296baeeca389866cb651adcf9c152afaf5c9cf2d173d8cc`.

## Daily Rewards screenshot attempt and stop

V07's existing completed tutorial profile under `.godot/bcm_sandboxes/bcm_m34_v07_20261021_01` was used; the tutorial state SHA-256 remained `7bcb866de1bfe828ca6b4f80bdf755ff74b6651baffc1a842acaddb553fe9a2d`. The fresh Computer Use inventory returned `apps=[]`; the exposed runtime had no native `listApps`, `listWindows`, or window input methods. A task-owned GUI-mode production capture process (PID 17252) was started with the isolated `APPDATA`/`LOCALAPPDATA`, then stopped after no controllable target window was returned. No key or click was injected, no reward was claimed, and no screenshot or Daily Rewards store composition was fabricated. The V03 Daily Rewards composition remains `HOLD`.

`tools/release/capture_live_game_input.gd` now supports a dedicated V08 capture directory for a later authentic F12 capture. Owner handoff option: open the isolated profile, navigate through Home to Daily Rewards, wait for the UI to settle, press F12, and provide the genuine 720x1280 viewport PNG for composition. No screenshot is represented as device-captured.

## Focused checks and limits

- PowerShell AST parse of the V08 export wrapper — PASS.
- Synthetic SDK-root mismatch preflight — PASS; rejected before export.
- Real SDK/JDK/NDK/CMake/API36 preflight — PASS.
- Godot 4.7.2 `--headless --path . --check-only --script res://tools/release/capture_live_game_input.gd` — exit 0.
- Gradle daemon result — `BUILD SUCCESSFUL in 2m 58s`.
- Cached bundletool validate / dump manifest / dump config — all exit 0 after the bundletool runtime-classpath correction.
- AAB ZIP integrity — PASS; arm64 ELF 16 KB PT_LOAD alignment — PASS.
- Manifest SDK/package/debug/permission assertions — PASS.
- Ad placement/product disabled source checks — PASS.
- `git diff --check` — PASS.
- No Android emulator/device, GitHub Actions, SDK/license installation, store upload, official portal write, signing key, or billing/ad request was used.

Daily Rewards real screenshot and Android/iOS public-store acceptance remain open. No M34-006/007 closure is claimed.

## Repository handoff

Implementation and evidence were committed and pushed as `e661443e1cbe230c1df301411adfd7a7e4a9818e`. Immediately after that push, `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` matched that SHA and divergence was `0/0`; `TASKS.md` working/staged diffs were empty. This immutable log is published as a follow-up commit, after which parity is verified again in the final handoff.

`TASKS.md` was not modified. All pre-existing owner-untracked files remain unstaged. Independent review remains pending.
