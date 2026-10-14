# Codex Log — BCM-M34 R06 V02 Disk Recovery and Android Setup (Correction V02)

## Scope and correction authority

Active prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R06_V02_DISK_RECOVERY_THEN_ANDROID_SETUP_MASTER_PROMPT.md`, SHA-256 `8B7D247788A37736C1AD31FE972F8E95F3092098D209EEDD827A0B6BECAAB753`. Required stop marker: `AWAITING_GPT_M34_R06V02_DISK_RECOVERY_ANDROID_SETUP_INDEPENDENT_AUDIT`.

This version records work performed after the immutable `CODEX_LOG_M34_R06_V02_DISK_RECOVERY_ANDROID_SETUP_V01.md` snapshot. It corrects the earlier no-worktree-removal and Android-install-blocked statements with later verified operations and records this run's test results. V01 remains unchanged.

## Repository preflight and state

- Start HEAD: `eb05ddc6c48ed700f0bc6ddbf21f533101e305b3`, branch `codex/m33-r01-physics`, isolated checkout `C:\Users\sekip\.codex\worktrees\bcm-m33-r01-physics\Beach Cocktails - Merge`.
- At the initial safe sync this checkout was clean and fast-forwarded to `eb05ddc`; the canonical Desktop checkout had 7 tracked dirty paths, 15 untracked paths, 72 stashes, and no ahead commits. Root `TASKS.md` was never edited.
- During this run `origin/main` advanced to `cffc0e280302cc21a77832c54aacfd8f334d4e90` through three commits in a separate R06 execution. After confirming that its added paths did not collide with this run's untracked evidence, this worktree fast-forwarded with `git merge --ff-only origin/main`.
- The canonical Desktop checkout remains at `eb05ddc` and reports `behind 3` with its original owner changes still dirty. It was not synchronized again because the standing policy requires preserving and stopping at dirty owner changes.

## Disk recovery performed in this execution

- Removed ten exact clean registered worktrees using normal `git worktree remove`, with no `--force`: M12 V03, M12 V04, M12 V06, M12 World Map, M14 gameplay bridge, M32 owner tutorial review, BCM main merge, owner audit remediation, remaining table assets, and beach visual production.
- Each worktree was rechecked immediately for clean status, published ancestry, process-path absence, and no reparse point. Their combined logical file size was 5,846,822,729 bytes; measured per-batch free-space deltas totalled 5,840,969,728 bytes. `cleanup_receipts.csv` contains exact paths and readings.
- One clean isolated BCM checkout was retained for this task. The verified R05 recovery backup, R06 backup, canonical project, and all 72 stashes remain.
- A separate concurrent R06 log records six generated cache deletions; this correction does not attribute those receipts to this execution. At this execution's earlier cache-deletion attempt, the M25 `.godot` target was rejected by policy and no alternative mechanism was tried. It is now absent according to the later committed R06 receipts.
- C: free was 87,226,593,280 bytes at first measurement, 86,409,519,104 before the cleanup batches, 91,453,231,104 after worktree cleanup, and 90,264,719,360 after Android setup and regression/editor probes. These are live volume readings and include concurrent Windows activity. They do not establish the source of the reported historical 118.8 GiB loss.

## Android development setup

- Capacity gate passed with a conservative 15 GiB peak estimate and >40 GiB preferred reserve after installation.
- Installed task-scoped Temurin JDK 17.0.20.1+1; Android command-line tools 22.0; Platform Tools 37.0.1; Android Platform 35; Build Tools 35.0.1; NDK 28.1.13356709; CMake 3.10.2.4988404. `java -version`, `adb version`, and `sdkmanager --list_installed` succeeded; package identities and license marker hashes are in `android_setup_manifest_v02.json`.
- Installed all three Godot 4.7.2 Android export template entries (debug APK, release APK, source ZIP). Godot user editor settings point to the task-scoped JDK and SDK; the pre-change settings copy is retained locally and hashed in `android_setup_execution_v02.md`.
- `sdkmanager --licenses` received yes responses for all eight prompts, including optional Preview, Google TV/GDK, XR, and system-image IDs beyond the packages installed here; all IDs and license-file hashes are disclosed in `android_setup_manifest_v02.json`. No corresponding optional packages were installed. No app-store, payment, advertising, or account agreement was accepted. No global PATH, Desktop shortcut, signing key, or device configuration was added.
- The five exact verified installer/archive files remain in the task download directory because the exact-file `Remove-Item` invocation was rejected by execution policy before PowerShell ran. Their combined size is 1,627,828,502 logical bytes. No alternate deletion method was tried.
- There is no project `export_presets.cfg`; no Android APK was exported. Production signing, device acceptance, store setup, AdMob, live SSV/backend, and IAP remain separate open gates.

## Regression and import evidence

- `tests/m34_economy_closure_probe.gd`: PASS, 24/24, exit 0.
- `tests/m34_daily_rewards_probe.gd`: PARTIAL, 35 pass markers; failed before the remaining UI checks because current campaign service types were unresolved, `application_shell.gd` had a type-inference parse error at line 865, and the probe called `new()` on the failed script. Exit `-1`; two invalid UID fallback warnings (World Map and main scene).
- `tests/m33_campaign_navigation_probe.gd`: PARTIAL, 4 pass markers; campaign navigation service types were unresolved and the probe called `new()` on the failed script at line 62. It did not reach 17 checks; the exact R06 process tree was stopped after confirming its command line. Exit `-1`; two invalid UID fallback warnings.
- The clean Godot 4.7.2 headless editor import completed all 1,283 asset reimport steps, then exited with native code `-1073741819` during shutdown. It changed only one generated plugin UID line in this isolated worktree's `project.godot`; that generated line was restored and the file matches HEAD. `godot_editor_import_summary.txt` includes the raw console SHA-256.
- No gameplay, production source, or test files were changed. The two incomplete suites remain builder findings for independent audit; no passing claim is made for their remaining checks.

## Preservation and files

- `protected_state_after_android.json`: all seven owner-dirty tracked hashes and all 15 untracked file hashes/lengths match the baseline; canonical `project.godot` and `TASKS.md` hashes match; all 72 stash identities match.
- Root `TASKS.md` was not modified, staged, or committed.
- Correction evidence is in `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R06/`. Generated Godot `.import` and `.translation` files are excluded from publication.
- `git diff --check` is required before this correction commit. Final commit SHA and the verified `origin/main` / remote `main` values are recorded after publication below.

## Final repository state

Correction evidence commit: `6c5fef8` (`docs(m34): record R06 Android setup completion`). This versioned builder log is a separate documentation-only followup. The final published `main` SHA and the remote/local equality check are reported in the task handoff.

Builder evidence is not independent acceptance. Stop marker: `AWAITING_GPT_M34_R06V02_DISK_RECOVERY_ANDROID_SETUP_INDEPENDENT_AUDIT`.
