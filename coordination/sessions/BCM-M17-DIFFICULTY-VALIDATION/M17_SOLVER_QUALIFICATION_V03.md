# M17 V03A Merge-Aware Solver Qualification

Policy: `MERGE_AWARE_V01`; canonical qualification scale: `1.0x`; this is validation evidence only and does not tune canonical data.

Seed schedule: `base + level_id * 1000 + trial_index`; cohort: `30` trials (`[1, 10, 11, 50, 51, 100]`).

| Level | Trials | Complete | Timeout | Danger | Abort | Completion | Median sec | Median merges | Peak live | Median occ. | Rail proxy | Contacts | Failed merge | Timer | Cost |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| L1 | 5 | 3 | 2 | 0 | 0 | 0.60 | 17.28 | 9.0 | 9.0 | 0.0628 | 1.0 | 20.0 | 1.0 | 20 | 16 |
| L10 | 5 | 1 | 1 | 3 | 0 | 0.20 | 78.40 | 39.0 | 19.0 | 0.1364 | 2.0 | 99.0 | 13.0 | 80 | 64 |
| L11 | 5 | 3 | 1 | 1 | 0 | 0.60 | 41.30 | 26.0 | 15.0 | 0.1076 | 2.0 | 68.0 | 9.0 | 60 | 48 |
| L50 | 5 | 0 | 0 | 5 | 0 | 0.00 | 0.00 | 28.0 | 18.0 | 0.1210 | 1.0 | 79.0 | 12.0 | 180 | 144 |
| L51 | 5 | 0 | 0 | 5 | 0 | 0.00 | 0.00 | 36.0 | 20.0 | 0.1361 | 1.0 | 102.0 | 14.0 | 140 | 112 |
| L100 | 5 | 0 | 0 | 5 | 0 | 0.00 | 0.00 | 26.0 | 19.0 | 0.1219 | 1.0 | 76.0 | 15.0 | 300 | 240 |

## Machine-readable qualification

- Verdict: `SOLVER_QUALIFIED_FOR_M17_007`
- `FIXED_LANE_FAILURE = false`
- L1 completion: `3/5`; L10: `1/5`; L11: `3/5`.
- Lateral variation: `30/30 = 1.00`; minimum `0.80`.
- Focused fixture result: `true`; same-seed log: `true`; replay: `true`.
- 4x spot-check historical telemetry-only flag: `true`.

## Interpretation boundary

This is a small deterministic diagnostic cohort, not statistical significance and not a player difficulty rating. No M17-007 final classification, M17-008 tuning, timer change, objective change, physics change, or canonical data change is authorized by this report.
