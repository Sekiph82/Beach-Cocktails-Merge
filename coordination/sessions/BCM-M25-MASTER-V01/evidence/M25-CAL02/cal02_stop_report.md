# BCM-M25-CAL02 calibration workflow and disposition

**Decision: `OWNER_CALIBRATION_REQUIRED`.** No move budget, move-based star threshold, score formula, product configuration, or campaign progression change was enabled.

## Work completed

- Added a resumable Godot runner that reads the canonical 45-class M17 challenge map, runs the current canonical Sunny Cove representative level for each class/policy/seed key, appends each completed trial and full action log to JSONL, skips already checkpointed keys on resume, and writes invocation status.
- Added deterministic summary and coverage builders. They report win-rate Wilson intervals, move distributions for completed routes, measured wall cost, per-class/policy coverage, and VIP-enabled cases separately.
- Preserved the task-local production-physics harness behavior: `GameManager.spawn_drink`, `Drink.launch_up`, the production collision/merge code, 60 physics frames/action, and `Engine.time_scale = 1.0`. The copied harness only corrects the prior one-second abort for untimed canonical levels; it does not alter physics or force objective completion.
- Set isolated `APPDATA` and `LOCALAPPDATA` before Godot invocations. The Windows runtime nevertheless wrote to the real Godot app-data log directory. The pre/post manifest covers the seven tracked owner-local files, all untracked owner-local files, and original user save files.

## Fresh real-time evidence

Four current no-timer trials completed with the unaccelerated Godot run mode:

| Class | Policy / seed | Outcome | Moves | Wall time |
| --- | --- | --- | ---: | ---: |
| C01 | WEAK_V02 / 31001 | danger | 17 | 16.75 s |
| C01 | WEAK_V02 / 31002 | danger | 19 | 18.64 s |
| C01 | MERGE_AWARE_V01 / 31001 | completed | 13 | 12.62 s |
| C20 | MERGE_AWARE_V01 / 31001 | completed | 78 | 77.70 s |

Fresh real-time evidence therefore covers 2/45 order classes, with 4 trials total. C01's weak policy is 0/2 (Wilson 95% interval approximately 0.00–0.66); its merge-aware policy is 1/1 (approximately 0.21–1.00). C20 merge-aware is 1/1 (approximately 0.21–1.00). These policy/class-specific intervals are far too broad for a move cap or star cutoff. No fresh VIP-enabled representative class completed under trusted real-time execution, so VIP optionality has not been evaluated by this sample.

Historical M17 trials remain context only: their levels used positive timers and their objective was time/score feasibility, not current no-timer move distributions.

## Resumable runner and acceleration qualification

The checkpoint/resume path was exercised across separate Godot processes. It skipped prior class/policy/seed keys and appended new rows without duplicate keys. The interrupted batch retains only completed records; the active C24 merge-aware trial was stopped before its record could be written. `runs/run_status_final.json` reconciles the per-trial JSONL source after that interruption.

I compared fixed-frame runs against real-time baselines. Fixed 60 FPS matched three low-order C01 samples at the gameplay outcome/action-log level (one had a final settle duration difference of one 1/60-second tick), but it failed on a higher-order class: C20, seed 31001, MERGE_AWARE_V01 completed in 78 moves in real time and 101 moves at fixed 60 FPS, with a different action log. A higher fixed 240 FPS candidate also changed C23's same-seed route from 120 moves at fixed 60 to 73 moves. Both accelerated modes are rejected for calibration use. All 71 fixed-60 trial records across 24 classes remain indexed as exploratory-only; they are excluded from trusted distributions and threshold decisions.

The tested optimization reduces wall cost in short trials but does not preserve routes for higher-order cases. The resumable workflow remains useful for future staged real-time calibration; the valid route is to retain the standard production physics cadence and resume by class/policy/seed.

## Coverage and disposition

- `class_coverage_status.csv` lists all 45 canonical classes, representatives, member levels, current VIP contract, trusted real-time coverage, and excluded exploratory candidate counts.
- `trusted_realtime_trials.jsonl` contains only the four accepted-physics real-time samples above, including their action logs.
- `runs/trials.jsonl` contains 71 excluded fixed-60 exploratory trials, with full replay action logs.
- `physics_optimization_qualification.json` records the per-seed comparisons and rejection criteria.
- `pretest_protected_hashes.json` and the paired after-state manifest cover owner files and saves.

The current sample cannot establish distributions for all classes, identify natural impossibility, or justify one/two/three-star thresholds. Calibration stops here for independent audit. No M26 work was started, and root `TASKS.md` remains byte-identical to synchronized `origin/main`.

## Owner-file preservation exception

Godot's Windows log rotation changed the real `CocktailMerge` log directory despite the environment isolation. I restored `project.godot` and the original `godot.log` to their exact pretest SHA-256 values; the latter was recoverable byte-for-byte from Godot's rotated log. Two older diagnostic logs were evicted by the runtime's five-file retention rotation: `godot2026-10-08T20.26.59.log` and `godot2026-10-08T20.36.08.log`. The after-manifest records both missing paths and preserves the two new test logs. All other 249 original tracked/untracked/save paths match their pretest hashes; the user campaign/save JSON files are unchanged. No further Godot invocation was made after discovering this behavior.
