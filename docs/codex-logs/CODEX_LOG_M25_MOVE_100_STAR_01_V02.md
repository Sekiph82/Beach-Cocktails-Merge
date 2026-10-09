# BCM-M25-MOVE-100-STAR Child 01 execution log V02 — calibration gate

- Work item / prompt: `BCM-M25-MOVE-100-STAR`, master prompt and locked criteria V01, Child 01 (100-level budget/star calibration).
- Start HEAD: `fd22ab93fe3a4a78781ba79b678e99c7e0aa003a` on `main`; `origin/main` matched. Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Sync-first preflight: initial HEAD `f7c5ba02c532f9d40980f030122beda992794d43`, 0 ahead / 6 behind. Incoming paths were `TASKS.md` and M25 coordination files, disjoint from seven tracked owner-local changes and all untracked owner files. Used tracked-only stash `owner-local-safe-sync-f7c5ba0`, left untracked owner work untouched, fast-forwarded to `fd22ab93fe3a4a78781ba79b678e99c7e0aa003a`, applied only the new stash. Current diff remains unstaged owner-local work only.
- Canonical `TASKS.md` is read-only and unchanged. The new owner ruling authorizes the 100-level rollout and move-based stars. No product implementation was started because locked calibration criterion 4 requires attainable per-level budgets and star cutoffs before implementation.
- Protected baseline: `evidence/M25-MOVE-100-STAR/pretest_hashes.json`; 251 tracked owner-local, untracked owner-file, and user-save files were captured before any Godot invocation. `protected_hashes_after.json` reports all 251 byte-identical; no protected M23-R01 additions. Godot user data and task outputs were isolated.
- Product files changed: none. Evidence additions: calibration pilot runner and local harness copy, attempt logs, all-level calibration status CSV, calibration stop report, and protected-file hash comparison.

## Calibration command and results

- Godot: `4.7.2.stable.official.ed1daf0bf`; all recorded simulation attempts used isolated `APPDATA` / `LOCALAPPDATA` under `C:\Users\sekip\AppData\Local\Temp\BCM-M25-MOVE-100-STAR-20261009\`.
- The pilot used a task-local copy of `M17SeededValidationHarness`; the repository harness remained unchanged. Physics scale was 1.0. The copy only allows untimed (`time_limit_sec=0`) trials to continue to a production terminal/action cap. The harness launches through production `GameManager.spawn_drink`, `Drink.launch_up`, merge/collision code, and Godot physics. This is solver evidence, not a real-pointer production acceptance run; the L6 direct spawn path also bypasses the production 35-shot launch cap.
- `pilot_run3.log`: 14 complete seeded trials: L1 and L6 and L20 each had two fixed seeds with `WEAK_V02` and `MERGE_AWARE_V01`; L60 had two weak-policy seeds. L1 wins were 6/10/13/18 shots. L20 weak-policy runs ended in danger at 38/22; merge-aware runs completed naturally in 84/89 shots. L60 weak-policy runs ended in danger at 38/25. Full details are in the log.
- The previous structural candidate formula would assign 63 shots to L20 (objective merge mass 96), below both observed no-timer winning routes. It is rejected as a deployment formula.
- Historical cross-check: `M17_CANONICAL_CONFIRMATION_V07_R03.json` has 100 level rows, 45 exact order classes, and 213 old physical-screening trials. The current 100 objective merge masses match those rows, but M17 ran with prior nonzero timers and one policy; 34 classes had no win in that timer-bounded sample. These failures cannot be carried forward as proof of no-timer impossibility or move-budget thresholds.
- The no-timer pilot stopped after 14 trials. At canonical-scale physics and the existing 60 physics-frame action window, it does not provide adequate coverage of 45 classes. Only 4 of 100 current levels have fresh no-timer trials; 96 have none. A 2/4 success sample has a two-sided 95% Wilson interval of approximately 0.15–0.85. This is insufficient for universal 1/2/3-star cutoffs.
- `pilot_run.log` and its `calibration/pilot/` outputs preserve 20 excluded runs from the original timer-bounded harness; each stopped at one shot as `harness_abort/ACTION_BUDGET` because untimed sessions hit the harness one-second guard. `pilot_run2.log` preserves the duplicate global-class compile error and invalid construction that followed. These are harness setup/control records, not product failures. The corrected runner and isolated evidence are `runners/m25_move100_calibration_pilot.gd` and `runners/m25_move100_physics_harness.gd`.

## Disposition

The locked owner-calibration gate is unmet. Stop this child with `OWNER_CALIBRATION_REQUIRED`; do not assign or enable invented limits/star thresholds, change score-star calculation, or proceed to later implementation/renderer regressions. `level_calibration_status.csv` has 100 rows with move/star cutoff fields deliberately blank. `calibration_stop_report.md` records the exact discrepancy and the additional evidence required to resume calibration.

The next calibration must cover all 45 distinct normal-order classes with multiple reproducible seeds and at least two policies under current no-timer, time-scale-1.0 physics. Candidate discovery must be separated from under-budget validation, use the real commit path for cap checks, and report shot distributions/uncertainty. Classes without natural wins remain unresolved; changing orders or physics requires separate owner authorization. `M26` is untouched.

- `git diff --check`: pending final publication check.
- Start/end HEAD and publication equality: pending evidence-only commit and post-push verification.
