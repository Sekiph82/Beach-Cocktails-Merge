# M25 MOVE-100-STAR calibration disposition

**Stop marker: `OWNER_CALIBRATION_REQUIRED`. No 100-level budget or move-star rollout is being implemented in this child.** The owner authorized the rollout, but the locked criteria require realistic attainable thresholds based on production physics and legitimate trials. Current evidence does not support them.

## Current-data scope

The canonical Sunny Cove file contains 100 levels and 45 distinct normal-order contracts. A cross-check against the prior M17 class report found the same normal-order merge mass for all 100 level IDs (0 mismatches). The M17 report is useful as historical physics evidence, but it ran with the older 20–300 second timers and one solver policy. It is not a current no-timer move-distribution study.

The earlier M25 structural rule estimated `ceil(ceil(order_mass / (7/3)) * 1.35 + 6)`. It would propose 63 moves for L20 (merge mass 96). A fresh no-timer physics sample completed L20 in 84 and 89 shots with `MERGE_AWARE_V01`; the weaker baseline ended in table danger after 38 and 22. Thus the structural candidate is already below both observed successful L20 routes, and it cannot be reused as a fair move limit or as a basis for 2/3-star thresholds.

## Fresh production-physics pilot

The task-local copy of `M17SeededValidationHarness` called the production `GameManager.spawn_drink`, `Drink.launch_up`, collision/merge code, and Godot physics at `Engine.time_scale=1.0`. It removed only the harness’s one-second termination for a canonical `time_limit_sec=0` session. Seeds and policies are recorded in `pilot_run3.log`.

Four fixed-seed trials were run for each of L1, L6, and L20 using `WEAK_V02` and `MERGE_AWARE_V01`; two weak-policy trials were run for L60. Results:

- L1: four natural wins at 6, 10, 13, and 18 shots.
- L6: two weak-policy danger outcomes at 38 and 25; merge-aware wins at 40 and 27. The harness directly invokes the spawn test hook and does not enforce the production L6 cap; the 40-shot completion is therefore not a valid under-35 route. Separate prior M25 real-input evidence found an L6 win at 22 and a Reduced-mode last-shot win at 35.
- L20: weak-policy danger at 38 and 22; merge-aware natural wins at 84 and 89.
- L60: weak-policy danger at 38 and 25. No merge-aware trial was completed in this pilot.
- L2–L5, L7–L19, L21–L59, and L61–L100 have no fresh no-timer move-distribution trials here.

The larger existing M17 physical-screening report contains 213 trials over 45 order classes, but its levels had nonzero time limits. Thirty-four classes had no completed trial in that timer-bound sample. Because the current campaign intentionally has no timers, these historical non-completions cannot be reinterpreted as move-limit impossibility. They do show that extending the earlier score/timer heuristics without fresh no-timer calibration is unsafe.

The fresh pilot was stopped after 14 trial records: at the preserved 60 physics frames per action and 1.0 time scale, the production simulation is too slow to use this small pilot as a confidence basis for all 45 classes. The partial run and runner are preserved. No completion rate or fairness claim is inferred from these samples. Even L20 has only two wins across the tested policies; the two-sided 95% Wilson interval for 2/4 wins is approximately 0.15–0.85. Thresholds for 3 stars and 2 stars need substantially more coverage.

## Evidence index

- `level_calibration_status.csv`: one row for every current level, exact order mass, best-case/mean-spawn planning figures, deliberately blank move/star thresholds, prior M17 class and outcomes, fresh pilot observations, and `OWNER_CALIBRATION_REQUIRED` disposition.
- `runners/m25_move100_physics_harness.gd`: task-local reproduction copy; production M17 harness is unchanged.
- `runners/m25_move100_calibration_pilot.gd`: fixed pilot levels/seeds/policies and raw trial CSV/JSON emission.
- `pilot_run3.log`: partial fresh run log. `pilot_run.log` and `pilot_run2.log` preserve two harness setup errors; neither is treated as a product failure.
- `pretest_hashes.json` / `protected_hashes_after.json`: owner-local and save preservation inventory.
- Historical cross-check: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json` and its immutable audit chain.

## Required next calibration evidence

Before any 100-level budget or star formula is enabled, collect no-timer, time-scale-1.0 production-physics trials for every distinct order class with multiple reproducible seeds and at least two policies. Enforce each candidate move limit through the real commit path for validation runs; separate candidate-discovery runs from under-budget acceptance runs. Use observed win-shot distributions to choose and validate one-star caps and two/three-star cutoffs, including interval bounds and seed sensitivity. Any class without natural wins must remain unresolved and be corrected through separately authorized design changes rather than assigned an invented threshold. Then migrate score-star assumptions in focused and progression regressions.

No product configuration, runtime, scoring, stars, rewards, progression, or HUD code has changed in this child. Root `TASKS.md` remains read-only. `M26` remains untouched.
