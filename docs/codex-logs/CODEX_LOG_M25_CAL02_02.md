# BCM-M25-CAL02 Codex Execution Log V02

- Work item: `BCM-M25-CAL02` — resumable move/star calibration workflow and staged 45-class discovery.
- Prompt/version: `coordination/sessions/BCM-M25-MASTER-V01/BCM-M25-CAL02_PROMPT.md` (`CAL02 Calibration Evidence`).
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Session start `HEAD`: `bdf1a6e` (`bdf1a6e...`); post-sync local and `origin/main` matched before work.
- Initial preflight: branch `main`, clean relative to origin with owner-local tracked/untracked paths present; remote fetch moved `origin/main` from `db6e839` to `bdf1a6e`; pre-sync divergence was `0 ahead / 3 behind`.
- Safe sync: inventoried six tracked evidence changes plus `project.godot` and all untracked paths; incoming diff touched only `TASKS.md` and three M25 coordination files, so it was path-disjoint. Created tracked-only `owner-local-safe-sync-db6e839`, left untracked paths untouched, fast-forwarded to `bdf1a6e`, and reapplied the exact new stash. Owner tracked/untracked contents were hash-checked before the first Godot invocation.

## Changes

- Added checkpointed `m25_cal02_resumable_runner.gd`, which enumerates the 45 M17 challenge classes, executes the unchanged task-local production-physics harness, appends replayable JSONL trial records immediately, skips completed `(class, policy, seed)` keys on resume, and writes status after each completed trial.
- Added Python summary/coverage builders, per-class coverage matrix, raw trusted real-time subset, candidate-run action logs, physics optimization qualification, preservation hash manifests, and the calibration stop report under `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-CAL02/`.
- No product runtime/configuration, limits, stars, score calculation, orders, physics, rewards, HUD, or progression files were changed. No M26 work was started.

## Calibration results and evidence boundary

- Current canonical data has 100 levels and 45 order classes. Fresh unaccelerated `time_scale=1.0` data contains four trials over C01 and C20 only; no valid VIP-enabled class trial is present.
- C01 real-time observations: `WEAK_V02` seeds 31001/31002 ended in danger at 17/19 moves; `MERGE_AWARE_V01` seed 31001 completed in 13 moves. C20 `MERGE_AWARE_V01` seed 31001 completed in 78 moves and took 77,697 ms wall time.
- The per-class confidence intervals remain too broad to choose move caps or 2/3-star cutoffs. The historical M17 timed trials are context only and were not pooled into current no-timer distributions.
- The resumable runner produced 71 fixed-60 exploratory records over 24 classes, with no duplicate keys. These are explicitly excluded from calibration decisions: C20 same-seed real-time versus fixed-60 completed in 78 versus 101 moves with a different action log. Fixed-240 also changed C23 same-seed fixed-60’s 120 moves to 73. The acceleration candidates failed equivalence.
- Stop marker: `OWNER_CALIBRATION_REQUIRED`. No new budget/star formula was enabled.

## Commands and exact results

- `godot --version` — `4.7.2.stable.official.ed1daf0bf`.
- `godot --headless --path . --editor --quit` — exit 0; editor import/quit.
- Console executable `Godot_v4.7.2-stable_win64_console.exe --headless --path . --check-only --script res://coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-CAL02/m25_cal02_resumable_runner.gd` — exit 0; runner parse check.
- Checkpoint/resume batches with `--fixed-fps 60` — 71 complete exploratory trial records over 24 classes; no duplicate keys. One in-progress C24 merge-aware trial was interrupted before checkpoint and will rerun if the workflow resumes.
- Real-time/fixed-frame equivalence fixtures — three low-order C01 matches at gameplay/action-log level (one elapsed settle difference of one 1/60-second tick); high-order C20 comparison failed; fixed-240 C23 comparison failed. Accelerated data excluded.
- `python summarize_cal02.py runs` and `python build_cal02_status.py` — exit 0; emitted 45-row coverage and confidence summaries.
- `python -m py_compile summarize_cal02.py build_cal02_status.py` — exit 0.
- `git diff --cached --check` — exit 0; no whitespace errors.
- `git hash-object TASKS.md` equals `git rev-parse HEAD:TASKS.md`: `6e983f3ebb73049c770a835847d029a85b793e88`. Root `TASKS.md` was not modified.

## Owner-local state and limitation

- Isolated `APPDATA` and `LOCALAPPDATA` were set before Godot runs. This Godot Windows runtime still wrote into the real `CocktailMerge` app-data log directory. The paired manifest records 251 original tracked/untracked/save paths; 249 still exist and match their pretest hashes.
- Restored `project.godot` to its exact pretest SHA-256 and restored the original `godot.log` byte-for-byte from a rotated copy. Two older diagnostic logs were evicted by Godot's five-file log rotation: `godot2026-10-08T20.26.59.log` and `godot2026-10-08T20.36.08.log`. The two newly generated test logs were preserved. All other original paths, including campaign/save JSON, match pretest hashes. No further Godot invocation was made after discovering the rotation.
- No pointer/touch acceptance or player-population fairness study was performed. Move-cap candidate validation through the production shot-commit path remains future calibration work.

## Publication

- Evidence implementation/report commit: `e84b56626b79d95dbb14fbcddd1f8f3865203221` (`Add resumable M25 calibration evidence`), pushed to `origin/main`.
- At that publication checkpoint, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `e84b56626b79d95dbb14fbcddd1f8f3865203221`.
- Final result: stop for independent audit at `OWNER_CALIBRATION_REQUIRED`; do not transition `TASKS.md` or start M26.
