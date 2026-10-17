# BCM-M33-004 — Winnability sample, Claude closure (2026-10-17)

## Owner scope

- Test the owner-frozen random sample only: seed `20261016`, 10 distinct levels per island, 100 levels
  (`.../BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/qualification/r23_random_selection_seed_20261016_v01.json`,
  SHA-256 `ef21d5a3023ae7328424da4e459b667c6d6b0dbd567e7a2106cc9b9161d66eb2`, re-verified by the runner before every run).
- Owner ruling 2026-10-17: **no difficulty grading or difficulty evaluation.** Each level is reported only as
  WINNABLE (bot won within the normal 4T move cap) or NOT_WON_BY_BOT.

## Root cause of the R16–R24 "BUDGET_UNKNOWN" loop

All earlier trials ran production physics in real time (60 frames = 1 s per shot) under a self-imposed 120 s wall
clock. Levels allow 96–224 moves, so trials were cut off at ~100 shots. Every one of the 16 R23/R24
`BUDGET_UNKNOWN` results has `reason = PER_LEVEL_WALL_BUDGET` at 94–102 shots. They were never game outcomes.

## Protocol `UNCENSORED_FIXED_FPS_V01`

- `tools/campaign/m33_004_sample_trial.gd`: production `GameManager`, `ShotController._unhandled_input` launch path,
  Godot 2D physics, spawn L1–L3, R21 lane policy, normal 4T cap, VIP optional, no timer.
- Launched with `godot --headless --fixed-fps 60`: each frame advances physics by exactly 1/60 s (same step as normal
  play), only without waiting for the real clock. No wall-clock cutoff inside the trial; the runner keeps a 900 s
  process timeout that was never hit.
- `tools/campaign/m33_004_run_sample.py`: parallel runner, isolated APPDATA/LOCALAPPDATA per process, resumable.
  `--retry-unwon` adds seeded extra attempts (`case_seed + k*100000000`) only for levels with no recorded win.
- `tools/campaign/m33_004_summarize.py` → `evidence/m33_004_summary.json`, `evidence/M33_004_SUMMARY.md`.

Real-time vs fixed-fps cross-check on the same levels/seeds (R23+R24 records vs this run, attempt 0):
all 10 real-time wins are also fixed-fps wins; 14 of the 16 wall-censored levels won on the first fixed-fps attempt,
the other 2 (final_island L76, tiki_island L45) won on a later attempt.

## Result

- **100 / 100 sampled levels winnable** within the normal 4T move cap, 10/10 on every island.
- 154 trials: 137 `WIN_OBSERVED`, 17 `LOSS_OUT_OF_MOVES`, 0 `LOSS_DANGER`, 0 errors, 0 trials over the 4T cap.
- 93 levels won on the first attempt; the other 7 (sunny_cove L36/L80, sunset_island L25, party_beach L6/L32/L35,
  final_island L67) won on attempts 1–5.
- 6 in-flight trials were killed by Claude when the run was re-scoped mid-way; those NO_RESULT files were discarded
  (all six levels already had wins) and are not counted.
- Earlier R23/R24 records are kept unchanged as historical evidence.

## Limits (stated, not hidden)

- A bot is not a human; this proves the sampled levels can be finished, not how they feel to a player.
- 100 of 1000 levels, by owner decision. The remaining 900 were not played.
- Godot physics is not bit-deterministic run to run; results are observed outcomes, not replay hashes.
