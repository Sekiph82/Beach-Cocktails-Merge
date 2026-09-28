# M17 V01 telemetry and harness definitions

The M17 harness is validation tooling. It loads the canonical Sunny Cove data read-only and drives production `GameManager.spawn_drink`, `Drink.launch_up`, `Drink`, `MergeQueue`, and Godot physics frames through a bounded test hook. It never calls campaign completion APIs to fake a result and it does not write player save state.

## Analytical planning metrics

The reusable model in `scripts/campaign/m17_difficulty_model.gd` uses `cost(Ln) = 2^(n-1)` and sums normal orders only. VIP cost is reported separately. The L1-L3 spawn expectation is `(1 + 2 + 4) / 3 = 7/3` L1-equivalent value per launch and `objective_cost / (7/3)` expected launches. The default calibration is the named, overrideable `DEFAULT_SECONDS_PER_LAUNCH = 1.5`; it is a provisional round planning assumption, not a measured runtime guarantee. The planning target is raw production time ×2.

## Trial record

Each seeded trial records:

| Field | Definition |
| --- | --- |
| `island_id`, `level_id`, `seed` | Canonical identity and deterministic trial seed. |
| `outcome` | One of `completed`, `timeout`, `danger`, `harness_abort`. |
| `elapsed_sec`, `remaining_sec` | Simulated 1/60-second step time and bridge timer remainder at terminal observation. |
| `shot_count` | Number of actual `GameManager.spawn_drink` bodies launched by the harness. |
| `merge_count` | Unique production `Drink.merged` pair requests observed; duplicate two-sided contact signals are deduplicated by body-pair/new-level key. |
| `failed_merge_approach_count` | Bounded proxy: a same-level live body existed when an action launched, but no unique merge request was observed during that action's fixed physics window. It is not a claim that the player failed. |
| `peak_live_drinks`, `mean_live_drinks` | Live non-held production Drink bodies sampled each physics frame; mean is the arithmetic mean of samples. |
| `peak_board_occupancy` | Deterministic area proxy: sum of production collider-circle areas divided by the documented `360000 px²` canonical playable-area estimate. |
| `large_piece_coexistence_peak` | Maximum simultaneous live bodies with cocktail level ≥7. |
| `contact_count` | Production `Drink.body_entered` callbacks observed by the harness. |
| `rail_contact_count` | Subset of contact callbacks whose body name contains `Rail` or `TopRail`. |
| `danger_line_exposure_sec` | Fixed-step sum while a settled production body extends below the configured danger line. |
| `normal_objective_complete` | True only when the production gameplay/session bridge reaches normal WIN. |
| `vip_complete` | Optional VIP state only; never part of mandatory completion. |
| `action_log` | Exact deterministic spawn-level, lane-index, x-position, and action-step records required for replay. |

The deterministic baseline bot chooses an existing same-level body position when available; otherwise it chooses the least-occupied one of seven fixed lanes with a seed/action-index tie rotation. It is deliberately non-optimal. Same-seed replay is expected to preserve logical outcome and action log; telemetry timing may vary by at most the documented fixed-step tolerance when the OS schedules frames differently.

Percentiles in the baseline report use R7 linear interpolation over sorted completion times. Empty completion cohorts report `0.0` and retain timeout/danger/abort counts.

The report may say `baseline outlier` or `needs further validation`. V01 does not decide impossibility and does not tune canonical level data.
