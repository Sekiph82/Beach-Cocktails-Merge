# CODEX LOG — BCM-M24-R01 Validation Completion

## Identity and synchronization

- Work item: BCM-M24-R01, M24 validation completion, locked prompt/criteria V01.
- Branch: `main`; remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Start HEAD after safe sync: `96ee9abdecc7e9f96a81e084c6a6848be4191291`.
- Start local/origin divergence: `0 0`; synchronized checkout was `96ee9ab...`.
- Safe-sync preservation stash: `owner-local-safe-sync-8cc4b22`. The tracked owner-local paths and untracked inventory were preserved. No owner-local path was staged by the R01 work.
- Root `TASKS.md` was read only and not modified.

## Scope and changes

Only new R01 validation evidence and this execution log are intended for publication. M24-001 through M24-003 implementation/source was already published and was not changed. No gameplay authority, effect policy, art, or task status was changed. No M25 work was started.

Evidence index: `coordination/sessions/BCM-M24-MASTER-V01/evidence/M24-R01/README.md`.

Files changed: `coordination/sessions/BCM-M24-MASTER-V01/evidence/M24-R01/**`; `docs/codex-logs/CODEX_LOG_M24_R01.md`.

## Commands and results

- `git status --short --branch`, `git remote -v`, `git fetch origin main`, `git rev-list --left-right --count HEAD...origin/main`: completed before prompt work; behind-only 0 ahead / 4 behind, disjoint safe-sync then fast-forwarded to `96ee9ab...` and reapplied tracked-only stash.
- Godot 4.7.2 editor import: `godot_console.exe --headless --path . --editor --quit`; exit 0.
- M02/M09/M15/M21/M22/M23/M24 probes: passed as recorded in R01 `regression/` logs. Runners were copied to `%TEMP%\BCM-M24-R01-runner`, redirected to R01 evidence outputs, and launched with isolated `%TEMP%\BCM-M24-R01-appdata` as `APPDATA`.
- M21 mobile QA: GL Compatibility renderer, 720×1280 window plus 720×1440 tall viewport; PASS, 16 image captures.
- FULL and REDUCED production gameplay acceptance: GL Compatibility, 720×1280; each runner PASS. Accepted order and VIP states and event tokens are in the two gameplay acceptance logs and screenshots.
- Godot boot: `godot_console.exe --headless --path . --quit-after 120`; exit 0.
- `git diff --check`; exit 0.
- Protected owner tracked blobs were compared against `stash@{0}` after tests. `project.godot`, the two M21 reports, four M22 reports all matched their saved pre-test blob IDs. Owner-local untracked PNGs and M23 evidence were not modified.

## Regression summary

- M02 22 checks PASS; M09 21 PASS; M15 63 PASS.
- M21 progression: 100 levels, five persistence checkpoints, 1,352 assertions PASS; M21 release persistence 9 PASS.
- M22-001 21 PASS; M22-002 27 PASS; M22-003 97 PASS.
- M23-001 28 PASS; M23-002 30 PASS; M23-003 30 PASS; M23-R03 color lifecycle 13 checks / 7 scenarios PASS.
- M24-001 7 PASS; M24-002 8 PASS; M24-003 8 PASS.
- Real-renderer M21 mobile QA 16 captures PASS; gameplay FULL and REDUCED each PASS.

## Manual / visual review and limitations

Inspected the real-renderer 720×1280 gameplay capture and FULL/REDUCED accepted-order images. The canonical HUD/table geometry remains stable. FULL screenshots show short local spark accents; REDUCED screenshots show immediate state with no order-progress particles. No duplicate WIN overlay was observed.

FPS capture samples were instantaneous and include startup/screenshot work: FULL 2–37 FPS; REDUCED 2–36 FPS. This is not a steady-state or physical-device performance result. Owner F5 and physical-device acceptance remain unverified and are not claimed.

A preliminary M02 run happened before setting isolated APPDATA; its log reported the user save path and game-over score 0. The authoritative M02 rerun was isolated and passed. The existing user save currently reads `best=321`; no pre-run byte snapshot exists, so byte parity across the preliminary invocation cannot be proven. No manual restore was attempted.

M22-003 scratch runs first failed because the redirected folder was missing and then because an isolated matrix copy was read-only; the corrected writable isolated output passed 97 checks. An early GL overwrite attempt also failed to save one preexisting R01 screenshot; final unique-output runs passed. These scratch logs are retained beside the successful logs for audit transparency.

## Publication and handoff

- Final implementation/evidence commit SHA: `e1a28643f22e80a409dd82b3c251cc047972b847`.
- This log is committed in the log-only publication commit after the evidence commit above. After pushing that commit, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` are run and their matching SHA is reported in the completion response.
- `TASKS.md` remains unchanged. Stop marker: `AWAITING_GPT_M24_R01_REAUDIT`.

