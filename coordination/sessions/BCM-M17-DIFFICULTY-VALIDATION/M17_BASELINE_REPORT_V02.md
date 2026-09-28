# M17 V02 Seeded Difficulty Baseline

This is tooling/evidence only. The planning model is not a physical guarantee, and no canonical level, timer, VIP, reward, HUD, table, or physics data was tuned.

- Calibration: `1.500` seconds per launch (named provisional planning assumption; overrideable).
- Target multiplier: `×2.0`.
- Percentiles: R7 linear interpolation over sorted completion times.
- Physics time scale: `4.0`; the focused reproducibility probe uses canonical scale `1.0`.
- Runtime limit: 10 trials were impractical at canonical scale after a measured L1 timeout took approximately 20 seconds wall time; this cohort uses the prompt-authorized minimum of 3 trials per required level with explicit accelerated Godot physics timing. The focused M17 probe remains canonical scale 1.0.
- Seed schedule: `base + level_id * 1000 + trial_index`.
- Rail metric: `footprint_proximity_transition_proxy`; enter `<= 1.0 px`, release `> 3.0 px`; this is a footprint-to-authoritative-boundary transition proxy, not a body collision callback.

| Level | Trials | Completion | Median sec | P75 sec | P90 sec | Timeout | Danger | Abort | Median occ. | Peak live | Large coexist. | Rail events | Cost | Plan target sec | Timer sec | Flag |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| L1 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 3 | 0 | 0 | 0.0208 | 4.0 | 0.0 | 0.0 | 16 | 20.57 | 20 | baseline outlier; needs further validation |
| L10 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 1 | 2 | 0 | 0.0637 | 12.0 | 0.0 | 0.0 | 64 | 82.29 | 80 | baseline outlier; needs further validation |
| L11 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 2 | 1 | 0 | 0.0391 | 8.0 | 0.0 | 0.0 | 48 | 61.71 | 60 | baseline outlier; needs further validation |
| L20 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0619 | 11.0 | 0.0 | 0.0 | 96 | 123.43 | 120 | baseline outlier; needs further validation |
| L21 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0599 | 12.0 | 0.0 | 0.0 | 64 | 82.29 | 80 | baseline outlier; needs further validation |
| L30 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0642 | 11.0 | 0.0 | 0.0 | 112 | 144.00 | 140 | baseline outlier; needs further validation |
| L31 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0605 | 12.0 | 0.0 | 0.0 | 80 | 102.86 | 100 | baseline outlier; needs further validation |
| L40 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0628 | 11.0 | 0.0 | 0.0 | 128 | 164.57 | 160 | baseline outlier; needs further validation |
| L41 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0665 | 12.0 | 0.0 | 0.0 | 96 | 123.43 | 120 | baseline outlier; needs further validation |
| L50 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0663 | 11.0 | 0.0 | 1.0 | 144 | 185.14 | 180 | baseline outlier; needs further validation |
| L51 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0610 | 11.0 | 0.0 | 0.0 | 112 | 144.00 | 140 | baseline outlier; needs further validation |
| L60 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0639 | 12.0 | 0.0 | 0.0 | 176 | 226.29 | 220 | baseline outlier; needs further validation |
| L61 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0660 | 11.0 | 0.0 | 0.0 | 128 | 164.57 | 160 | baseline outlier; needs further validation |
| L70 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0648 | 12.0 | 0.0 | 1.0 | 176 | 226.29 | 220 | baseline outlier; needs further validation |
| L71 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0637 | 11.0 | 0.0 | 0.0 | 144 | 185.14 | 180 | baseline outlier; needs further validation |
| L80 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0686 | 11.0 | 0.0 | 0.0 | 192 | 246.86 | 240 | baseline outlier; needs further validation |
| L81 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0617 | 11.0 | 0.0 | 0.0 | 160 | 205.71 | 200 | baseline outlier; needs further validation |
| L90 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0637 | 12.0 | 0.0 | 0.0 | 208 | 267.43 | 260 | baseline outlier; needs further validation |
| L91 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0605 | 12.0 | 0.0 | 0.0 | 176 | 226.29 | 220 | baseline outlier; needs further validation |
| L100 | 3 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 3 | 0 | 0.0582 | 12.0 | 0.0 | 1.0 | 240 | 308.57 | 300 | baseline outlier; needs further validation |

## Interpretation boundary

The baseline bot is a deterministic lane-placement policy, not an optimal human. A low completion rate, timeout, danger result, or candidate flag is an observation requiring further validation, not a final impossible-level or tuning decision. A TABLE_DANGER trial is counted as danger, never timeout; timeout is reserved for actual time-limit exhaustion. `contact_count` is a body collision callback count, while `rail_contact_count` is the documented proximity transition proxy. Spatial metrics are telemetry from the production Drink/GameManager physics hook; theoretical cost and timer planning are analytical values.
